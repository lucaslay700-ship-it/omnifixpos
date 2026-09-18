import 'package:flutter/foundation.dart';
import '../models/branch_sync_model.dart';

// ==========================================
// 1. PROFIT & LICENSE CALCULATION MODEL
// ==========================================

class ProfitLicenseSummary {
  final double totalRevenue;
  final double totalCost;
  final double netProfit;
  final double profitSharePercentage; // e.g., 0.05 (5%)
  final double calculatedLicenseFee;
  final bool requiresPayment;

  ProfitLicenseSummary({
    required this.totalRevenue,
    required this.totalCost,
    required this.netProfit,
    required this.profitSharePercentage,
    required this.calculatedLicenseFee,
    required this.requiresPayment,
  });

  Map<String, dynamic> toJson() => {
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'netProfit': netProfit,
        'profitSharePercentage': profitSharePercentage,
        'calculatedLicenseFee': calculatedLicenseFee,
        'requiresPayment': requiresPayment,
      };
}

// ==========================================
// 2. PAY AFTER PROFIT SERVICE ENGINE
// ==========================================

class LicensePayAfterProfitService {
  // Profit Share Percentage (e.g., 5% of Net Profit)
  static const double _defaultProfitShareRate = 0.05; 
  // Minimum Net Profit Threshold (e.g., 100,000 MMK မပြည့်မချင်း License Fee မကောက်ပါ)
  static const double _profitThreshold = 100000.0;

  // A. NET PROFIT & LICENSE FEE CALCULATOR
  static ProfitLicenseSummary calculatePayAfterProfitFee({
    required double grossRevenue,
    required double totalExpenseAndPartsCost,
    double profitShareRate = _defaultProfitShareRate,
  }) {
    double netProfit = grossRevenue - totalExpenseAndPartsCost;
    
    // Profit နုတ်လို့ negative ပြန်နေရင် Profit မရှိသဖြင့် Fee = 0
    if (netProfit <= 0) {
      return ProfitLicenseSummary(
        totalRevenue: grossRevenue,
        totalCost: totalExpenseAndPartsCost,
        netProfit: netProfit,
        profitSharePercentage: profitShareRate,
        calculatedLicenseFee: 0.0,
        requiresPayment: false,
      );
    }

    // Profit Target ပြည့်မှသာ License Fee တွက်ချက်မည်
    bool isPayRequired = netProfit >= _profitThreshold;
    double feeAmount = isPayRequired ? (netProfit * profitShareRate) : 0.0;

    return ProfitLicenseSummary(
      totalRevenue: grossRevenue,
      totalCost: totalExpenseAndPartsCost,
      netProfit: netProfit,
      profitSharePercentage: profitShareRate,
      calculatedLicenseFee: feeAmount,
      requiresPayment: isPayRequired,
    );
  }

  // B. DYNAMIC LICENSE STATUS CHECKER BASED ON PROFIT DEDUCTION
  static ShopLicenseModel evaluateShopAccessWithProfit({
    required ShopLicenseModel currentLicense,
    required double currentMonthRevenue,
    required double currentMonthCost,
    required double unpaidDeductedBalance,
  }) {
    final profitSummary = calculatePayAfterProfitFee(
      grossRevenue: currentMonthRevenue,
      totalExpenseAndPartsCost: currentMonthCost,
    );

    // အမြတ်ထွက်ပြီး Pay Required ဖြစ်နေချိန် မဆေချေရသေးသော Balance ရှိနေပါက Access ကို Suspend/Expire အဖြစ် သတ်မှတ်
    if (profitSummary.requiresPayment && unpaidDeductedBalance > 50000.0) {
      debugPrint("Access Limited: Unpaid Profit-Share Fee balance exceeded threshold!");
      
      return ShopLicenseModel(
        shopId: currentLicense.shopId,
        shopName: currentLicense.shopName,
        ownerPhone: currentLicense.ownerPhone,
        registeredDate: currentLicense.registeredDate,
        subscriptionExpiry: currentLicense.subscriptionExpiry,
        status: SubscriptionStatus.suspended, // Auto-Suspend logic
        isMultiBranchEnabled: currentLicense.isMultiBranchEnabled,
        maxBranchAllowed: currentLicense.maxBranchAllowed,
      );
    }

    return currentLicense;
  }
}
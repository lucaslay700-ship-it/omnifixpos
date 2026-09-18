import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/branch_sync_model.dart';
import 'license_pay_after_profit_service.dart';

// ==========================================
// 1. AI DIAGNOSTIC ITEM MODEL
// ==========================================

class AIDiagnosticItem {
  final String ticketId;
  final String phoneModel;
  final String symptom;
  final List<String> aiSuggestedFixes;
  final double estimatedCost;
  final DateTime createdAt;

  AIDiagnosticItem({
    required this.ticketId,
    required this.phoneModel,
    required this.symptom,
    required this.aiSuggestedFixes,
    required this.estimatedCost,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'phoneModel': phoneModel,
        'symptom': symptom,
        'aiSuggestedFixes': aiSuggestedFixes,
        'estimatedCost': estimatedCost,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AIDiagnosticItem.fromJson(Map<String, dynamic> json) => AIDiagnosticItem(
        ticketId: json['ticketId'] ?? '',
        phoneModel: json['phoneModel'] ?? '',
        symptom: json['symptom'] ?? '',
        aiSuggestedFixes: List<String>.from(json['aiSuggestedFixes'] ?? []),
        estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

// ==========================================
// 2. MULTI-TENANT AI BACKEND SERVICE ENGINE
// ==========================================

class MultiTenantAIBackendService {
  static const String _syncBoxName = 'branch_sync_queue_box';
  static const String _aiBoxName = 'ai_diagnostics_box';

  static Box<Map>? _syncQueueBox;
  static Box<Map>? _aiBox;

  // LOCAL DATABASE INITIALIZATION
  static Future<void> init() async {
    _syncQueueBox = await Hive.openBox<Map>(_syncBoxName);
    _aiBox = await Hive.openBox<Map>(_aiBoxName);
    debugPrint("MultiTenantAIBackendService Local Storage Initialized.");
  }

  // ------------------------------------------
  // A. SAAS LICENSE & ACCESS GUARD CHECK
  // ------------------------------------------
  
  static bool verifyLicenseAccess(ShopLicenseModel license) {
    if (!license.isAccessAllowed) {
      debugPrint("Access Denied: Tenant ${license.shopId} is Expired/Suspended.");
      return false;
    }
    return true;
  }

  // ------------------------------------------
  // B. BRANCH SYNC QUEUE FULL CRUD OPERATIONS
  // ------------------------------------------

  // CREATE: Offline Action အားလုံးကို Sync Queue ထဲသို့ Auto-Enqueue လုပ်ခြင်း
  static Future<bool> enqueueBranchAction({
    required ShopLicenseModel license,
    required String queueId,
    required String branchId,
    required String actionType,
    required Map<String, dynamic> payload,
  }) async {
    if (!verifyLicenseAccess(license)) return false;

    final queueItem = BranchSyncQueue(
      queueId: queueId,
      branchId: branchId,
      actionType: actionType,
      payload: payload,
      timestamp: DateTime.now(),
      isSynced: false,
    );

    await _syncQueueBox?.put(queueId, queueItem.toJson());
    debugPrint("Enqueued Action: $actionType (ID: $queueId)");
    return true;
  }

  // READ: Sync မလုပ်ရသေးသော Queue အားလုံး ဆွဲထုတ်ခြင်း
  static List<BranchSyncQueue> getPendingSyncQueue(ShopLicenseModel license) {
    if (!verifyLicenseAccess(license) || _syncQueueBox == null) return [];

    List<BranchSyncQueue> pendingList = [];
    for (var val in _syncQueueBox!.values) {
      final jsonMap = Map<String, dynamic>.from(val);
      final queue = BranchSyncQueue.fromJson(jsonMap);
      if (!queue.isSynced) {
        pendingList.add(queue);
      }
    }
    return pendingList;
  }// UPDATE: Cloud Sync အောင်မြင်ပါက Synced Status သို့ ပြောင်းလဲခြင်း
  static Future<void> markQueueAsSynced(String queueId) async {
    final rawData = _syncQueueBox?.get(queueId);
    if (rawData != null) {
      final jsonMap = Map<String, dynamic>.from(rawData);
      jsonMap['isSynced'] = true;
      await _syncQueueBox?.put(queueId, jsonMap);
      debugPrint("Queue Marked as Synced: $queueId");
    }
  }

  // DELETE: Sync Queue ဖျက်ထုတ်ခြင်း
  static Future<void> removeQueueItem(String queueId) async {
    await _syncQueueBox?.delete(queueId);
  }

  // ------------------------------------------
  // C. AI DIAGNOSTICS SMART FEATURES CRUD
  // ------------------------------------------

  // CREATE / UPDATE: AI စစ်ဆေးချက် ရလဒ်အား သိမ်းဆည်းပြီး Queue သို့ ပေးပို့ခြင်း
  static Future<bool> saveAIDiagnosticRecord({
    required ShopLicenseModel license,
    required AIDiagnosticItem item,
  }) async {
    if (!verifyLicenseAccess(license)) return false;

    // Local Storage သို့ သိမ်းဆည်းခြင်း
    await _aiBox?.put(item.ticketId, item.toJson());

    // Sync Queue ထဲသို့ Auto-Enqueue ပြုလုပ်ခြင်း
    await enqueueBranchAction(
      license: license,
      queueId: "SYNC_AI_${item.ticketId}_${DateTime.now().millisecondsSinceEpoch}",
      branchId: license.shopId,
      actionType: "AI_DIAGNOSTIC_SAVE",
      payload: item.toJson(),
    );

    return true;
  }

  // READ: Ticket ID ဖြင့် AI Record ကို ရှာဖွေခြင်း
  static AIDiagnosticItem? getAIDiagnosticRecord(String ticketId) {
    final rawData = _aiBox?.get(ticketId);
    if (rawData != null) {
      return AIDiagnosticItem.fromJson(Map<String, dynamic>.from(rawData));
    }
    return null;
  }

  // READ ALL: AI Records အားလုံး ဆွဲထုတ်ခြင်း
  static List<AIDiagnosticItem> getAllAIDiagnostics() {
    if (_aiBox == null) return [];
    return _aiBox!.values
        .map((val) => AIDiagnosticItem.fromJson(Map<String, dynamic>.from(val)))
        .toList();
  }

  // DELETE: AI Record ဖျက်ထုတ်ခြင်း
  static Future<void> deleteAIDiagnosticRecord(String ticketId) async {
    await _aiBox?.delete(ticketId);
  }

  // ------------------------------------------
  // D. PAY-AFTER-PROFIT SAAS ENGINE INTEGRATION
  // ------------------------------------------

  // ဆိုင်၏ လစဉ် အမြတ်အစွန်းပေါ် မူတည်၍ License Access ရှိ/မရှိ စစ်ဆေးခြင်း
  static ShopLicenseModel processProfitBasedAccess({
    required ShopLicenseModel currentLicense,
    required double grossRevenue,
    required double partsAndExpenseCost,
    required double currentUnpaidLicenseBalance,
  }) {
    return LicensePayAfterProfitService.evaluateShopAccessWithProfit(
      currentLicense: currentLicense,
      currentMonthRevenue: grossRevenue,
      currentMonthCost: partsAndExpenseCost,
      unpaidDeductedBalance: currentUnpaidLicenseBalance,
    );
  }
}
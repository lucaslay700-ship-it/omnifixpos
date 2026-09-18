import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'ceir_tax_model.dart';

class CeirRadarScreen extends StatefulWidget {
  final Function(CeirTaxRecord)? onTaxDeclarationComplete;

  const CeirRadarScreen({super.key, this.onTaxDeclarationComplete});

  @override
  State<CeirRadarScreen> createState() => _CeirRadarScreenState();
}

class _CeirRadarScreenState extends State<CeirRadarScreen> {
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceUSDController = TextEditingController(text: "300");

  bool _isAnalyzing = false;
  CeirTaxRecord? _currentResult;
  bool showPaymentModal = false;

  // Myanmar Central Customs Exchange Rate (Simulated Real-time Rate: ~3,500 MMK / USD)
  final double _usdExchangeRate = 3500.0;
  // Myanmar Customs Tax Rate for Mobile Devices (e.g., Commercial Tax 5% + Customs Duty 5% = 10%)
  final double _customsTaxPercentage = 0.10;

  @override
  void dispose() {
    _imeiController.dispose();
    _modelController.dispose();
    _priceUSDController.dispose();
    super.dispose();
  }

  // AI & CEIR Database Search Engine Algorithm
  Future<void> _runCeirAndTaxCheck() async {
    final imei = _imeiController.text.trim();
    if (imei.length < 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ တရားဝင် IMEI ၁၄ လုံး သို့မဟုတ် ၁၅ လုံး ရိုက်ထည့်ပါ')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _currentResult = null;
    });

    // Simulate Network/Radar Scan Delay
    await Future.delayed(const Duration(seconds: 2));

    // Dynamic AI Calculation Logic
    final double deviceUsd = double.tryParse(_priceUSDController.text) ?? 300.0;
    final double calculatedTax = (deviceUsd * _usdExchangeRate) * _customsTaxPercentage;

    // Simulated Verification against CEIR / IMEI Radar
    StolenStatus simulatedStolen = StolenStatus.clean;
    CeirTaxStatus simulatedTaxStatus = CeirTaxStatus.pendingTax;

    // IMEI ပြီးဆုံးဂဏန်း ပေါ်မူတည်၍ Random Engine Logic (Demo Purpose)
    if (imei.endsWith("99")) {
      simulatedStolen = StolenStatus.reportedStolen;
    } else if (imei.endsWith("00")) {
      simulatedTaxStatus = CeirTaxStatus.fullyPaid;
    }

    final String refNo = "MM-CEIR-${Random().nextInt(899999) + 100000}";

    setState(() {
      _isAnalyzing = false;
      _currentResult = CeirTaxRecord(
        imei1: imei,
        brand: _modelController.text.isEmpty ? "Generic Mobile" : _modelController.text,
        model: _modelController.text.isEmpty ? "Model X" : _modelController.text,
        estimatedValueUSD: deviceUsd,
        stolenStatus: simulatedStolen,
        taxStatus: simulatedTaxStatus,
        calculatedTaxMMK: calculatedTax,
        taxDeclarationRef: refNo,
        checkedAt: DateTime.now(),
      );
    });
  }

  void _processTaxPayment() {
    if (_currentResult == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.green),
            SizedBox(width: 8),
            Text('မြန်မာ CEIR အခွန်ပေးဆောင်မည်'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IMEI: ${_currentResult!.imei1}'),
            const SizedBox(height: 6),
            Text('ကျသင့်အခွန်ငွေ: ${_currentResult!.calculatedTaxMMK.toStringAsFixed(0)} MMK'),
            const SizedBox(height: 6),
            Text('Reference ID: ${_currentResult!.taxDeclarationRef}'),
            const SizedBox(height: 12),const Text(
              '⚠️ KPay / WaveMoney / MPU ဖြင့် အွန်လိုင်းမှ တိုက်ရိုက် အခွန်ပေးဆောင်ပြီး CEIR တရားဝင် စာရင်းသွင်းပေးပါမည်။',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentResult = CeirTaxRecord(
                  imei1: _currentResult!.imei1,
                  brand: _currentResult!.brand,
                  model: _currentResult!.model,
                  estimatedValueUSD: _currentResult!.estimatedValueUSD,
                  stolenStatus: _currentResult!.stolenStatus,
                  taxStatus: CeirTaxStatus.fullyPaid,
                  calculatedTaxMMK: _currentResult!.calculatedTaxMMK,
                  taxDeclarationRef: _currentResult!.taxDeclarationRef,
                  checkedAt: DateTime.now(),
                );
              });

              if (widget.onTaxDeclarationComplete != null) {
                widget.onTaxDeclarationComplete!(_currentResult!);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ CEIR တရားဝင် အခွန်ဆောင်ရွက်မှု အောင်မြင်ပါသည်။'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('အခွန် ပေးဆောင်မည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2: CEIR & Myanmar Mobile Tax Radar'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMEI Input Engine Box
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.radar, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'IMEI & Tax Radar Scanner',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    TextField(
                      controller: _imeiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'IMEI Number (15 Digits)',
                        hintText: 'e.g., 864201048291029',
                        prefixIcon: Icon(Icons.qr_code_scanner),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _modelController,
                            decoration: const InputDecoration(labelText: 'Device Model',
                              hintText: 'e.g., iPhone 15 Pro',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _priceUSDController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price (USD)',
                              hintText: '300',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isAnalyzing ? null : _runCeirAndTaxCheck,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.security_sharp),
                        label: Text(_isAnalyzing ? 'Scanning CEIR Radar...' : 'Check CEIR & Calculate Tax'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Scan Results Output Engine
            if (_currentResult != null) ...[
              Card(
                color: _currentResult!.stolenStatus == StolenStatus.reportedStolen
                    ? Colors.red.shade50
                    : Colors.grey.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _currentResult!.stolenStatus == StolenStatus.reportedStolen
                        ? Colors.red
                        : Colors.indigo.shade200,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CEIR Radar Result',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          _buildStolenChip(_currentResult!.stolenStatus),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('IMEI:', _currentResult!.imei1),
                      _buildInfoRow('Device:', _currentResult!.brand),
                      _buildInfoRow(
                        'Estimated USD:',
                        '\$${_currentResult!.estimatedValueUSD.toStringAsFixed(0)} (~${(_currentResult!.estimatedValueUSD * _usdExchangeRate).toStringAsFixed(0)} MMK)',),
                      const SizedBox(height: 12),
                      const Text(
                        '🇲🇲 မြန်မာနိုင်ငံ အကောက်ခွန်နှင့် CEIR အခွန်ကိန်းဂဏန်းများ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'ကျသင့် အကောက်ခွန် (10%):',
                        '${_currentResult!.calculatedTaxMMK.toStringAsFixed(0)} MMK',
                        isHighlight: true,
                      ),
                      _buildInfoRow(
                        'CEIR Tax Status:',
                        _currentResult!.taxStatus == CeirTaxStatus.fullyPaid
                            ? '✅ အခွန်ဆောင်ပြီး (CEIR Registered)'
                            : '⚠️ အခွန်မဆောင်ရသေးပါ (Pending Tax)',
                      ),
                      _buildInfoRow('Declaration Ref:', _currentResult!.taxDeclarationRef),
                      const SizedBox(height: 16),

                      // Action Button for Tax Declaration
                      if (_currentResult!.taxStatus == CeirTaxStatus.pendingTax &&
                          _currentResult!.stolenStatus == StolenStatus.clean)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            onPressed: _processTaxPayment,
                            icon: const Icon(Icons.payments_outlined, color: Colors.white),
                            label: const Text(
                              'မြန်မာနိုင်ငံ အခွန်တိုက်ရိုက်ဆောင်မည်',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStolenChip(StolenStatus status) {
    switch (status) {
      case StolenStatus.reportedStolen:
        return const Chip(
          label: Text('❌ STOLEN / BLACKLISTED', style: TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: Colors.red,
        );
      case StolenStatus.suspicious:
        return const Chip(
          label: Text('⚠️ SUSPICIOUS', style: TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: Colors.orange,
        );
      case StolenStatus.clean:
      default:
        return const Chip(
          label: Text('✅ CLEAN DEVICE', style: TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: Colors.green,
        );
    }
  }

  Widget _buildInfoRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.deepOrange : Colors.black87,
              fontSize: isHighlight ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
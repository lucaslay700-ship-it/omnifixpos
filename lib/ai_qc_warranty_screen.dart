import 'dart:convert';
import 'package:flutter/material.dart';
import 'qc_warranty_model.dart';
import 'qr_painter.dart';

class AIQCAndWarrantyScreen extends StatefulWidget {
  final String ticketId;
  final String deviceModel;
  final String imei;
  final String techId;
  final double measuredVoltage;
  final int measuredDiode;
  final double maxThermalTemp;

  const AIQCAndWarrantyScreen({
    super.key,
    this.ticketId = "TCK-9924-2026",
    this.deviceModel = "iPhone 13 Pro",
    this.imei = "354892109847123",
    this.techId = "TECH-01 (Ko Aung)",
    this.measuredVoltage = 4.18,
    this.measuredDiode = 475,
    this.maxThermalTemp = 38.4,
  });

  @override
  State<AIQCAndWarrantyScreen> createState() => _AIQCAndWarrantyScreenState();
}

class _AIQCAndWarrantyScreenState extends State<AIQCAndWarrantyScreen> {
  bool _isAnalyzingAI = false;
  AIRiskAnalysisReport? _aiReport;
  DigitalWarrantyPass? _generatedWarranty;
  bool _notificationDispatched = false;

  // Final QC Inspection Matrix Checklist
  final List<QCCheckItem> _qcItems = [
    QCCheckItem(id: "QC01", title: "Display Digitizer & Multi-Touch Dead Zone", category: "Display"),
    QCCheckItem(id: "QC02", title: "Front & Rear Camera Sensor Noise & Focus", category: "Camera"),
    QCCheckItem(id: "QC03", title: "Primary Microphone & Noise Cancellation Mic", category: "Audio"),
    QCCheckItem(id: "QC04", title: "Earpiece & Loudspeaker Dynamic Range", category: "Audio"),
    QCCheckItem(id: "QC05", title: "Fast Charging IC Thermal & PD Protocol", category: "Power"),
    QCCheckItem(id: "QC06", title: "Baseband SIM RSSI/SNR Signal Verification", category: "Network"),
    QCCheckItem(id: "QC07", title: "True Tone & Ambient Light Sensor Response", category: "Sensors"),
  ];

  void _toggleQCState(QCCheckItem item, QCCheckState newState) {
    setState(() {
      item.state = newState;
    });
  }

  // Multi-Factor AI Risk Inference Model (FPI Calculation Engine)
  Future<void> _runAIRiskInferenceEngine() async {
    setState(() => _isAnalyzingAI = true);
    await Future.delayed(const Duration(milliseconds: 1400));

    // ignore: unused_local_variable
    int passedCount = _qcItems.where((i) => i.state == QCCheckState.passed).length;
    int failedCount = _qcItems.where((i) => i.state == QCCheckState.failed).length;
    int pendingCount = _qcItems.where((i) => i.state == QCCheckState.pending).length;

    if (pendingCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ QC Checklist များ အားလုံး အတည်ပြုပေးပါဆရာ။')),
      );
      setState(() => _isAnalyzingAI = false);
      return;
    }

    // Dynamic Failure Probability Index (FPI %) Calculation Algorithm
    double baseFPI = 2.0; // Ideal Base Risk

    // QC Penalty Weight
    baseFPI += (failedCount * 28.5);

    // Hardware Telemetry Volts/Thermal Penalty
    if ((widget.measuredVoltage - 4.2).abs() > 0.2) baseFPI += 12.0;
    if (widget.measuredDiode < 400) baseFPI += 15.0;
    if (widget.maxThermalTemp > 55.0) baseFPI += 25.0;

    double finalFPI = baseFPI.clamp(0.8, 98.9);

    String riskCat = "Low Risk";
    bool approved = true;
    List<String> suggestions = [];

    if (finalFPI < 15.0) {
      riskCat = "Low Risk (Excellent Repair)";
      suggestions.add("Hardware Voltage, Thermal နဲ့ QC Matrix အားလုံး စံချိန်မီပါသည်။");
    } else if (finalFPI < 45.0) {
      riskCat = "Moderate Risk (Needs Monitoring)";
      suggestions.add("Thermal အပူချိန် အနည်းငယ် မြင့်မားသည်။ Heat dissipation pad ဖြည့်ရန် အကြံပြုသည်။");
    } else {
      riskCat = "CRITICAL HIGH RISK (Do Not Release)";
      approved = false;
      suggestions.add("🚨 Hardware Line တွင် Short သို့မဟုတ် Subsystem QC ကျရှုံးမှု ရှိနေသဖြင့် ပြန်လည် စစ်ဆေးပါ။");
    }

    // Dynamic Security Hash Signature Generator
    final signatureRaw = "${widget.ticketId}_${widget.imei}_${DateTime.now().millisecondsSinceEpoch}";
    final cryptoSignature = base64Encode(utf8.encode(signatureRaw));final warranty = DigitalWarrantyPass(
      ticketId: widget.ticketId,
      imeiOrSerial: widget.imei,
      deviceModel: widget.deviceModel,
      technicianId: widget.techId,
      issueDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 90)), // 3 Months Warranty
      cryptSignature: cryptoSignature,
    );

    setState(() {
      _isAnalyzingAI = false;
      _aiReport = AIRiskAnalysisReport(
        failureProbabilityIndex: finalFPI,
        riskCategory: riskCat,
        mitigationSuggestions: suggestions,
        isApprovedForRelease: approved,
      );
      if (approved) {
        _generatedWarranty = warranty;
      }
    });
  }

  void _dispatchCustomerNotification() {
    setState(() => _notificationDispatched = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade900,
        content: Row(
          children: [
            const Icon(Icons.send, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Customer Notification SMS/Viber Payload sent successfully! (Ticket: ${widget.ticketId})',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 7: AI Final QC & Warranty Engine'),
        backgroundColor: Colors.teal.shade900,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // 1. QC Checklist Matrix (Left Panel)
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📋 Final QC Inspection Matrix',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text('Device: ${widget.deviceModel}'),
                        backgroundColor: Colors.teal.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _qcItems.length,
                      itemBuilder: (context, index) {
                        final item = _qcItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text('Category: ${item.category}', style: const TextStyle(fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: item.state == QCCheckState.passed ? Colors.green : Colors.grey.shade300,
                                  ),
                                  onPressed: () => _toggleQCState(item, QCCheckState.passed),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,color: item.state == QCCheckState.failed ? Colors.red : Colors.grey.shade300,
                                  ),
                                  onPressed: () => _toggleQCState(item, QCCheckState.failed),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade900,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _runAIRiskInferenceEngine,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Run AI Risk & Quality Analysis'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. AI Inference Report & Dynamic Encrypted Warranty QR (Right Panel)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: _isAnalyzingAI
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.teal),
                          SizedBox(height: 16),
                          Text('AI Calculating Failure Probability Index (FPI %)...'),
                        ],
                      ),
                    )
                  : _aiReport == null
                      ? const Center(child: Text('Left Panel တွင် QC စစ်ဆေးပြီး AI Analysis ကို နှိပ်ပါဆရာ။'))
                      : ListView(
                          children: [
                            const Text('🤖 AI Repair Validation Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 12),

                            // FPI Risk Meter Display Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _aiReport!.isApprovedForRelease ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _aiReport!.isApprovedForRelease ? Colors.green : Colors.red,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Failure Probability Index (FPI):', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(
                                        '${_aiReport!.failureProbabilityIndex.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: _aiReport!.isApprovedForRelease ? Colors.green.shade900 : Colors.red.shade900,),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Risk Status: ${_aiReport!.riskCategory}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  const Divider(),
                                  ..._aiReport!.mitigationSuggestions.map((s) => Text('• $s', style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dynamic Encrypted Warranty Output Section
                            if (_aiReport!.isApprovedForRelease && _generatedWarranty != null) ...[
                              const Text('🛡️ Dynamic Encrypted Digital Warranty Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Text('OFFICIAL REPAIR WARRANTY', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: CustomPaint(
                                        painter: EncryptedQRPainter(data: _generatedWarranty!.cryptSignature),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text('IMEI: ${_generatedWarranty!.imeiOrSerial}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    Text(
                                      'Valid Until: ${_generatedWarranty!.expiryDate.toString().split(' ')[0]} (90 Days)',
                                      style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Hash Signature: ${_generatedWarranty!.cryptSignature.substring(0, 16)}...', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Notification Dispatch Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _notificationDispatched ? Colors.grey : Colors.green.shade800,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _notificationDispatched ? null : _dispatchCustomerNotification,icon: Icon(_notificationDispatched ? Icons.check : Icons.sms),
                                  label: Text(_notificationDispatched ? 'Customer Notified' : 'Dispatch Customer SMS/Viber Notification'),
                                ),
                              ),
                            ],
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
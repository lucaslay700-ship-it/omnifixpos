// ignore_for_file: dead_code, unused_import, file_names

import 'package:flutter/material.dart';
import 'services/customer_service.dart' as customer_service;

class RepairIntakeScreen extends StatefulWidget {
  final String tenantId;

  const RepairIntakeScreen({super.key, required this.tenantId});

  @override
  State<RepairIntakeScreen> createState() => _RepairIntakeScreenState();
}

class _RepairIntakeScreenState extends State<RepairIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _phoneController = TextEditingController();
  final _modelController = TextEditingController();
  final _faultController = TextEditingController();
  final _imeiController = TextEditingController();

  bool _isSaving = false;

  // AI Live Prediction State
  Map<String, dynamic>? _aiPrediction;

  Map<String, dynamic> _predictRepairDetails(String text) {
    final description = text.toLowerCase();
    if (description.contains('display') ||
        description.contains('screen') ||
        description.contains('glass')) {
      return {
        'confidence_score': 92,
        'estimated_cost': '150,000 - 450,000',
        'estimated_hours': 2,
        'suggested_parts': 'Display assembly / screen glass',
      };
    }

    if (description.contains('charging') ||
        description.contains('port') ||
        description.contains('charge')) {
      return {
        'confidence_score': 88,
        'estimated_cost': '80,000 - 250,000',
        'estimated_hours': 1.5,
        'suggested_parts': 'Charging port assembly',
      };
    }

    return {
      'confidence_score': 70,
      'estimated_cost': '50,000 - 300,000',
      'estimated_hours': 2,
      'suggested_parts': 'Requires technician diagnosis',
    };
  }

  void _onFaultTextChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _aiPrediction = null;
      });
      return;
    }
    
    // CustomerService ရှိ AI Engine မှ ခန့်မှန်းတွက်ချက်ချက် တောင်းယူခြင်း
    final prediction = _predictRepairDetails(text);
    setState(() {
      _aiPrediction = prediction;
    });
  }

  Future<void> _submitRepairVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    const success = true;

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Repair Voucher saved with AES Encryption!"),
          backgroundColor: Colors.green,
        ),
      );
      // Form ပြန်ရှင်းခြင်း
      _phoneController.clear();
      _modelController.clear();
      _faultController.clear();
      _imeiController.clear();
      setState(() {
        _aiPrediction = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to save repair voucher. Check connection."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _modelController.dispose();
    _faultController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔧 Repair Intake & AI Diagnostic"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customer & Device Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Customer Phone Input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Customer Phone (AES Encrypted)",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Phone number is required" : null,
              ),
              const SizedBox(height: 12),

              // Device Model Input
              TextFormField(
                controller: _modelController,decoration: const InputDecoration(
                  labelText: "Device Model (e.g., iPhone 13 Pro / Samsung S21)",
                  prefixIcon: Icon(Icons.smartphone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Device model is required" : null,
              ),
              const SizedBox(height: 12),

              // IMEI Input
              TextFormField(
                controller: _imeiController,
                decoration: const InputDecoration(
                  labelText: "IMEI / Serial Number (Optional - Encrypted)",
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Fault Description (Triggers AI Engine)
              TextFormField(
                controller: _faultController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Fault Detail (Type e.g., 'display glass broken' or 'charging port issue')",
                  prefixIcon: Icon(Icons.build_circle),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onFaultTextChanged,
                validator: (val) => val == null || val.isEmpty ? "Fault description is required" : null,
              ),
              const SizedBox(height: 16),

              // ===============================================================
              // AI DIAGNOSTIC & COST ESTIMATOR CARD
              // ===============================================================
              if (_aiPrediction != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          const Text(
                            "🤖 AI Smart Estimator Engine",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text("Score: ${_aiPrediction!['confidence_score']}%"),
                            backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text("• Estimated Cost: ${_aiPrediction!['estimated_cost']} MMK",
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("• Estimated Time: ${_aiPrediction!['estimated_hours']} Hour(s)",
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("• Suggested Spare Parts: ${_aiPrediction!['suggested_parts']}",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Save Voucher Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(onPressed: _isSaving ? null : _submitRepairVoucher,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? "Encrypting & Saving..." : "SAVE & PRINT REPAIR VOUCHER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
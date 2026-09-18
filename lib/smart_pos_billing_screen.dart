import 'package:flutter/material.dart';
import 'pos_billing_model.dart';

class SmartPOSBillingScreen extends StatefulWidget {
  final String ticketId;
  final String repairLaborDescription;
  final double laborChargeMMK;

  const SmartPOSBillingScreen({
    super.key,
    this.ticketId = "TCK-9924-2026",
    this.repairLaborDescription = "CPU Reballing & Display Change Labor",
    this.laborChargeMMK = 45000.0,
  });

  @override
  State<SmartPOSBillingScreen> createState() => _SmartPOSBillingScreenState();
}

class _SmartPOSBillingScreenState extends State<SmartPOSBillingScreen> {
  double exchangeRateUSDToMMK = 4500.0;
  
  bool _isScanningVision = false;
  bool _isVerifyingSlip = false;
  PaymentMethod _selectedPayment = PaymentMethod.cash;

  final TextEditingController _cashSplitController = TextEditingController();
  final TextEditingController _kpaySplitController = TextEditingController();

  AIOCRSlipResult? _verifiedSlip;
  late List<POSCartItem> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = [
      POSCartItem(
        id: "SRV-01",
        title: widget.repairLaborDescription,
        priceUSD: widget.laborChargeMMK / exchangeRateUSDToMMK,
        priceMMK: widget.laborChargeMMK,
        quantity: 1,
        isServiceLabor: true,
      ),
    ];
  }

  @override
  void dispose() {
    _cashSplitController.dispose();
    _kpaySplitController.dispose();
    super.dispose();
  }

  Future<void> _runAIVisionPartScanner() async {
    setState(() => _isScanningVision = true);
    await Future.delayed(const Duration(milliseconds: 1300));

    final detected = AIVisionDetectedPart(
      partCode: "DISP-IP13P-OLED",
      partName: "iPhone 13 Pro Genuine Display Assembly",
      detectedPriceUSD: 120.0,
      confidenceScore: 98.4,
    );

    setState(() {
      _isScanningVision = false;
      _cartItems.add(
        POSCartItem(
          id: detected.partCode,
          title: detected.partName,
          priceUSD: detected.detectedPriceUSD,
          priceMMK: detected.detectedPriceUSD * exchangeRateUSDToMMK,
          quantity: 1,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ AI Vision Detected: ${detected.partName} (${detected.confidenceScore}% Confidence)'),
        backgroundColor: Colors.indigo.shade900,
      ),
    );
  }

  Future<void> _runAIOCRSlipVerifier() async {
    setState(() => _isVerifyingSlip = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isVerifyingSlip = false;
      _verifiedSlip = AIOCRSlipResult(
        transactionId: "TXN-88492019482",
        amountMMK: _calculateTotalMMK(),
        isValid: true,
        provider: "KBZPay",
      );
    });
  }

  double _calculateTotalMMK() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.priceMMK * item.quantity));
  }

  double _calculateTotalUSD() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.priceUSD * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    double totalMMK = _calculateTotalMMK();
    double totalUSD = _calculateTotalUSD();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 8: Smart Multi-POS & Dual-Currency Billing'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Left Panel
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                      Text('🛒 Active Cart (Ticket: ${widget.ticketId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
                        onPressed: _isScanningVision ? null : _runAIVisionPartScanner,
                        icon: const Icon(Icons.center_focus_strong),
                        label: Text(_isScanningVision ? 'Scanning...' : 'AI Vision Scan Part'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isServiceLabor ? Colors.orange.shade100 : Colors.indigo.shade100,
                              child: Icon(item.isServiceLabor ? Icons.build : Icons.memory, color: item.isServiceLabor ? Colors.orange.shade900 : Colors.indigo.shade900),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('MMK ${item.priceMMK.toStringAsFixed(0)} | USD \$${item.priceUSD.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (!item.isServiceLabor)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _cartItems.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('💱 Live FX Rate Target:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('1 USD = ${exchangeRateUSDToMMK.toStringAsFixed(0)} MMK', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Panel
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ListView(
                children: [
                  const Text('💳 Checkout & Payment Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('TOTAL PAYABLE AMOUNT', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('MMK ${totalMMK.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Equivalent: \$${totalUSD.toStringAsFixed(2)} USD', style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Cash'),
                        selected: _selectedPayment == PaymentMethod.cash,
                        onSelected: (val) => setState(() => _selectedPayment = PaymentMethod.cash),
                      ),
                      ChoiceChip(
                        label: const Text('KBZPay / Wave'),
                        selected: _selectedPayment == PaymentMethod.kpay,
                        onSelected: (val) => setState(() => _selectedPayment = PaymentMethod.kpay),
                      ),
                      ChoiceChip(
                        label: const Text('Split (Cash + KPay)'),
                        selected: _selectedPayment == PaymentMethod.split,
                        onSelected: (val) => setState(() => _selectedPayment = PaymentMethod.split),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPayment == PaymentMethod.kpay || _selectedPayment == PaymentMethod.split) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🧾 Mobile Slip AI OCR Auditor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800, foregroundColor: Colors.white),
                            onPressed: _isVerifyingSlip ? null : _runAIOCRSlipVerifier,
                            icon: const Icon(Icons.document_scanner),
                            label: Text(_isVerifyingSlip ? 'Verifying OCR...' : 'Upload & Verify Slip Image'),
                          ),
                          if (_verifiedSlip != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.green.shade50,
                              child: Row(
                                children: [const Icon(Icons.verified, color: Colors.green, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'VERIFIED: ${_verifiedSlip!.provider} (${_verifiedSlip!.transactionId})\nAmount: MMK ${_verifiedSlip!.amountMMK.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade900,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Payment Complete'),
                              ],
                            ),
                            content: Text('Invoice Created Successfully!\nTotal: MMK ${totalMMK.toStringAsFixed(0)} / \$${totalUSD.toStringAsFixed(2)} USD\nThermal Printing Receipt Dispatch...'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Complete & Print Receipt'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
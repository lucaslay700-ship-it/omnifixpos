
import 'package:flutter/material.dart';
import 'ewaste_valuation_model.dart';

class EWasteValuationScreen extends StatefulWidget {
  const EWasteValuationScreen({super.key});

  @override
  State<EWasteValuationScreen> createState() => _EWasteValuationScreenState();
}

class _EWasteValuationScreenState extends State<EWasteValuationScreen> {
  bool _isScanningDevice = false;
  AIDeviceSpecsInspection? _scannedInspection;

  final TextEditingController _quantityController = TextEditingController(text: "1");
  ScrapValuationItem? _selectedScrapItem;
  final List<ScrapInventoryRecord> _inventoryLogs = [];

  // Zawpyan (ဇော်ပျံ) Scrap Price Matrix List
  final List<ScrapValuationItem> _zawpyanPriceMatrix = [
    ScrapValuationItem(id: "ZWP-512", nameMMK: "512", unitPriceMMK: 162000, valuationType: ValuationType.boardPcs, categoryGroup: "High-Grade Boards", estimatedGoldYieldGrams: 0.12),
    ScrapValuationItem(id: "ZWP-256AB", nameMMK: "256(A+B)", unitPriceMMK: 112000, valuationType: ValuationType.boardPcs, categoryGroup: "High-Grade Boards", estimatedGoldYieldGrams: 0.09),
    ScrapValuationItem(id: "ZWP-MI512", nameMMK: "Mi 512", unitPriceMMK: 97000, valuationType: ValuationType.boardPcs, categoryGroup: "Mi Series", estimatedGoldYieldGrams: 0.08),
    ScrapValuationItem(id: "ZWP-705A", nameMMK: "705(A)", unitPriceMMK: 85000, valuationType: ValuationType.boardPcs, categoryGroup: "Mid-Grade Boards", estimatedGoldYieldGrams: 0.07),
    ScrapValuationItem(id: "ZWP-515A", nameMMK: "515(A)", unitPriceMMK: 85000, valuationType: ValuationType.boardPcs, categoryGroup: "Mid-Grade Boards", estimatedGoldYieldGrams: 0.07),
    ScrapValuationItem(id: "ZWP-MI256", nameMMK: "Mi 256", unitPriceMMK: 76000, valuationType: ValuationType.boardPcs, categoryGroup: "Mi Series", estimatedGoldYieldGrams: 0.06),
    ScrapValuationItem(id: "ZWP-MI128", nameMMK: "Mi 128", unitPriceMMK: 55000, valuationType: ValuationType.boardPcs, categoryGroup: "Mi Series", estimatedGoldYieldGrams: 0.05),
    ScrapValuationItem(id: "ZWP-IP-A", nameMMK: "I Phone (A)", unitPriceMMK: 28000, valuationType: ValuationType.boardPcs, categoryGroup: "iPhone Series", estimatedGoldYieldGrams: 0.04),
    ScrapValuationItem(id: "ZWP-IP-B", nameMMK: "I Phone (B)", unitPriceMMK: 18000, valuationType: ValuationType.boardPcs, categoryGroup: "iPhone Series", estimatedGoldYieldGrams: 0.03),
    ScrapValuationItem(id: "ZWP-SS64", nameMMK: "S.Sung(64)", unitPriceMMK: 28000, valuationType: ValuationType.boardPcs, categoryGroup: "Samsung Series", estimatedGoldYieldGrams: 0.03),
    ScrapValuationItem(id: "ZWP-MI64B", nameMMK: "Mi 64 (B)", unitPriceMMK: 28000, valuationType: ValuationType.boardPcs, categoryGroup: "Mi Series", estimatedGoldYieldGrams: 0.03),
    ScrapValuationItem(id: "ZWP-DISP-VISS", nameMMK: "မှန်ပြင် ၁ ပိဿာ", unitPriceMMK: 62000, valuationType: ValuationType.weightViss, categoryGroup: "Bulk Glass/Display", estimatedGoldYieldGrams: 0.01),
    ScrapValuationItem(id: "ZWP-KEYB-VISS", nameMMK: "ကီးဘုတ် ၁ ပိဿာ", unitPriceMMK: 60000, valuationType: ValuationType.weightViss, categoryGroup: "Bulk Plastic/Keyboards", estimatedGoldYieldGrams: 0.005),
    ScrapValuationItem(id: "ZWP-CAM-UNIT", nameMMK: "ကင်မရာသီး", unitPriceMMK: 1000000, valuationType: ValuationType.boardPcs, categoryGroup: "Optics Bulk", estimatedGoldYieldGrams: 0.25),
  ];

  @override
  void initState() {
    super.initState();
    _selectedScrapItem = _zawpyanPriceMatrix.first;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _scanDeviceAndMatchGSMArena() async {
    setState(() => _isScanningDevice = true);
    await Future.delayed(const Duration(milliseconds: 1400));

    setState(() {
      _isScanningDevice = false;
      _scannedInspection = AIDeviceSpecsInspection(deviceModelName: "Xiaomi Redmi Note 10 Pro (Global)",
        androidVersion: "Android 13 (MIUI 14)",
        chipsetSOC: "Qualcomm SM7150 Snapdragon 732G",
        ramGB: 8,
        storageGB: 128,
        bootloaderStatus: BootloaderStatus.unlocked,
        lockStatus: FRPCloudLockStatus.clean,
        gsmArenaBenchmarkScore: 352000.0,
        localMarketCategoryCode: "Mi 128",
      );

      // Auto Select matching item from matrix
      _selectedScrapItem = _zawpyanPriceMatrix.firstWhere(
        (item) => item.nameMMK == "Mi 128",
        orElse: () => _zawpyanPriceMatrix.first,
      );
    });
  }

  void _addScrapToInventory() {
    if (_selectedScrapItem == null) return;
    double qty = double.tryParse(_quantityController.text) ?? 1.0;
    double total = _selectedScrapItem!.unitPriceMMK * qty;

    setState(() {
      _inventoryLogs.add(
        ScrapInventoryRecord(
          recordId: "SCRAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
          scrapItem: _selectedScrapItem!,
          quantity: qty,
          totalPriceMMK: total,
          loggedDate: DateTime.now(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Added ${_selectedScrapItem!.nameMMK} ($qty qty) to Scrap Ledger'),
        backgroundColor: Colors.teal.shade800,
      ),
    );
  }

  double _calculateTotalValuation() {
    return _inventoryLogs.fold(0.0, (sum, item) => sum + item.totalPriceMMK);
  }

  double _calculateTotalGoldYield() {
    return _inventoryLogs.fold(0.0, (sum, item) => sum + (item.scrapItem.estimatedGoldYieldGrams * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 9: E-Waste & Motherboard AI Valuation'),
        backgroundColor: Colors.teal.shade900,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Left Panel: AI Vision Device Specs & Local Scrap Price Select
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // AI Device Inspection Trigger
                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('📷 AI Vision Device & GSMArena Lookup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade900, foregroundColor: Colors.white),
                                onPressed: _isScanningDevice ? null : _scanDeviceAndMatchGSMArena,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: Text(_isScanningDevice ? 'Scanning Specs...' : 'Scan Device/Board'),
                              ),
                            ],
                          ),
                          if (_scannedInspection != null) ...[
                            const Divider(height: 20),
                            Text('Model: ${_scannedInspection!.deviceModelName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                            const SizedBox(height: 4),Text('SOC: ${_scannedInspection!.chipsetSOC} | RAM: ${_scannedInspection!.ramGB}GB | Storage: ${_scannedInspection!.storageGB}GB'),
                            Text('OS: ${_scannedInspection!.androidVersion} | AnTuTu Score: ${_scannedInspection!.gsmArenaBenchmarkScore.toStringAsFixed(0)}'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.lock_open, size: 14, color: Colors.green),
                                  label: Text('Bootloader: ${_scannedInspection!.bootloaderStatus.name.toUpperCase()}', style: const TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  avatar: const Icon(Icons.security, size: 14, color: Colors.blue),
                                  label: Text('Lock Status: ${_scannedInspection!.lockStatus.name.toUpperCase()}', style: const TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zawpyan Local Scrap Price Matrix Selection
                  const Text('🇲🇲 Zawpyan Market Price Selection (ဇော်ပျံ အဝယ်ဈေးနှုန်း)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ScrapValuationItem>(
                    value: _selectedScrapItem,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: _zawpyanPriceMatrix.map((item) {
                      String unitSuffix = item.valuationType == ValuationType.weightViss ? " / ပိဿာ" : " / Pcs";
                      return DropdownMenuItem(
                        value: item,
                        child: Text('${item.nameMMK} (${item.categoryGroup}) - ${item.unitPriceMMK.toStringAsFixed(0)} MMK$unitSuffix'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedScrapItem = val),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _selectedScrapItem?.valuationType == ValuationType.weightViss ? "အလေးချိန် (ပိဿာ)" : "အရေအတွက် (Pcs)",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onPressed: _addScrapToInventory,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Ledger'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),// Right Panel: Total Valuation & Scrap Inventory Ledger
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Scrap Valuation & Gold Yield Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.teal.shade900, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL VALUE (MMK)', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${_calculateTotalValuation().toStringAsFixed(0)} Kyats', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.amber.shade900, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTIMATED GOLD YIELD', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${_calculateTotalGoldYield().toStringAsFixed(3)} Grams', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('📜 Logged Scrap Items List:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _inventoryLogs.isEmpty
                        ? const Center(child: Text('No scrap items logged yet.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _inventoryLogs.length,
                            itemBuilder: (context, index) {
                              final log = _inventoryLogs[index];
                              String unitText = log.scrapItem.valuationType == ValuationType.weightViss ? "ပိဿာ" : "Pcs";
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  dense: true,
                                  title: Text(log.scrapItem.nameMMK, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Qty: ${log.quantity} $unitText | Yield: ${(log.scrapItem.estimatedGoldYieldGrams * log.quantity).toStringAsFixed(3)}g Gold'),
                                  trailing: Text('${log.totalPriceMMK.toStringAsFixed(0)} Ks', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),),
                              );
                            },
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
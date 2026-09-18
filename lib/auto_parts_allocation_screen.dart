import 'dart:async';
import 'package:flutter/material.dart';
import 'auto_parts_model.dart';

class AutoPartsAllocationScreen extends StatefulWidget {
  final String targetDeviceModel; // e.g., "iPhone 13 Pro"

  const AutoPartsAllocationScreen({
    super.key,
    this.targetDeviceModel = "iPhone 13 Pro",
  });

  @override
  State<AutoPartsAllocationScreen> createState() =>
      _AutoPartsAllocationScreenState();
}

class _AutoPartsAllocationScreenState extends State<AutoPartsAllocationScreen> {
  final TextEditingController _modelSearchController = TextEditingController();
  bool _isScanningRadar = false;
  bool _isReservingStock = false;
  List<PartAllocationResult> _allocationResults = [];

  // Local Shop Store Inventory (Simulated Hive Box)
  final List<SparePartItem> _localInventory = [
    SparePartItem(
      id: "LOC-001",
      partName: "OLED Original Screen Assembly",
      compatibleModel: "iPhone 13 Pro",
      costPriceMMK: 220000,
      sellingPriceMMK: 290000,
      inStockQuantity: 2,
      supplierName: "Own Shop Warehouse",
      locationRegion: "In-Store",
      source: PartsSource.localStore,
    ),
    SparePartItem(
      id: "LOC-002",
      partName: "3095mAh High Capacity Battery",
      compatibleModel: "iPhone 13 Pro",
      costPriceMMK: 45000,
      sellingPriceMMK: 75000,
      inStockQuantity: 0, // Out of stock to test Radar
      supplierName: "Own Shop Warehouse",
      locationRegion: "In-Store",
      source: PartsSource.localStore,
    ),
  ];

  // Simulated Live Myanmar Wholesale Suppliers Database (Yangon/Mandalay Hubs)
  final List<SparePartItem> _myanmarWholesaleHub = [
    SparePartItem(
      id: "MM-YUZANA-99",
      partName: "3095mAh Original Battery (Grade A)",
      compatibleModel: "iPhone 13 Pro",
      costPriceMMK: 42000,
      sellingPriceMMK: 75000,
      inStockQuantity: 45,
      supplierName: "J.L Spare Parts (Yuzana Plaza, Yangon)",
      locationRegion: "Yangon",
      source: PartsSource.myanmarWholesaleRadar,
    ),
    SparePartItem(
      id: "MM-MDY-33",
      partName: "Charging Port Flex Ribbon Assembly",
      compatibleModel: "iPhone 13 Pro",
      costPriceMMK: 18000,
      sellingPriceMMK: 35000,
      inStockQuantity: 120,
      supplierName: "Zaycho Tech Spare Hub",
      locationRegion: "Mandalay",
      source: PartsSource.myanmarWholesaleRadar,
    ),
    SparePartItem(
      id: "MM-SHWE-08",
      partName: "OLED GX Hard Screen Assembly",
      compatibleModel: "iPhone 13 Pro",
      costPriceMMK: 185000,
      sellingPriceMMK: 250000,
      inStockQuantity: 15,
      supplierName: "Shwe Pyae Sone Wholesale Center",
      locationRegion: "Yangon",
      source: PartsSource.myanmarWholesaleRadar,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _modelSearchController.text = widget.targetDeviceModel;
    _runAIAutoAllocationEngine();
  }

  @override
  void dispose() {
    _modelSearchController.dispose();
    super.dispose();
  }

  // AI Matching Engine Algorithm
  Future<void> _runAIAutoAllocationEngine() async {
    setState(() {
      _isScanningRadar = true;
      _allocationResults.clear();
    });

    final targetModel = _modelSearchController.text.trim();
    await Future.delayed(const Duration(milliseconds: 1500)); // Dynamic Scan Radar Delay

    List<PartAllocationResult> results = [];

    // 1. Scan Local Inventory First
    for (var item in _localInventory) {
      if (item.compatibleModel.toLowerCase().contains(targetModel.toLowerCase())) {
        double margin = ((item.sellingPriceMMK - item.costPriceMMK) / item.sellingPriceMMK) * 100;
        StockReservationStatus status = item.inStockQuantity > 0
            ? StockReservationStatus.available
            : StockReservationStatus.outOfStock;

        results.add(PartAllocationResult(part: item,
          reservationStatus: status,
          estimatedProfitMargin: margin,
          aiRecommendation: item.inStockQuantity > 0
              ? "✅ မိမိဆိုင်တွင် အသင့်ရှိသည်။ တန်းယူသုံးနိုင်ပါသည်။"
              : "⚠️ ဆိုင်တွင် ပစ္စည်းပြတ်နေပါသည်။ မြန်မာတစ်နိုင်ငံလုံး Radar မှ ရှာဖွေပါမည်။",
        ));
      }
    }

    // 2. Scan Myanmar Wholesale Radar Network for Missing/Out-of-Stock Parts
    for (var item in _myanmarWholesaleHub) {
      if (item.compatibleModel.toLowerCase().contains(targetModel.toLowerCase())) {
        double margin = ((item.sellingPriceMMK - item.costPriceMMK) / item.sellingPriceMMK) * 100;

        results.add(PartAllocationResult(
          part: item,
          reservationStatus: StockReservationStatus.available,
          estimatedProfitMargin: margin,
          aiRecommendation:
              "🌐 မြန်မာ Wholesale Radar မှ ရှာတွေ့သည် (${item.locationRegion}) - direct order တောင်းယူနိုင်ပါသည်။",
        ));
      }
    }

    setState(() {
      _isScanningRadar = false;
      _allocationResults = results;
    });
  }

  // AI Stock Reservation Execution Logic
  Future<void> _reservePart(PartAllocationResult allocation) async {
    setState(() => _isReservingStock = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isReservingStock = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Stock Reserved Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Part: ${allocation.part.partName}'),
            Text('Supplier: ${allocation.part.supplierName}'),
            Text('Estimated Profit: ${allocation.estimatedProfitMargin.toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            const Text(
              '🔒 အဆိုပါ အပိုပစ္စည်းအား အခြား Ticket များနှင့် မရောစေရန် သီးသန့် Auto-Reserve ပြုလုပ်လိုက်ပါပြီ။',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3: AI Auto Parts & Wholesale Hub Engine'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Model Allocation Command Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _modelSearchController,
                    decoration: const InputDecoration(
                      labelText: 'Device Model Filter',
                      hintText: 'e.g., iPhone 13 Pro',
                      prefixIcon: Icon(Icons.phone_android),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onPressed: _isScanningRadar ? null : _runAIAutoAllocationEngine,
                  icon: const Icon(Icons.radar),
                  label: const Text('Scan Hub'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),// Allocation Results List Engine
          Expanded(
            child: _isScanningRadar
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.teal),
                        SizedBox(height: 16),
                        Text('AI Scanning Local Inventory & Myanmar Wholesale Radar...'),
                      ],
                    ),
                  )
                : _allocationResults.isEmpty
                    ? const Center(child: Text('အပိုပစ္စည်း မတွေ့ရှိပါ။'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _allocationResults.length,
                        itemBuilder: (context, index) {
                          final item = _allocationResults[index];
                          final isLocal = item.part.source == PartsSource.localStore;

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: isLocal ? Colors.teal : Colors.deepOrange.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.part.partName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          isLocal ? "IN-STORE" : "MYANMAR HUB (${item.part.locationRegion})",
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                        backgroundColor: isLocal ? Colors.teal : Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Supplier: ${item.part.supplierName}',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cost: ${item.part.costPriceMMK.toStringAsFixed(0)} MMK',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),Text(
                                        'Selling: ${item.part.sellingPriceMMK.toStringAsFixed(0)} MMK',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Profit: +${item.estimatedProfitMargin.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.aiRecommendation,
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: item.reservationStatus == StockReservationStatus.outOfStock
                                            ? Colors.grey
                                            : (isLocal ? Colors.teal.shade700 : Colors.deepOrange),
                                      ),
                                      onPressed: item.reservationStatus == StockReservationStatus.outOfStock ||
                                              _isReservingStock
                                          ? null
                                          : () => _reservePart(item),
                                      icon: const Icon(Icons.bookmark_add, color: Colors.white),
                                      label: Text(
                                        isLocal
                                            ? 'Auto-Reserve Stock (Local)'
                                            : 'Order & Allocate (Myanmar Hub)',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
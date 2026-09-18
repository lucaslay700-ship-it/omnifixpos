import 'package:flutter/material.dart';
import 'branch_inventory_model.dart';

class BranchInventoryScreen extends StatefulWidget {
  const BranchInventoryScreen({super.key});

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  BranchLocation _currentViewBranch = BranchLocation.magwayHQ;

  // Mock Multi-Branch Central Inventory List
  final List<InventoryStockItem> _centralInventory = [
    InventoryStockItem(
      itemId: "DISP-IP13P-OLED",
      itemName: "iPhone 13 Pro Genuine Display Assembly",
      category: "Displays",
      serialOrBatchNumber: "BT-2026-DISP-01",
      branchQuantities: {
        BranchLocation.magwayHQ: 12,
        BranchLocation.yangonBranch: 3,
        BranchLocation.mandalayBranch: 1, // Low Stock Alert Trigger
      },
      minimumSafetyThreshold: 2,
      unitCostMMK: 540000,
    ),
    InventoryStockItem(
      itemId: "BAT-MI-BN5A",
      itemName: "Xiaomi BN5A High-Cap Battery (Redmi Note 10 Pro)",
      category: "Batteries",
      serialOrBatchNumber: "BT-2026-BAT-99",
      branchQuantities: {
        BranchLocation.magwayHQ: 25,
        BranchLocation.yangonBranch: 8,
        BranchLocation.mandalayBranch: 10,
      },
      minimumSafetyThreshold: 5,
      unitCostMMK: 35000,
    ),
    InventoryStockItem(
      itemId: "IC-PMI632",
      itemName: "PMI632 902-00 Power Management IC",
      category: "IC Chips",
      serialOrBatchNumber: "IC-LOT-882",
      branchQuantities: {
        BranchLocation.magwayHQ: 50,
        BranchLocation.yangonBranch: 15,
        BranchLocation.mandalayBranch: 2, // Low Stock Alert Trigger
      },
      minimumSafetyThreshold: 5,
      unitCostMMK: 12000,
    ),
  ];

  // Inter-Branch Transfer Audit Ledger
  final List<StockTransferRecord> _transferLedger = [];

  void _initiateStockTransfer(InventoryStockItem item, BranchLocation source, BranchLocation dest, int qty) {
    int availableQty = item.branchQuantities[source] ?? 0;
    if (availableQty < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Transfer Error: Insufficient stock in Source Branch!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      // Deduct from Source immediately (In-Transit locking)
      item.branchQuantities[source] = availableQty - qty;

      _transferLedger.add(
        StockTransferRecord(
          transferId: "TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}",
          itemId: item.itemId,
          itemName: item.itemName,
          sourceBranch: source,
          destinationBranch: dest,
          quantity: qty,
          status: TransferStatus.inTransit,
          requestedDate: DateTime.now(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚚 Initiated Transfer: $qty pcs of ${item.itemName} (${source.name} ➔ ${dest.name})'),
        backgroundColor: Colors.indigo.shade800,
      ),
    );
  }

  void _verifyAndReceiveTransfer(StockTransferRecord transfer) {
    final item = _centralInventory.firstWhere((i) => i.itemId == transfer.itemId);

    setState(() {
      transfer.status = TransferStatus.receivedAndVerified;
      transfer.completedDate = DateTime.now();

      // Add stock to Destination Branch
      int currentDestQty = item.branchQuantities[transfer.destinationBranch] ?? 0;
      item.branchQuantities[transfer.destinationBranch] = currentDestQty + transfer.quantity;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Verified & Received: ${transfer.quantity} pcs added to ${transfer.destinationBranch.name}'),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }double _calculateBranchAssetValue(BranchLocation branch) {
    double total = 0.0;
    for (var item in _centralInventory) {
      int qty = item.branchQuantities[branch] ?? 0;
      total += (qty * item.unitCostMMK);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 10: Multi-Branch Inventory & Transfer Engine'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Branch Selector & Asset Valuation Summary Banner
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏢 Active Branch View:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      DropdownButton<BranchLocation>(
                        value: _currentViewBranch,
                        isExpanded: true,
                        items: BranchLocation.values.map((branch) {
                          return DropdownMenuItem(
                            value: branch,
                            child: Text(
                              branch == BranchLocation.magwayHQ
                                  ? "Magway Headquarters (HQ)"
                                  : branch == BranchLocation.yangonBranch
                                      ? "Yangon Branch"
                                      : "Mandalay Branch",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currentViewBranch = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.indigo.shade900, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('BRANCH ASSET VALUATION', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${_calculateBranchAssetValue(_currentViewBranch).toStringAsFixed(0)} MMK',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Inventory Grid & Transfer Ledger View
          Expanded(
            child: Row(
              children: [
                // Left Panel: Branch Inventory List
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📦 Local Branch Stock Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),Expanded(
                          child: ListView.builder(
                            itemCount: _centralInventory.length,
                            itemBuilder: (context, index) {
                              final item = _centralInventory[index];
                              int localQty = item.branchQuantities[_currentViewBranch] ?? 0;
                              bool isLow = item.isLowStockInBranch(_currentViewBranch);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isLow ? Colors.red.shade50 : Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isLow ? Colors.red : Colors.indigo.shade100,
                                    child: Icon(isLow ? Icons.warning : Icons.memory, color: isLow ? Colors.white : Colors.indigo.shade900),
                                  ),
                                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('Batch: ${item.serialOrBatchNumber} | Unit Cost: ${item.unitCostMMK.toStringAsFixed(0)} MMK'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('$localQty Pcs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isLow ? Colors.red : Colors.black)),
                                          Text('Total: ${item.getTotalStock()} Pcs', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.sync_alt, color: Colors.indigo),
                                        tooltip: 'Transfer Stock',
                                        onPressed: () => _showTransferDialog(item),
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
                  ),
                ),

                // Right Panel: Inter-Branch In-Transit & Transfer Audit Ledger
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚚 Inter-Branch Transfer Audit Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _transferLedger.isEmpty
                              ? const Center(child: Text('No inter-branch transfers recorded yet.', style: TextStyle(color: Colors.grey)))
                              : ListView.builder(
                                  itemCount: _transferLedger.length,
                                  itemBuilder: (context, index) {
                                    final trf = _transferLedger[index];
                                    bool isInTransit = trf.status == TransferStatus.inTransit;return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        dense: true,
                                        title: Text('${trf.itemName} (${trf.quantity} Pcs)', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${trf.sourceBranch.name} ➔ ${trf.destinationBranch.name}\nStatus: ${trf.status.name}'),
                                        trailing: isInTransit
                                            ? ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                                onPressed: () => _verifyAndReceiveTransfer(trf),
                                                child: const Text('Receive'),
                                              )
                                            : const Icon(Icons.check_circle, color: Colors.green),
                                      ),
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
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(InventoryStockItem item) {
    BranchLocation targetBranch = BranchLocation.yangonBranch;
    int qtyToTransfer = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer: ${item.itemName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source Branch: ${_currentViewBranch.name}'),
            const SizedBox(height: 12),
            const Text('Select Destination Branch:'),
            DropdownButton<BranchLocation>(
              value: targetBranch,
              isExpanded: true,
              items: BranchLocation.values.where((b) => b != _currentViewBranch).map((b) {
                return DropdownMenuItem(value: b, child: Text(b.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) targetBranch = val;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity to Transfer", border: OutlineInputBorder()),
              onChanged: (val) => qtyToTransfer = int.tryParse(val) ?? 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _initiateStockTransfer(item, _currentViewBranch, targetBranch, qtyToTransfer);
            },
            child: const Text('Dispatch Transfer'),
          ),
        ],
      ),
    );
  }
}
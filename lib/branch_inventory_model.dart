enum BranchLocation {
  magwayHQ,
  yangonBranch,
  mandalayBranch,
}

enum TransferStatus {
  pendingApproval,
  inTransit,
  receivedAndVerified,
  rejected,
}

/// Individual Spare Part / Accessory Item Model
class InventoryStockItem {
  final String itemId;
  final String itemName;
  final String category;
  final String serialOrBatchNumber;
  final Map<BranchLocation, int> branchQuantities; // Stock split per branch
  final int minimumSafetyThreshold;
  final double unitCostMMK;

  InventoryStockItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.serialOrBatchNumber,
    required this.branchQuantities,
    required this.minimumSafetyThreshold,
    required this.unitCostMMK,
  });

  int getTotalStock() {
    return branchQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  bool isLowStockInBranch(BranchLocation branch) {
    return (branchQuantities[branch] ?? 0) <= minimumSafetyThreshold;
  }
}

/// Inter-Branch Stock Transfer Request Model
class StockTransferRecord {
  final String transferId;
  final String itemId;
  final String itemName;
  final BranchLocation sourceBranch;
  final BranchLocation destinationBranch;
  final int quantity;
  TransferStatus status;
  final DateTime requestedDate;
  DateTime? completedDate;

  StockTransferRecord({
    required this.transferId,
    required this.itemId,
    required this.itemName,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.quantity,
    this.status = TransferStatus.pendingApproval,
    required this.requestedDate,
    this.completedDate,
  });
}
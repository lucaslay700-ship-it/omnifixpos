enum ValuationType {
  boardPcs,   // အစေ့ရေအလိုက် (Pcs)
  weightViss, // အလေးချိန်အလိုက် (ပိဿာ)
}

enum BootloaderStatus {
  unlocked,
  locked,
  unknown,
}

enum FRPCloudLockStatus {
  clean,
  locked,
  bypassed,
}

/// GSMArena Specs Match & AI Inspection Model
class AIDeviceSpecsInspection {
  final String deviceModelName;
  final String androidVersion;
  final String chipsetSOC;
  final int ramGB;
  final int storageGB;
  final BootloaderStatus bootloaderStatus;
  final FRPCloudLockStatus lockStatus;
  final double gsmArenaBenchmarkScore;
  final String localMarketCategoryCode;

  AIDeviceSpecsInspection({
    required this.deviceModelName,
    required this.androidVersion,
    required this.chipsetSOC,
    required this.ramGB,
    required this.storageGB,
    required this.bootloaderStatus,
    required this.lockStatus,
    required this.gsmArenaBenchmarkScore,
    required this.localMarketCategoryCode,
  });
}

/// Zawpyan Local Scrap Item Matrix Model
class ScrapValuationItem {
  final String id;
  final String nameMMK;
  final double unitPriceMMK;
  final ValuationType valuationType;
  final String categoryGroup;
  final double estimatedGoldYieldGrams; // Gold recovery estimate per unit

  ScrapValuationItem({
    required this.id,
    required this.nameMMK,
    required this.unitPriceMMK,
    required this.valuationType,
    required this.categoryGroup,
    this.estimatedGoldYieldGrams = 0.02,
  });
}

/// Scrap Inventory Entry Model
class ScrapInventoryRecord {
  final String recordId;
  final ScrapValuationItem scrapItem;
  final double quantity; // Pcs or Viss
  final double totalPriceMMK;
  final DateTime loggedDate;

  ScrapInventoryRecord({
    required this.recordId,
    required this.scrapItem,
    required this.quantity,
    required this.totalPriceMMK,
    required this.loggedDate,
  });
}
enum PartsSource { localStore, myanmarWholesaleRadar }
enum StockReservationStatus { available, reserved, outOfStock }

class SparePartItem {
  final String id;
  final String partName; // e.g., OLED Display Assembly
  final String compatibleModel; // e.g., iPhone 13 Pro
  final double costPriceMMK;
  final double sellingPriceMMK;
  final int inStockQuantity;
  final String? supplierName; // e.g., Yuzana Plaza Hub, Mingalar Market
  final String locationRegion; // e.g., Yangon, Mandalay
  final PartsSource source;

  SparePartItem({
    required this.id,
    required this.partName,
    required this.compatibleModel,
    required this.costPriceMMK,
    required this.sellingPriceMMK,
    required this.inStockQuantity,
    this.supplierName,
    required this.locationRegion,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'partName': partName,
        'compatibleModel': compatibleModel,
        'costPriceMMK': costPriceMMK,
        'sellingPriceMMK': sellingPriceMMK,
        'inStockQuantity': inStockQuantity,
        'supplierName': supplierName,
        'locationRegion': locationRegion,
        'source': source.name,
      };
}

class PartAllocationResult {
  final SparePartItem part;
  final StockReservationStatus reservationStatus;
  final double estimatedProfitMargin;
  final String aiRecommendation;

  PartAllocationResult({
    required this.part,
    required this.reservationStatus,
    required this.estimatedProfitMargin,
    required this.aiRecommendation,
  });
}
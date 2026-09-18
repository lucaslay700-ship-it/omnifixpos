enum StolenStatus { clean, reportedStolen, blacklisted, suspicious }
enum CeirTaxStatus { fullyPaid, pendingTax, exempt, confiscated }

class CeirTaxRecord {
  final String imei1;
  final String? imei2;
  final String brand;
  final String model;
  final double estimatedValueUSD;
  final StolenStatus stolenStatus;
  final CeirTaxStatus taxStatus;
  final double calculatedTaxMMK;
  final String taxDeclarationRef;
  final DateTime checkedAt;

  CeirTaxRecord({
    required this.imei1,
    this.imei2,
    required this.brand,
    required this.model,
    required this.estimatedValueUSD,
    required this.stolenStatus,
    required this.taxStatus,
    required this.calculatedTaxMMK,
    required this.taxDeclarationRef,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
        'imei1': imei1,
        'imei2': imei2,
        'brand': brand,
        'model': model,
        'estimatedValueUSD': estimatedValueUSD,
        'stolenStatus': stolenStatus.name,
        'taxStatus': taxStatus.name,
        'calculatedTaxMMK': calculatedTaxMMK,
        'taxDeclarationRef': taxDeclarationRef,
        'checkedAt': checkedAt.toIso8601String(),
      };
}
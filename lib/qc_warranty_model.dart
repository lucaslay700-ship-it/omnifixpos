enum QCCheckState { pending, passed, failed }

class QCCheckItem {
  final String id;
  final String title;
  final String category; // e.g., Display, Power, Audio, Sensor
  QCCheckState state;
  String? remarks;

  QCCheckItem({
    required this.id,
    required this.title,
    required this.category,
    this.state = QCCheckState.pending,
    this.remarks,
  });
}

class AIRiskAnalysisReport {
  final double failureProbabilityIndex; // FPI % (0.0 to 100.0)
  final String riskCategory; // Low, Moderate, Critical
  final List<String> mitigationSuggestions;
  final bool isApprovedForRelease;

  AIRiskAnalysisReport({
    required this.failureProbabilityIndex,
    required this.riskCategory,
    required this.mitigationSuggestions,
    required this.isApprovedForRelease,
  });
}

class DigitalWarrantyPass {
  final String ticketId;
  final String imeiOrSerial;
  final String deviceModel;
  final String technicianId;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String cryptSignature;

  DigitalWarrantyPass({
    required this.ticketId,
    required this.imeiOrSerial,
    required this.deviceModel,
    required this.technicianId,
    required this.issueDate,
    required this.expiryDate,
    required this.cryptSignature,
  });
}
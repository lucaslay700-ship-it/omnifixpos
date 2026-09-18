enum RepairStage {
  intakeAccepted,
  aiDiagnosisCompleted,
  partsAwaitingApproval,
  repairInProcess,
  qcPassed,
  readyForPickup,
}

enum ChatMessageSender {
  customer,
  aiBot,
  humanTechnician,
}

/// Customer-Facing Chat Conversation Log Model
class CustomerChatMessage {
  final String messageId;
  final ChatMessageSender sender;
  final String text;
  final DateTime timestamp;

  CustomerChatMessage({
    required this.messageId,
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

/// Privacy-Protected Customer Portal Data Model
class CustomerPortalTicket {
  final String ticketId;
  final String customerName;
  final String customerPhone;
  final String deviceModel;
  final String serialOrIMEI;
  RepairStage currentStage;
  
  // Hidden Internal Values (For POS/Admin Only)
  final double internalPartCost;
  final double internalLaborCharge;
  
  // Customer-Facing Total Fee (Aggregated to hide profit margin)
  final double totalEstimatedRepairFeeMMK;
  final String aiGeneratedExplanation;
  final List<CustomerChatMessage> chatHistory;
  bool isEstimateApprovedByCustomer;

  CustomerPortalTicket({
    required this.ticketId,
    required this.customerName,
    required this.customerPhone,
    required this.deviceModel,
    required this.serialOrIMEI,
    required this.currentStage,
    required this.internalPartCost,
    required this.internalLaborCharge,
    required this.totalEstimatedRepairFeeMMK,
    required this.aiGeneratedExplanation,
    required this.chatHistory,
    this.isEstimateApprovedByCustomer = false,
  });
}
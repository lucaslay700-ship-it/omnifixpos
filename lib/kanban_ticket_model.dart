enum TicketStage { intake, diagnosing, waitingParts, repairing, testing, ready }

class KanbanTicket {
  final String id;
  final String customerName;
  final String phoneModel;
  final String issueDescription;
  TicketStage stage;
  final DateTime slaDeadline;
  final String assignedTechnician;

  KanbanTicket({
    required this.id,
    required this.customerName,
    required this.phoneModel,
    required this.issueDescription,
    required this.stage,
    required this.slaDeadline,
    required this.assignedTechnician,
  });
}
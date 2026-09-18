import 'dart:async';
import 'package:flutter/material.dart';
import 'kanban_ticket_model.dart'; // Model ဖိုင်ကို Import လုပ်ထားပါ

class KanbanPipelineScreen extends StatefulWidget {
  const KanbanPipelineScreen({super.key});

  @override
  State<KanbanPipelineScreen> createState() => _KanbanPipelineScreenState();
}

class _KanbanPipelineScreenState extends State<KanbanPipelineScreen> {
  late Timer _slaTimer;

  // 1. 'final' ကိုဖြုတ်ပြီး List ကို ပြင်/ဖျက်/ထည့် ပြုလုပ်နိုင်အောင် Dynamic ပြောင်းထားသည်
  final List<KanbanTicket> _tickets = [
    KanbanTicket(
      id: "TK-101",
      customerName: "",
      phoneModel: "iPhone 13 Pro",
      issueDescription: "Display Replacement",
      stage: TicketStage.intake,
      slaDeadline: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      assignedTechnician: "",
    ),
    KanbanTicket(
      id: "TK-102",
      customerName: "",
      phoneModel: "Samsung S22 Ultra",
      issueDescription: "Charging IC Repair",
      stage: TicketStage.diagnosing,
      slaDeadline: DateTime.now().add(const Duration(minutes: 15)),
      assignedTechnician: "",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // SLA မီမမီ စက္ကန့်တိုင်း စစ်ပေးသည့် Timer
    _slaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slaTimer.cancel();
    super.dispose();
  }

  // ==========================================
  //  CRUD Functions (ထည့်/ပြင်/ဖျက် Logic များ)
  // ==========================================

  // [CREATE] Ticket အသစ်ထည့်ရန်
  void _addTicket(KanbanTicket newTicket) {
    setState(() {
      _tickets.add(newTicket);
    });
  }

  // [UPDATE] Ticket အချက်အလက် ပြင်ရန်
  void _updateTicket(int index, KanbanTicket updatedTicket) {
    setState(() {
      _tickets[index] = updatedTicket;
    });
  }

  // [DELETE] Ticket ဖျက်ရန်
  void _deleteTicket(String id) {
    setState(() {
      _tickets.removeWhere((ticket) => ticket.id == id);
    });
  }

  // [AI FEATURE] Smart SLA & AI Technician Auto-Assigner
  void _runAiSmartAssign(KanbanTicket ticket, int index) {
    // AI မှ ပျက်စီးမှု အမျိုးအစားပေါ်မူတည်၍ တာဝန်ယူရမည့် ဆရာကို ခွဲဝေပေးခြင်း
    String recommendedTech = "Aung Ko";
    if (ticket.issueDescription.toLowerCase().contains("ic") || 
        ticket.issueDescription.toLowerCase().contains("board")) {
      recommendedTech = "Kyaw Kyaw (Motherboard Specialist)";
    }

    setState(() {
      _tickets[index] = KanbanTicket(
        id: ticket.id,
        customerName: ticket.customerName,
        phoneModel: ticket.phoneModel,
        issueDescription: ticket.issueDescription,
        stage: ticket.stage,
        slaDeadline: ticket.slaDeadline,
        assignedTechnician: recommendedTech,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("AI: Assigned to $recommendedTech")),
    );
  }

  // ==========================================
  //  UI Dialogs (Ticket အသစ်ထည့်ရန်/ပြင်ရန် Form)
  // ==========================================

  void _showTicketDialog({KanbanTicket? ticket, int? index}) {
    final isEditing = ticket != null;
    final nameController = TextEditingController(text: ticket?.customerName ?? '');
    final modelController = TextEditingController(text: ticket?.phoneModel ?? '');
    final issueController = TextEditingController(text: ticket?.issueDescription ?? '');
    final techController = TextEditingController(text: ticket?.assignedTechnician ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit Ticket (ပြင်ရန်)" : "Add New Ticket (အသစ်ထည့်ရန်)"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Customer Name")),TextField(controller: modelController, decoration: const InputDecoration(labelText: "Phone Model")),
                TextField(controller: issueController, decoration: const InputDecoration(labelText: "Issue Description")),
                TextField(controller: techController, decoration: const InputDecoration(labelText: "Technician")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newOrUpdated = KanbanTicket(
                  id: isEditing ? ticket.id : "TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                  customerName: nameController.text,
                  phoneModel: modelController.text,
                  issueDescription: issueController.text,
                  stage: isEditing ? ticket.stage : TicketStage.intake,
                  slaDeadline: isEditing ? ticket.slaDeadline : DateTime.now().add(const Duration(hours: 2)),
                  assignedTechnician: techController.text,
                );

                if (isEditing && index != null) {
                  _updateTicket(index, newOrUpdated);
                } else {
                  _addTicket(newOrUpdated);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kanban Repair Pipeline"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _showTicketDialog(),
            tooltip: "Add Ticket",
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("${ticket.id} - ${ticket.customerName} (${ticket.phoneModel})"),
              subtitle: Text("Issue: ${ticket.issueDescription}\nTech: ${ticket.assignedTechnician}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI Smart Assign Button
                  IconButton(
                    icon: const Icon(Icons.psychology, color: Colors.purple),
                    onPressed: () => _runAiSmartAssign(ticket, index),
                    tooltip: "AI Auto-Assign",
                  ),
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showTicketDialog(ticket: ticket, index: index),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTicket(ticket.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTicketDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
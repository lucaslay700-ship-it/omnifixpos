import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'service_item.dart';

class CreateTicketModal extends StatefulWidget {
  final String tenantId;
  final VoidCallback onTicketCreated;

  const CreateTicketModal({
    super.key,
    required this.tenantId,
    required this.onTicketCreated,
  });

  @override
  State<CreateTicketModal> createState() => _CreateTicketModalState();
}

class _CreateTicketModalState extends State<CreateTicketModal> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _phoneModelController = TextEditingController();
  final _issueController = TextEditingController();
  final _costController = TextEditingController();

  Future<void> _saveTicket() async {
    if (_formKey.currentState!.validate()) {
      var serviceItem = ServiceItem(
        id: const Uuid().v4(),
        tenantId: widget.tenantId,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        phoneModel: _phoneModelController.text.trim(),
        issueDescription: _issueController.text.trim(),
        estimatedCost: double.tryParse(_costController.text.trim()) ?? 0.0,
        status: 'Pending',
        createdAt: DateTime.now(),
      );
      final newTicket = serviceItem;

      // Isolated Hive Box သို့ သိမ်းဆည်းခြင်း
      await DatabaseHelper().saveServiceItem(widget.tenantId, newTicket);
      
      widget.onTicketCreated();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Repair Ticket',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter customer name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Customer Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneModelController,
                decoration: const InputDecoration(
                  labelText: 'Phone Model (e.g., iPhone 13 Pro)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.smartphone),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter phone model' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issueController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Issue Description (e.g., Display Replace)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter issue details' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Cost',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter estimated cost' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTicket,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Ticket', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
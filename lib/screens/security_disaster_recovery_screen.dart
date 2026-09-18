import 'package:flutter/material.dart';

class SecurityDisasterRecoveryScreen extends StatelessWidget {
  const SecurityDisasterRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security & Disaster Recovery"),
        backgroundColor: Colors.redAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Card(
              color: Color(0xFF1E2430),
              child: ListTile(
                leading: Icon(Icons.shield, color: Colors.greenAccent),
                title: Text("Database Backup Status: Healthy", style: TextStyle(color: Colors.white)),
                subtitle: Text("Automated Cloud Backup Enabled", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Manual Disaster Recovery Backup Started...")),
                );
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Trigger Manual Backup"),
            ),
          ],
        ),
      ),
    );
  }
}

class CrossAlignment {
  static late CrossAxisAlignment start;
}
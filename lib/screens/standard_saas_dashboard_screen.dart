import 'package:flutter/material.dart';

class StandardSaaSDashboardScreen extends StatelessWidget {
  final String shopUuid;
  final String shopName;

  const StandardSaaSDashboardScreen({
    Key? key,
    required this.shopUuid,
    required this.shopName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("$shopName - POS & AI Diagnostics"),
        backgroundColor: const Color(0xFF2D2D3F),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 64, color: Colors.cyanAccent),
            const SizedBox(height: 16),
            Text("Welcome to $shopName",
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              "Standard Tenant View (AI Diagnostics & Service Intake Only)",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
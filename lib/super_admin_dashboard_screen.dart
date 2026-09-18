import 'package:flutter/material.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final String shopUuid;
  final String shopName;

  const SuperAdminDashboardScreen({
    Key? key,
    required this.shopUuid,
    required this.shopName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181824),
      appBar: AppBar(
        title: const Text("SUPER ADMIN ENGINE (Developer Control)"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Chip(
            label: const Text("GALAXY GATE OWNER",
                style: TextStyle(color: Colors.white, fontSize: 10)),
            backgroundColor: Colors.amber.shade900,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SHOP CREDENTIAL BANNER
            Card(
              color: const Color(0xFF232334),
              child: ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.amber),
                title: Text(shopName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("UUID: $shopUuid\nLocation: Thayet | Phone: 09977223316",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 20),

            const Text("DEVELOPER SUPER CONTROLS",
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),

            // SUPER ADMIN CONTROL TILES
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAdminTile(
                  icon: Icons.store_mall_directory,
                  title: "All Tenant Shops",
                  subtitle: "Manage SaaS Subscriptions",
                  color: Colors.blueAccent,
                  onTap: () {},
                ),
                _buildAdminTile(
                  icon: Icons.vpn_key_outlined,
                  title: "License Key Generator",
                  subtitle: "Issue Offline/Cloud Keys",
                  color: Colors.purpleAccent,
                  onTap: () {},
                ),
                _buildAdminTile(
                  icon: Icons.psychology_outlined,
                  title: "Global AI Diagnostic Logs",
                  subtitle: "View All Fault & Hardware Data",
                  color: Colors.tealAccent,
                  onTap: () {},
                ),
                _buildAdminTile(
                  icon: Icons.security,
                  title: "Security & Anti-Bypass",
                  subtitle: "App Lock & Hardware ID Blacklist",
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF232334),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
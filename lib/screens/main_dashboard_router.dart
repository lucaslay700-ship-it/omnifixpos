// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import '../super_admin_dashboard_screen.dart' show SuperAdminDashboardScreen;
import 'super_admin_dashboard_screen.dart';
import 'standard_saas_dashboard_screen.dart';

bool _isSuperAdmin({required String shopUuid, required String phone}) {
  return shopUuid == 'GALAXY-GATE-MOBILE-THAYET-09799223316' &&
      phone == '09799223316';
}

class MainDashboardRouter extends StatelessWidget {
  final String currentShopUuid; // e.g., "GALAXY-GATE-MOBILE-THAYET-09977223316"
  final String currentOwnerPhone; // e.g., "09977223316"
  final String shopName;

  const MainDashboardRouter({
    Key? key,
    required this.currentShopUuid,
    required this.currentOwnerPhone,
    required this.shopName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check Super Admin Privilege
    final bool isDeveloperOwner = _isSuperAdmin(
      shopUuid: currentShopUuid,
      phone: currentOwnerPhone,
    );

    // If Developer / Main Owner -> Load Super Admin Dashboard
    // Otherwise -> Load Standard SaaS App Dashboard (Standard Tenant View)
    if (isDeveloperOwner) {
      return SuperAdminDashboardScreen(
        shopUuid: currentShopUuid,
        shopName: shopName,
      );
    } else {
      return StandardSaaSDashboardScreen(
        shopUuid: currentShopUuid,
        shopName: shopName,
      );
    }
  }

}
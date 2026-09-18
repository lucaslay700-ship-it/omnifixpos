class AuthRoleService {
  // Main Developer / Super Owner Context
  static const String developerShopUuid = "GALAXY-GATE-MOBILE-THAYET-09977223316";
  static const String developerPhone = "09977223316";

  // Check if current logged-in user/shop is Super Admin (Developer Owner)
  static bool isSuperAdmin({required String shopUuid, String? phone}) {
    return shopUuid == developerShopUuid || phone == developerPhone;
  }
}
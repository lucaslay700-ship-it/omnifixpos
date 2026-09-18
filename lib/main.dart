import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ----------------------------------------------------
// 1. SERVICES IMPORTS
// ----------------------------------------------------
import 'ewaste-valuation_screen.dart';
import 'services/auth_role_service.dart';
import 'services/firebase_core_service.dart';
import 'services/multi_tenant_ai_backend_service.dart';
import 'services/customer_service.dart';
import 'services/external_payment_gateway_service.dart';
import 'services/license_pay_after_profit_service.dart';
import 'digital_warranty_customer_portal_service.dart';

// ----------------------------------------------------
// 2. MODELS IMPORTS
// ----------------------------------------------------
import 'models/branch_sync_model.dart';
import 'models/shop_profile_model.dart';
import 'models/shop_profile.dart';
import 'auto_parts_model.dart';
import 'borneo_schematic_model.dart';
import 'branch_inventory_model.dart';
import 'ceir_tax_model.dart';
import 'create_ticket_model.dart';
import 'customer_portal_model.dart';
import 'ewaste_valuation_model.dart';
import 'kanban_ticket_model.dart';
import 'pos_billing_model.dart';
import 'qc_warranty_model.dart';

// ----------------------------------------------------
// 3. SCREENS IMPORTS (Fixing All Import Paths)
// ----------------------------------------------------
import 'screens/main_dashboard_router.dart';
import 'screens/super_admin_dashboard_screen.dart';
import 'screens/standard_saas_dashboard_screen.dart';
import 'screens/shop_profile_screen.dart';
import 'screens/security_disaster_recovery_screen.dart';

import 'ai_diagnostics_screen.dart';
import 'ai_qc_warranty_screen.dart';
import 'auto_parts_allocation_screen.dart';
import 'borneo_ai_diagnostic_screen.dart';
import 'branch_inventory_screen.dart';
import 'ceir_radar_screen.dart';
import 'customer_portal_screen.dart';
import 'dashboard_screen.dart';
import 'ewaste_valuation_screen.dart'; // Fixed: package: prefix ဖယ်ရှားထားပါသည်
import 'inspection_canvas_screen.dart';
import 'kanban_pipeline_screen.dart';
import 'onboarding_screen.dart';
import 'repair_intake_screen.dart';
import 'repair_intake_vouncher_screen.dart';
import 'smart_pos_billing_screen.dart';
import 'super_admin_dashboard_screen.dart';
import 'technician_matching_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const OmniFixPOSApp());
}

class OmniFixPOSApp extends StatefulWidget {
  const OmniFixPOSApp({Key? key}) : super(key: key);

  @override
  State<OmniFixPOSApp> createState() => _OmniFixPOSAppState();
}

class _OmniFixPOSAppState extends State<OmniFixPOSApp> {
  bool _isInitializing = true;
  bool _isAuthenticated = false; 
  bool _isHumanVerified = false; 

  String _initializationStatus = "OmniFix SaaS Engine စတင်နေပါသည်...";

  String _activeShopUuid = "";
  String _activeOwnerPhone = "";
  String _activeShopName = "";

  Stream<Object?>? stream;

  get MultiTenantAiBackendService => null;

 @override
  void initState() {
    super.initState();
    _initializeSaaSKernel();
  }

  Future<void> _initializeSaaSKernel() async {
    try {
      setState(() => _initializationStatus = "Firebase & Security Kernel စစ်ဆေးနေပါသည်...");
      await FirebaseCoreService.initialize();

      setState(() => _initializationStatus = "Multi-Tenant AI Backend Sync ပြုလုပ်နေပါသည်...");
      await MultiTenantAiBackendService.initAIModel();

      setState(() {
        _isAuthenticated = false;
        _isHumanVerified = false;
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint("Initialization Warning: $e");
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _onOwnerVerified(String shopUuid, String phone, String shopName) {
    setState(() {
      _activeShopUuid = shopUuid;
      _activeOwnerPhone = phone;
      _activeShopName = shopName;
      _isHumanVerified = true;
      _isAuthenticated = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniFix POS - AI Mobile Repair & SaaS Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF12121D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          elevation: 0,
        ),
        useMaterial3: true,
      ),

      home: _isInitializing
          ? _buildSplashScreen()
          : (!_isAuthenticated || !_isHumanVerified)
              ? AccessVerificationGate(
                  onVerified: _onOwnerVerified,
                )
              : MainDashboardRouter(
                  currentShopUuid: _activeShopUuid,
                  currentOwnerPhone: _activeOwnerPhone,
                  shopName: _activeShopName,
                ),

      routes: {
        '/dashboard': (context) => MainDashboardRouter(
              currentShopUuid: _activeShopUuid,
              currentOwnerPhone: _activeOwnerPhone,
              shopName: _activeShopName,
            ),
        '/super_admin': (context) => SuperAdminDashboardScreen(
              shopUuid: _activeShopUuid,
              shopName: _activeShopName,
            ),
        '/standard_saas': (context) => StandardSaaSDashboardScreen(
              shopUuid: _activeShopUuid,
              shopName: _activeShopName,
            ),
        '/tech_matching': (context) => const TechnicianMatchingScreen(),
        '/ai_diagnostics': (context) => const AIDiagnosticsScreen(),
        '/ai_qc_warranty': (context) => const AIQcWarrantyScreen() as Widget,
        '/auto_parts': (context) => const AutoPartsAllocationScreen(),
        '/borneo_ai': (context) => const BorneoAIDiagnosticScreen(),
        '/branch_inventory': (context) => const BranchInventoryScreen(),
        '/ceir_radar': (context) => const CeirRadarScreen(),
        '/customer_portal': (context) => const CustomerPortalScreen(),
        '/pos_billing': (context) => const SmartPOSBillingScreen(),
        '/repair_voucher': (context) => const RepairIntakeVoucherScreen(),
        '/ewaste_valuation': (context) => const EWasteValuationScreen(),
        '/inspection_canvas': (context) => StreamBuilder(
          stream: stream,
          builder: (context, asyncSnapshot) {
            // ignore: avoid_unnecessary_containers
            return Container(
              child: InspectionCanvasScreen(
                onSaveInspection: (inspection) {},
              ),
            );
          }
        ),
        '/kanban_pipeline': (context) => const KanbanPipelineScreen(),
        '/shop_profile': (context) => const ShopProfileScreen(),
        '/security_disaster': (context) => const SecurityDisasterRecoveryScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.2),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 64,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
            const SizedBox(height: 16),
            Text(
              _initializationStatus,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class AIQcWarrantyScreen {
  const AIQcWarrantyScreen();
}

class AccessVerificationGate extends StatefulWidget {
  final Function(String shopUuid, String phone, String shopName) onVerified;

  const AccessVerificationGate({Key? key, required this.onVerified})
      : super(key: key);

  @override
  State<AccessVerificationGate> createState() => _AccessVerificationGateState();
}class _AccessVerificationGateState extends State<AccessVerificationGate> {
  final _phoneController = TextEditingController();
  final _captchaAnswerController = TextEditingController();

  bool _isNotRobot = false;
  int _num1 = 4;
  int _num2 = 6;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final now = DateTime.now();
    setState(() {
      _num1 = (now.second % 8) + 2;
      _num2 = (now.millisecond % 7) + 1;
      _captchaAnswerController.clear();
      _errorMessage = "";
    });
  }

  void _verifyAndProceed() {
    final phone = _phoneController.text.trim();
    final expectedSum = _num1 + _num2;
    final userSum = int.tryParse(_captchaAnswerController.text.trim());

    if (phone.isEmpty) {
      setState(() => _errorMessage = "ဆိုင်ရှင် ဖုန်းနံပါတ် သို့မဟုတ် UUID ထည့်သွင်းပါ");
      return;
    }

    if (!_isNotRobot) {
      setState(() => _errorMessage = "Robot မဟုတ်ကြောင်း Checkbox ကို အမှန်ခြစ်ပေးပါ");
      return;
    }

    if (userSum != expectedSum) {
      setState(() => _errorMessage = "Human Check ဂဏန်းပေါင်းလဒ် မှားယွင်းနေပါသည်။ ပြန်လည်ကြိုးစားပါ");
      _generateCaptcha();
      return;
    }

    String shopName = "Galaxy Gate Mobile";
    String shopUuid = "GALAXY-GATE-MOBILE-THAYET-09799223316";

    widget.onVerified(shopUuid, phone, shopName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF181824),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade400, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 56,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Owner Access Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Auto-login ပိတ်ထားပါသည်။ ဆိုင်ရှင် အထောက်အထားနှင့် Human Check စစ်ဆေးပါမည်။",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Owner Phone / Shop UUID",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.phone_android, color: Colors.cyanAccent),
                    filled: true,
                    fillColor: const Color(0xFF222232),border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222232),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isNotRobot,
                        activeColor: Colors.cyanAccent,
                        checkColor: Colors.black,
                        onChanged: (val) {
                          setState(() => _isNotRobot = val ?? false);
                        },
                      ),
                      const Text(
                        "I am human (Robot မဟုတ်ပါ)",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$_num1 + $_num2 = ?",
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _captchaAnswerController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "အဖြေရိုက်ပါ",
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFF222232),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _verifyAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "VERIFY & ACCESS POS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';

// ==========================================
// 1. CURRENT LOGGED-IN SHOP PROFILE MODEL & SERVICE
// ==========================================

class LoggedInShopProfile {
  final String shopId;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String domainUrl; // e.g. "https://my-shop.omnifixpos.com"

  LoggedInShopProfile({
    required this.shopId,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.domainUrl,
  });
}

class ShopProfileService {
  // Login ဝင်ထားသော ဆိုင်ရှင်၏ Session Profile ကို ယူဆောင်ပေးသည့် Service
  static LoggedInShopProfile getCurrentShop() {
    // Session / Auth State မှ Dynamic ယူမည့် Data (Default Fallback ပါဝင်သည်)
    return LoggedInShopProfile(
      shopId: "SHOP_DYNAMIC_001",
      shopName: "DYNAMIC SHOP NAME", // Dynamic Loaded Name
      shopAddress: "Main Street, Yangon",
      shopPhone: "09987654321",
      domainUrl: "https://track.omnifixpos.com", // Dynamic Shop Domain URL
    );
  }
}

// ==========================================
// 2. OFFLINE / ONLINE SYNC & PRINTER ENGINES
// ==========================================

enum PrintConnectionType { bluetooth, usb, network }

class OfflineSyncEngine {
  static bool isOnline = true;
  static final List<Map<String, dynamic>> _offlinePrintQueue = [];

  static Future<void> queueOrSyncVoucher(Map<String, dynamic> voucherData) async {
    if (isOnline) {
      debugPrint("Cloud Syncing Voucher for ${voucherData['shopName']}: ${voucherData['ticketId']}");
    } else {
      _offlinePrintQueue.add(voucherData);
      debugPrint("Stored Offline. Queue Size: ${_offlinePrintQueue.length}");
    }
  }
}

class ESCPOSPrinterService {
  static Future<bool> printThermalVoucher({
    required LoggedInShopProfile shop,
    required String ticketId,
    required String customerName,
    required String phone,
    required String device,
    required String imei,
    required String issue,
    required double estimatedCost,
    required double advance,
    required String trackingUrl,
    PrintConnectionType connectionType = PrintConnectionType.bluetooth,
  }) async {
    try {
      debugPrint("==========================================");
      debugPrint(">>> ESC/POS THERMAL PRINT COMMAND <<<");
      debugPrint("SHOP     : ${shop.shopName}");
      debugPrint("ADDRESS  : ${shop.shopAddress}");
      debugPrint("PHONE    : ${shop.shopPhone}");
      debugPrint("------------------------------------------");
      debugPrint("Ticket ID : $ticketId");
      debugPrint("Customer  : $customerName ($phone)");
      debugPrint("Device    : $device | IMEI: $imei");
      debugPrint("Issue     : $issue");
      debugPrint("------------------------------------------");
      debugPrint("Est. Cost : ${estimatedCost.toStringAsFixed(0)} MMK");
      debugPrint("Advance   : ${advance.toStringAsFixed(0)} MMK");
      debugPrint("Balance   : ${(estimatedCost - advance).toStringAsFixed(0)} MMK");
      debugPrint("------------------------------------------");
      debugPrint("QR TRACK LINK : $trackingUrl");
      debugPrint("==========================================");
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==========================================
// 3. MAIN REPAIR INTAKE VOUCHER SCREEN
// ==========================================

class RepairIntakeVoucherScreen extends StatefulWidget {
  final String ticketId;
  final String customerName;
  final String customerPhone;
  final String deviceModel;
  final String imeiNumber;
  final String faultDescription;
  final double estimatedCostMMK;
  final double advancePaymentMMK;

  const RepairIntakeVoucherScreen({
    super.key,this.ticketId = "TCK-9924-2026",
    this.customerName = "U Ba",
    this.customerPhone = "09123456789",
    this.deviceModel = "iPhone 13 Pro",
    this.imeiNumber = "354920110293845",
    this.faultDescription = "Display Replacement & Battery Check",
    this.estimatedCostMMK = 185000.0,
    this.advancePaymentMMK = 50000.0,
  });

  @override
  State<RepairIntakeVoucherScreen> createState() => _RepairIntakeVoucherScreenState();
}

class _RepairIntakeVoucherScreenState extends State<RepairIntakeVoucherScreen> {
  late LoggedInShopProfile _activeShopProfile;

  late String _customerName;
  late String _customerPhone;
  late String _deviceModel;
  late String _imeiNumber;
  late String _faultDescription;
  late double _estimatedCostMMK;
  late double _advancePaymentMMK;

  bool _isPrinting = false;
  PrintConnectionType _selectedConnectionType = PrintConnectionType.bluetooth;

  @override
  void initState() {
    super.initState();
    // 1. Fetch Logged-in Shop Owner Info Dynamically
    _activeShopProfile = ShopProfileService.getCurrentShop();

    _customerName = widget.customerName;
    _customerPhone = widget.customerPhone;
    _deviceModel = widget.deviceModel;
    _imeiNumber = widget.imeiNumber;
    _faultDescription = widget.faultDescription;
    _estimatedCostMMK = widget.estimatedCostMMK;
    _advancePaymentMMK = widget.advancePaymentMMK;
  }

  double get _remainingBalance => _estimatedCostMMK - _advancePaymentMMK;

  // Login ဝင်ထားသော ဆိုင်၏ URL + Ticket ID ပေါင်းစပ်ထားသော Dynamic URL String
  String get _dynamicTrackingUrl =>
      "${_activeShopProfile.domainUrl}/track?shop=${_activeShopProfile.shopId}&ticket=${widget.ticketId}";

  // ==========================================
  // PRINT EXECUTION WITH DYNAMIC SHOP DATA
  // ==========================================
  Future<void> _handleExecutePrint() async {
    setState(() => _isPrinting = true);

    final voucherMap = {
      'shopId': _activeShopProfile.shopId,
      'shopName': _activeShopProfile.shopName,
      'ticketId': widget.ticketId,
      'customerName': _customerName,
      'customerPhone': _customerPhone,
      'deviceModel': _deviceModel,
      'imeiNumber': _imeiNumber,
      'faultDescription': _faultDescription,
      'estimatedCostMMK': _estimatedCostMMK,
      'advancePaymentMMK': _advancePaymentMMK,
      'trackingUrl': _dynamicTrackingUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await OfflineSyncEngine.queueOrSyncVoucher(voucherMap);

    bool isSuccess = await ESCPOSPrinterService.printThermalVoucher(
      shop: _activeShopProfile,
      ticketId: widget.ticketId,
      customerName: _customerName,
      phone: _customerPhone,
      device: _deviceModel,
      imei: _imeiNumber,
      issue: _faultDescription,
      estimatedCost: _estimatedCostMMK,
      advance: _advancePaymentMMK,
      trackingUrl: _dynamicTrackingUrl,
      connectionType: _selectedConnectionType,
    );

    setState(() => _isPrinting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuccess
                ? "Printed for ${_activeShopProfile.shopName} successfully!"
                : "Print Failed! Queued in local memory.",
          ),
          backgroundColor: isSuccess ? Colors.teal : Colors.orange,
        ),
      );
    }
  }

  // ==========================================
  // EDIT VOUCHER & SHOP INFO DIALOG
  // ==========================================
  void _showCrudEditDialog() {
    final shopNameCtrl = TextEditingController(text: _activeShopProfile.shopName);
    final shopAddrCtrl = TextEditingController(text: _activeShopProfile.shopAddress);
    final nameCtrl = TextEditingController(text: _customerName);
    final phoneCtrl = TextEditingController(text: _customerPhone);final modelCtrl = TextEditingController(text: _deviceModel);
    final imeiCtrl = TextEditingController(text: _imeiNumber);
    final faultCtrl = TextEditingController(text: _faultDescription);
    final costCtrl = TextEditingController(text: _estimatedCostMMK.toStringAsFixed(0));
    final advanceCtrl = TextEditingController(text: _advancePaymentMMK.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Shop Profile & Voucher (CRUD)"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Shop Info (Logged-in Dynamic Data)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              TextField(controller: shopNameCtrl, decoration: const InputDecoration(labelText: "Shop Name")),
              TextField(controller: shopAddrCtrl, decoration: const InputDecoration(labelText: "Shop Address")),
              const Divider(height: 20),
              const Text("Customer Voucher Info", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Customer Name")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: "Device Model")),
              TextField(controller: imeiCtrl, decoration: const InputDecoration(labelText: "IMEI")),
              TextField(controller: faultCtrl, decoration: const InputDecoration(labelText: "Issue")),
              TextField(controller: costCtrl, decoration: const InputDecoration(labelText: "Est. Cost (MMK)"), keyboardType: TextInputType.number),
              TextField(controller: advanceCtrl, decoration: const InputDecoration(labelText: "Advance Deposit (MMK)"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _customerName = "DELETED";
                _deviceModel = "N/A";
                _estimatedCostMMK = 0;
                _advancePaymentMMK = 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Clear Data", style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _activeShopProfile = LoggedInShopProfile(
                  shopId: _activeShopProfile.shopId,
                  shopName: shopNameCtrl.text,
                  shopAddress: shopAddrCtrl.text,
                  shopPhone: _activeShopProfile.shopPhone,
                  domainUrl: _activeShopProfile.domainUrl,
                );
                _customerName = nameCtrl.text;
                _customerPhone = phoneCtrl.text;
                _deviceModel = modelCtrl.text;
                _imeiNumber = imeiCtrl.text;
                _faultDescription = faultCtrl.text;
                _estimatedCostMMK = double.tryParse(costCtrl.text) ?? 0;
                _advancePaymentMMK = double.tryParse(advanceCtrl.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voucher Engine - ${_activeShopProfile.shopName}"),
        backgroundColor: Colors.teal.shade900,
        foregroundColor: Colors.white,
        actions: [Row(
            children: [
              Text(
                OfflineSyncEngine.isOnline ? "ONLINE" : "OFFLINE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: OfflineSyncEngine.isOnline ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              Switch(
                value: OfflineSyncEngine.isOnline,
                activeColor: Colors.greenAccent,
                onChanged: (val) {
                  setState(() {
                    OfflineSyncEngine.isOnline = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Connection Type Dropdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Printer Connection:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<PrintConnectionType>(
                        value: _selectedConnectionType,
                        items: PrintConnectionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedConnectionType = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Printable Thermal Voucher Paper Layout
              Container(
                width: 380, // Standard 80mm Thermal Printer Target
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Logged-in Shop Header Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _activeShopProfile.shopName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _activeShopProfile.shopAddress,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Ph: ${_activeShopProfile.shopPhone}",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1.5, height: 20),Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "REPAIR INTAKE VOUCHER",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.teal, size: 20),
                          onPressed: _showCrudEditDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    _buildVoucherRow("Ticket ID:", widget.ticketId),
                    _buildVoucherRow("Customer:", _customerName),
                    _buildVoucherRow("Phone:", _customerPhone),
                    _buildVoucherRow("Device:", _deviceModel),
                    _buildVoucherRow("IMEI/SN:", _imeiNumber),
                    _buildVoucherRow("Issue:", _faultDescription),

                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Est. Cost:"),
                        Text("${_estimatedCostMMK.toStringAsFixed(0)} MMK", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Advance Deposit:"),
                        Text("${_advancePaymentMMK.toStringAsFixed(0)} MMK"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Remaining Balance:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "${_remainingBalance.toStringAsFixed(0)} MMK",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dynamic QR Tracking Section (Embedded Shop URL)
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.qr_code_2, size: 70, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            _dynamicTrackingUrl,
                            style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Execute Print Button
              SizedBox(
                width: 380,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isPrinting
                      ? const SizedBox(width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  label: Text(_isPrinting ? "Printing..." : "Print Thermal Voucher"),
                  onPressed: _isPrinting ? null : _handleExecutePrint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
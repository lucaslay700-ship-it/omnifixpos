import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class ShopProfile {
  final String tenantId;
  final String shopName;
  final String phone;
  final String address;
  final String currencySymbol;
  final DateTime registeredAt;

  const ShopProfile({
    required this.tenantId,
    required this.shopName,
    required this.phone,
    required this.address,
    required this.currencySymbol,
    required this.registeredAt,
  });
}

class OnboardingScreen extends StatefulWidget {
  final Function(String tenantId) onSetupComplete;
  const OnboardingScreen({super.key, required this.onSetupComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCurrency = 'MMK';

  Future<void> _saveTenantSetup() async {
    if (_formKey.currentState!.validate()) {
      // Automatic Multi-Tenant Unique Identifier Generation
      final String generatedTenantId = const Uuid().v4();

      final newProfile = ShopProfile(
        tenantId: generatedTenantId,
        shopName: _shopNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        currencySymbol: _selectedCurrency,
        registeredAt: DateTime.now(),
      );

      // Hive Storage ထဲသို့ Dynamic Tenant Data သိမ်းဆည်းခြင်း
      await DatabaseHelper().saveShopProfile(newProfile);

      // Setup ပြီးသွားကြောင်း Tenant ID နှင့်အတူ Main သို့ အကြောင်းကြားခြင်း
      widget.onSetupComplete(generatedTenantId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniFix POS - Shop Setup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Welcome to OmniFix POS Engine',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure your independent repair shop workspace.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter shop name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Shop Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter shop address' : null,),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency Symbol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                items: const [
                  DropdownMenuItem(value: 'MMK', child: Text('MMK (K)')),
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  DropdownMenuItem(value: 'THB', child: Text('THB (฿)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTenantSetup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Complete Setup & Start', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

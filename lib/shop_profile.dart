import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController _shopNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _sloganController;

  late Box _shopBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHiveAndLoadData();
  }

  // Hive Box ကို ဖွင့်ပြီး Data များ ဆွဲယူခြင်း
  Future<void> _initHiveAndLoadData() async {
    _shopBox = await Hive.openBox('shop_profile_box');
    
    _shopNameController = TextEditingController(
      text: _shopBox.get('shop_name', defaultValue: 'Galaxy Gate Mobile'),
    );
    _phoneController = TextEditingController(
      text: _shopBox.get('shop_phone', defaultValue: '09-123456789'),
    );
    _addressController = TextEditingController(
      text: _shopBox.get('shop_address', defaultValue: 'Yangon, Myanmar'),
    );
    _sloganController = TextEditingController(
      text: _shopBox.get('shop_slogan', defaultValue: 'Your Trusted Mobile Service & Partner'),
    );

    setState(() {
      _isLoading = false;
    });
  }

  // Data များကို Hive Box ထဲသို့ သိမ်းဆည်းခြင်း
  Future<void> _saveShopProfile() async {
    if (_formKey.currentState!.validate()) {
      await _shopBox.put('shop_name', _shopNameController.text.trim());
      await _shopBox.put('shop_phone', _phoneController.text.trim());
      await _shopBox.put('shop_address', _addressController.text.trim());
      await _shopBox.put('shop_slogan', _sloganController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop Profile Updated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile Settings'),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Logo or Icon Header
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shop Name Input
                    TextFormField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Name',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {if (value == null || value.trim().isEmpty) {
                          return 'Please enter shop name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Input
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Slogan Input
                    TextFormField(
                      controller: _sloganController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Slogan / Tagline',
                        prefixIcon: Icon(Icons.subtitles),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Input
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Shop Address',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter shop address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _saveShopProfile,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}// TODO Implement this library.
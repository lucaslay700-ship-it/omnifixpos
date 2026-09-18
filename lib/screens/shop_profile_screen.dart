import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ignore: unused_import
import '../models/shop_profile_model.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  late Box<dynamic> _shopBox;

  @override
  void initState() {
    super.initState();
    _shopBox = Hive.box<dynamic>('shop_profile_box');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _shopBox.listenable(),
      builder: (context, Box<dynamic> box, _) {
        if (box.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("No Shop Profile Data Found.")),
          );
        }

        final profile = box.getAt(0)!;

        // 🚨 1. ရက် ၂၀ သက်တမ်းကုန်ပါက (သို့) Access ပိတ်ထားပါက တိုက်ရိုက် Lock မည်
        if (!profile.isLicenseActive) {
          return Scaffold(
            backgroundColor: Colors.red.shade900,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_clock_sharp, size: 90, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "TRIAL EXPIRED / ACCESS SUSPENDED",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "သင့်ဆိုင်၏ ရက်(၂၀) အစမ်းသုံးခွင့် သက်တမ်း ကုန်ဆုံးသွားပါပြီ။ စနစ်ကို ဆက်လက်အသုံးပြုရန် Software Developer ထံ ဆက်သွယ်၍ သက်တမ်းတိုးပါ။",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text("Shop ID: ${profile.tenantId}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        Text("Registered: ${profile.registeredAt.toString().split(' ')[0]}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 🟢 2. သက်တမ်းရှိသေးပါက ပြသပေးမည့် သန့်ရှင်းသော Client Shop Profile UI
        return Scaffold(
          appBar: AppBar(
            title: Text(profile.shopName),
            backgroundColor: Colors.teal.shade800,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Trial License Banner Indicator
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: profile.remainingTrialDays < 5 ? Colors.orange.shade50 : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: profile.remainingTrialDays < 5 ? Colors.orange : Colors.teal),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        profile.remainingTrialDays < 5 ? Icons.warning_amber : Icons.verified_user,color: profile.remainingTrialDays < 5 ? Colors.orange.shade800 : Colors.teal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "20-Day Trial Status: ACTIVE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: profile.remainingTrialDays < 5 ? Colors.orange.shade900 : Colors.teal.shade900,
                              ),
                            ),
                            Text(
                              "ကျန်ရှိသည့် သက်တမ်း: ${profile.remainingTrialDays} ရက်",
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Shop Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.storefront, size: 45, color: Colors.teal),
                        ),
                        const SizedBox(height: 12),
                        Text(profile.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Ph: ${profile.phone}", style: const TextStyle(color: Colors.grey)),
                        Text(profile.address, style: const TextStyle(color: Colors.grey)),
                        const Divider(height: 30),
                        _buildProfileTile(Icons.vpn_key, "Tenant ID", profile.tenantId),
                        _buildProfileTile(Icons.monetization_on, "Currency Symbol", profile.currencySymbol),
                        _buildProfileTile(Icons.event, "Registered Date", profile.registeredAt.toString().split(' ')[0]),
                        _buildProfileTile(
                          Icons.event_available,
                          "Trial Expiry Date",
                          profile.computedExpiryDate.toString().split(' ')[0],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      dense: true,
    );
  }
}
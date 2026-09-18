import 'package:hive_flutter/hive_flutter.dart';

// ==========================================
// 1. SHOP PROFILE MODEL (HIVE OBJECT)
// ==========================================

class ShopProfile extends HiveObject {
  String tenantId;
  String shopName;
  String phone;
  String address;
  String currencySymbol;
  String? logoPath;
  DateTime registeredAt;
  DateTime? expiryDate; // ရက် ၂၀ Trial သို့မဟုတ် SaaS Expiry Date
  bool isAccessGranted; // Super Admin Remote Lock Switch

  ShopProfile({
    required this.tenantId,
    required this.shopName,
    required this.phone,
    required this.address,
    this.currencySymbol = 'MMK',
    this.logoPath,
    required this.registeredAt,
    this.expiryDate,
    this.isAccessGranted = true,
  });

  // ရက် ၂၀ Free Trial Expiry Date တွက်ချက်ခြင်း Logic
  DateTime get computedExpiryDate {
    return expiryDate ?? registeredAt.add(const Duration(days: 20));
  }

  // System Access Valid ဖြစ်မဖြစ် စစ်ဆေးသည့် Logic
  bool get isLicenseActive {
    final now = DateTime.now();
    return isAccessGranted && now.isBefore(computedExpiryDate);
  }

  // ကျန်ရှိသည့် သက်တမ်း (Trial Days) တွက်ချက်ခြင်း
  int get remainingTrialDays {
    final now = DateTime.now();
    final expiry = computedExpiryDate;
    if (now.isAfter(expiry)) return 0;
    return expiry.difference(now).inDays;
  }

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'shopName': shopName,
        'phone': phone,
        'address': address,
        'currencySymbol': currencySymbol,
        'logoPath': logoPath,
        'registeredAt': registeredAt.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'isAccessGranted': isAccessGranted,
      };
}

// ==========================================
// 2. SHOP PROFILE MANUAL ADAPTER (TYPEID = 1)
// ==========================================

class ShopProfileAdapter extends TypeAdapter<ShopProfile> {
  @override
  final int typeId = 1;

  @override
  ShopProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ShopProfile(
      tenantId: fields[0] as String,
      shopName: fields[1] as String,
      phone: fields[2] as String,
      address: fields[3] as String,
      currencySymbol: fields[4] as String,
      logoPath: fields[5] as String?,
      registeredAt: fields[6] as DateTime,
      expiryDate: fields[7] as DateTime?,
      isAccessGranted: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, ShopProfile obj) {
    writer
      ..writeByte(9) // Field စုစုပေါင်း ၉ ခု
      ..writeByte(0)
      ..write(obj.tenantId)
      ..writeByte(1)
      ..write(obj.shopName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.currencySymbol)
      ..writeByte(5)
      ..write(obj.logoPath)
      ..writeByte(6)
      ..write(obj.registeredAt)
      ..writeByte(7)
      ..write(obj.expiryDate)
      ..writeByte(8)
      ..write(obj.isAccessGranted);
  }
}

// ==========================================
// 3. SHOP PROFILE SERVICE (LOCAL CRUD ENGINE)
// ==========================================

class ShopProfileService {
  static const String _boxName = 'shop_profile_box';
  static Box<ShopProfile>? _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShopProfileAdapter());
    }
    _box = await Hive.openBox<ShopProfile>(_boxName);
  }

  static Box<ShopProfile> get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception("ShopProfileService is not initialized. Call init() first.");
    }
    return _box!;
  }

  // CREATE / UPDATE SHOP PROFILE
  static Future<void> saveProfile(ShopProfile profile) async {
    await _getBox.put('current_shop', profile);
  }

  // READ SHOP PROFILE
  static ShopProfile? getProfile() {
    return _getBox.get('current_shop');
  }// EXTEND TRIAL / RENEW SUBSCRIPTION
  static Future<void> renewSubscription(int days) async {
    final current = getProfile();
    if (current != null) {
      DateTime baseDate = current.computedExpiryDate.isBefore(DateTime.now())
          ? DateTime.now()
          : current.computedExpiryDate;

      current.expiryDate = baseDate.add(Duration(days: days));
      current.isAccessGranted = true;
      await current.save();
    }
  }

  // DELETE PROFILE
  static Future<void> clearProfile() async {
    await _getBox.clear();
  }
}
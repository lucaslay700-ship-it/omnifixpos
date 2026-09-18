import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'service_item.dart';

class DatabaseHelper {
  // Singleton Pattern Implementation
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String globalSettingsBox = "omnifix_global_core";

  /// App စတင်ချိန်တွင် Dynamic Hive Database နှိုးဆော်ပေးသည့် စနစ်
  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    // Adapter များကို Manual မှတ်ပုံတင်ခြင်း
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceItemAdapter());
    }

    await Hive.openBox(globalSettingsBox);
    debugPrint("OmniFix POS Multi-Tenant Database Engine Active.");
  }

  // Tenant Isolation Box Resolvers
  String _getRecordsBoxName(String tenantId) => "records_$tenantId";
  String _getProfileBoxName(String tenantId) => "profile_$tenantId";

  /// Smart Shop Profile သိမ်းဆည်းခြင်း
  Future<void> saveShopProfile(dynamic profile) async {
    final boxName = _getProfileBoxName(profile.tenantId);
    final box = await Hive.openBox<dynamic>(boxName);
    await box.put('current_profile', profile);
  }

  /// Tenant အလိုက် Shop Profile ပြန်ထုတ်ယူခြင်း
  Future<dynamic> getShopProfile(String tenantId) async {
    final boxName = _getProfileBoxName(tenantId);
    final box = await Hive.openBox<dynamic>(boxName);
    return box.get('current_profile');
  }

  /// Service Item အသစ် ထည့်သွင်းခြင်း / ပြင်ဆင်ခြင်း
  Future<void> saveServiceItem(String tenantId, ServiceItem item) async {
    final boxName = _getRecordsBoxName(tenantId);
    final box = await Hive.openBox<ServiceItem>(boxName);
    await box.put(item.id, item);
  }

  /// Tenant အလိုက် Service Items စာရင်း အားလုံး ထုတ်ယူခြင်း
  Future<List<ServiceItem>> getAllServiceItems(String tenantId) async {
    final boxName = _getRecordsBoxName(tenantId);
    final box = await Hive.openBox<ServiceItem>(boxName);
    return box.values.toList();
  }

  /// Service Item တစ်ခုအား ဖျက်ထုတ်ခြင်း
  Future<void> deleteServiceItem(String tenantId, String itemId) async {
    final boxName = _getRecordsBoxName(tenantId);
    final box = await Hive.openBox<ServiceItem>(boxName);
    await box.delete(itemId);
  }

  /// Global App Settings ထဲသို့ Key-Value သိမ်းဆည်းခြင်း
  Future<void> saveGlobalSetting(String key, dynamic value) async {
    final box = Hive.box(globalSettingsBox);
    await box.put(key, value);
  }

  /// Global App Settings မှ Key-Value ပြန်ထုတ်ယူခြင်း
  dynamic getGlobalSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(globalSettingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<List<ServiceItem>> getServiceItems(String tenantId) async {
    return getAllServiceItems(tenantId);
  }
}
import 'package:flutter/services.dart';
import 'dart:convert';

class SecurityHelper {
  // 32-character Key နှင့် 16-character IV (စိတ်ကြိုက် စာလုံး ၃၂ လုံး နှင့် ၁၆ လုံး ပြောင်းလဲနိုင်ပါသည်)
  static const _key = 'omnifixpossecretkey32characters!';

  /// Text မူရင်းကို Encrypted String (ဖတ်မရသော စာသား) သို့ ပြောင်းခြင်း
  static String encryptData(String plainText) {
    if (plainText.isEmpty) return '';
    final bytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(_key);
    return base64Encode([
      for (var i = 0; i < bytes.length; i++) bytes[i] ^ keyBytes[i % keyBytes.length],
    ]);
  }

  /// Encrypted String ကို မူလ စာသား အဖြစ် ပြန်ပြောင်းခြင်း (Decryption)
  static String decryptData(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    final bytes = base64Decode(encryptedText);
    final keyBytes = utf8.encode(_key);
    return utf8.decode([
      for (var i = 0; i < bytes.length; i++) bytes[i] ^ keyBytes[i % keyBytes.length],
    ]);
  }
  static const MethodChannel _channel = MethodChannel('com.omnifix.pos/security');

  /// Android Screen Guard (Screenshot နှင့် Screen Recording တားဆီးခြင်း)
  static Future<void> enableScreenProtection() async {
    try {
      await _channel.invokeMethod('enableScreenSecure');
    } on PlatformException catch (e) {
      print("Failed to enable screen security: '${e.message}'.");
    }
  }

  /// System Integrity Check (Emulator သို့မဟုတ် Debugger မဟုတ်ကြောင်း စစ်ဆေးခြင်း)
  static Future<bool> isEnvironmentSecure() async {
    try {
      final bool isSecure = await _channel.invokeMethod('checkIntegrity');
      return isSecure;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
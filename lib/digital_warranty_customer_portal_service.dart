import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Backend Service for Step 13 (Digital Warranty) & Step 14 (Customer Portal)
class DigitalWarrantyAndCustomerPortalService {
  static final DigitalWarrantyAndCustomerPortalService _instance =
      DigitalWarrantyAndCustomerPortalService._internal();
  factory DigitalWarrantyAndCustomerPortalService() => _instance;
  DigitalWarrantyAndCustomerPortalService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentTenantId => _auth.currentUser?.uid;

  // Helper: Tenant Collection Isolation
  CollectionReference<Map<String, dynamic>> _getTenantCollection(
      String collectionName) {
    final tenantId = currentTenantId;
    if (tenantId == null || tenantId.isEmpty) {
      throw Exception("🔐 Security Exception: Active tenant session missing.");
    }
    return _db.collection('tenants').doc(tenantId).collection(collectionName);
  }

  // ============================================================================
  // STEP 13: DIGITAL WARRANTY BACKEND ENGINE
  // ============================================================================

  /// 1. Digital Warranty Card ထုတ်ပေးခြင်း (Issue Digital Warranty)
  Future<bool> issueDigitalWarranty({
    required String ticketId,
    required String customerPhone,
    required String deviceModel,
    required String serialOrImei,
    required int warrantyDays,
    required List<String> coveredComponents,
  }) async {
    try {
      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: warrantyDays));
      final warrantyId = "WAR-${now.millisecondsSinceEpoch.toString().substring(5)}";

      final payload = {
        'warranty_id': warrantyId,
        'ticket_id': ticketId,
        'customer_phone': customerPhone,
        'device_model': deviceModel,
        'serial_imei': serialOrImei,
        'issued_date': Timestamp.fromDate(now),
        'expiry_date': Timestamp.fromDate(expiryDate),
        'warranty_days': warrantyDays,
        'covered_components': coveredComponents,
        'status': 'ACTIVE', // ACTIVE, EXPIRED, VOID, CLAIMED
        'created_at': FieldValue.serverTimestamp(),
      };

      // Tenant-isolated Firestore DB ထဲသို့ သိမ်းဆည်းခြင်း
      await _getTenantCollection('warranties').doc(warrantyId).set(payload);

      // Public Access / Customer Portal အတွက် Global Lookup Collection ထဲသို့ Sync လုပ်ခြင်း
      await _db.collection('public_warranties').doc(warrantyId).set({
        'tenant_id': currentTenantId,
        'warranty_id': warrantyId,
        'customer_phone': customerPhone,
        'serial_imei': serialOrImei,
        'expiry_date': Timestamp.fromDate(expiryDate),
        'status': 'ACTIVE',
      });

      debugPrint("✅ [Step 13]: Digital Warranty Issued: $warrantyId");
      return true;
    } catch (e) {
      debugPrint("❌ [Step 13 Error]: Warranty Issuance Failed - $e");
      return false;
    }
  }

  /// 2. Warranty Status စစ်ဆေးခြင်း (Validate Warranty)
  Future<Map<String, dynamic>?> checkWarrantyStatus(String warrantyId) async {
    try {
      final doc = await _getTenantCollection('warranties').doc(warrantyId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final Timestamp expiryTimestamp = data['expiry_date'];
      final isExpired = DateTime.now().isAfter(expiryTimestamp.toDate());

      if (isExpired && data['status'] == 'ACTIVE') {
        // Auto-update to EXPIRED status if date passed
        await _getTenantCollection('warranties')
            .doc(warrantyId)
            .update({'status': 'EXPIRED'});
        data['status'] = 'EXPIRED';
      }

      return data;
    } catch (e) {
      debugPrint("❌ [Step 13 Error]: Checking Warranty Failed - $e");
      return null;
    }
  }// ============================================================================
  // STEP 14: CUSTOMER PORTAL BACKEND ENGINE
  // ============================================================================

  /// 1. ဝယ်သူဘက်မှ ဖုန်းနံပါတ် သို့မဟုတ် Voucher ID ဖြင့် Repair Status စစ်ဆေးခြင်း
  Stream<List<Map<String, dynamic>>> trackCustomerRepairStatus({
    required String customerPhone,
  }) {
    try {
      return _db
          .collectionGroup('tickets')
          .where('customer_phone', isEqualTo: customerPhone)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList());
    } catch (e) {
      debugPrint("⚠️ [Step 14 Error]: Repair tracking stream error - $e");
      return Stream.value([]);
    }
  }

  /// 2. Customer Portal တွင် ပြင်ဆင်မှု အခြေအနေပြောင်းလဲမှုများ Real-time ကြည့်ရှုခြင်း
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamSingleTicketStatus(
      String ticketId) {
    return _getTenantCollection('tickets').doc(ticketId).snapshots();
  }

  /// 3. ဝယ်သူဘက်မှ Customer Portal ထဲမှ Repair Ticket သို့ တိုက်ရိုက် Feedback/Note ပို့ခြင်း
  Future<bool> sendCustomerFeedback({
    required String ticketId,
    required String message,
    required double rating,
  }) async {
    try {
      await _getTenantCollection('tickets')
          .doc(ticketId)
          .collection('feedbacks')
          .add({
        'rating': rating,
        'message': message,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint("⭐ [Step 14]: Customer feedback submitted for Ticket: $ticketId");
      return true;
    } catch (e) {
      debugPrint("❌ [Step 14 Error]: Submitting Feedback Failed - $e");
      return false;
    }
  }
}
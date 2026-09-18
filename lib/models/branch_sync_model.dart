import 'package:flutter/foundation.dart';

// ==========================================
// 1. SUBSCRIPTION STATUS ENUM
// ==========================================

enum SubscriptionStatus { trial, active, expired, suspended }

// ==========================================
// 2. SHOP LICENSE MODEL (MULTI-TENANT SAAS)
// ==========================================

class ShopLicenseModel {
  final String shopId;
  final String shopName;
  final String ownerPhone;
  final DateTime registeredDate;
  final DateTime subscriptionExpiry;
  final SubscriptionStatus status;
  final bool isMultiBranchEnabled;
  final int maxBranchAllowed;

  ShopLicenseModel({
    required this.shopId,
    required this.shopName,
    required this.ownerPhone,
    required this.registeredDate,
    required this.subscriptionExpiry,
    required this.status,
    this.isMultiBranchEnabled = false,
    this.maxBranchAllowed = 1,
  });

  // Calculate 20-Day Free Trial Remaining Days
  int get remainingTrialDays {
    final now = DateTime.now();
    if (now.isAfter(subscriptionExpiry)) return 0;
    return subscriptionExpiry.difference(now).inDays;
  }

  // System Access Authorization Check Logic
  bool get isAccessAllowed {
    if (status == SubscriptionStatus.suspended) return false;
    if (status == SubscriptionStatus.expired || remainingTrialDays <= 0) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'shopName': shopName,
        'ownerPhone': ownerPhone,
        'registeredDate': registeredDate.toIso8601String(),
        'subscriptionExpiry': subscriptionExpiry.toIso8601String(),
        'status': status.name,
        'isMultiBranchEnabled': isMultiBranchEnabled,
        'maxBranchAllowed': maxBranchAllowed,
      };

  factory ShopLicenseModel.fromJson(Map<String, dynamic> json) => ShopLicenseModel(
        shopId: json['shopId'],
        shopName: json['shopName'],
        ownerPhone: json['ownerPhone'],
        registeredDate: DateTime.parse(json['registeredDate']),
        subscriptionExpiry: DateTime.parse(json['subscriptionExpiry']),
        status: SubscriptionStatus.values.byName(json['status']),
        isMultiBranchEnabled: json['isMultiBranchEnabled'] ?? false,
        maxBranchAllowed: json['maxBranchAllowed'] ?? 1,
      );
}

// ==========================================
// 3. BRANCH SYNC QUEUE MODEL
// ==========================================

class BranchSyncQueue {
  final String queueId;
  final String branchId;
  final String actionType; // e.g., INTAKE_CREATE, STOCK_TRANSFER, POS_SALE
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  bool isSynced;

  BranchSyncQueue({
    required this.queueId,
    required this.branchId,
    required this.actionType,
    required this.payload,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'queueId': queueId,
        'branchId': branchId,
        'actionType': actionType,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'isSynced': isSynced,
      };

  factory BranchSyncQueue.fromJson(Map<String, dynamic> json) => BranchSyncQueue(
        queueId: json['queueId'],
        branchId: json['branchId'],
        actionType: json['actionType'],
        payload: Map<String, dynamic>.from(json['payload']),
        timestamp: DateTime.parse(json['timestamp']),
        isSynced: json['isSynced'] ?? false,
      );
}
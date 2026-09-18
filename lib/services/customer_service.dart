import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ==========================================
// 1. CUSTOMER MODEL WITH HIVE ANNOTATION
// ==========================================

class CustomerModel extends HiveObject {
  String customerId;
  String name;
  String phone;
  String? email;
  String? address;
  DateTime createdAt;
  List<String> activeTicketIds; // Repair Tickets History Tracking

  CustomerModel({
    required this.customerId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.createdAt,
    List<String>? activeTicketIds,
  }) : activeTicketIds = activeTicketIds ?? [];

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
        'activeTicketIds': activeTicketIds,
      };
}

// Manual Hive Adapter (TypeId: 2)
class CustomerModelAdapter extends TypeAdapter<CustomerModel> {
  @override
  final int typeId = 2;

  @override
  CustomerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CustomerModel(
      customerId: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String?,
      address: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      activeTicketIds: (fields[6] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, CustomerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.activeTicketIds);
  }
}

// ==========================================
// 2. CUSTOMER SERVICE (CRUD & OFFLINE ENGINE)
// ==========================================

class CustomerService {
  static const String _boxName = 'customer_box';
  static Box<CustomerModel>? _box;

  // Hive DB Initialization
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }
    _box = await Hive.openBox<CustomerModel>(_boxName);
  }

  static Box<CustomerModel> get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception("CustomerService is not initialized. Call init() first.");
    }
    return _box!;
  }

  // CREATE / SAVE CUSTOMER
  static Future<void> saveCustomer(CustomerModel customer) async {
    await _getBox.put(customer.customerId, customer);
    debugPrint("Customer Saved/Updated: ${customer.name} (${customer.customerId})");
  }

  // READ / GET ALL CUSTOMERS
  static List<CustomerModel> getAllCustomers() {
    return _getBox.values.toList();
  }

  // GET CUSTOMER BY ID
  static CustomerModel? getCustomerById(String customerId) {
    return _getBox.get(customerId);
  }

  // SEARCH CUSTOMER BY PHONE OR NAME
  static List<CustomerModel> searchCustomer(String query) {
    if (query.isEmpty) return getAllCustomers();

    final cleanQuery = query.toLowerCase().trim();
    return _getBox.values.where((customer) {
      return customer.name.toLowerCase().contains(cleanQuery) ||
          customer.phone.contains(cleanQuery);
    }).toList();
  }

  // LINK REPAIR TICKET TO CUSTOMER
  static Future<void> attachTicketToCustomer(String customerId, String ticketId) async {
    final customer = getCustomerById(customerId);if (customer != null) {
      if (!customer.activeTicketIds.contains(ticketId)) {
        customer.activeTicketIds.add(ticketId);
        await customer.save(); // Save changes to Hive
        debugPrint("Ticket $ticketId linked to ${customer.name}");
      }
    }
  }

  // DELETE CUSTOMER
  static Future<void> deleteCustomer(String customerId) async {
    await _getBox.delete(customerId);
    debugPrint("Customer Deleted: $customerId");
  }

  // CLEAR ALL DATA (RESET)
  static Future<void> clearAll() async {
    await _getBox.clear();
  }
}

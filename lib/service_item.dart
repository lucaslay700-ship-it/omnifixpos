import 'package:hive/hive.dart';

// 1. Service Item Data Model
class ServiceItem extends HiveObject {
  String id;
  String tenantId;
  String customerName;
  String phoneModel;
  String issueDescription;
  double estimatedCost;
  String status;
  DateTime createdAt;

  ServiceItem({
    required this.id,
    required this.tenantId,
    required this.customerName,
    required this.phoneModel,
    required this.issueDescription,
    required this.estimatedCost,
    required this.status,
    required this.createdAt, required String customerPhone,
  });
}

// 2. Standalone Manual Adapter
class ServiceItemAdapter extends TypeAdapter<ServiceItem> {
  @override
  final int typeId = 0;

  @override
  ServiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceItem(
      id: fields[0] as String,
      tenantId: fields[1] as String,
      customerName: fields[2] as String,
      phoneModel: fields[3] as String,
      issueDescription: fields[4] as String,
      estimatedCost: fields[5] as double,
      status: fields[6] as String,
      createdAt: fields[7] as DateTime, customerPhone: '',
    );
  }
   
  

  @override
  void write(BinaryWriter writer, ServiceItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tenantId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.phoneModel)
      ..writeByte(4)
      ..write(obj.issueDescription)
      ..writeByte(5)
      ..write(obj.estimatedCost)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}
import 'package:flutter/material.dart';

enum ComponentFaultType { normal, shortToGround, openCircuit, highResistance, overheating }

class BorneoComponent {
  final String id;
  final String componentName; // e.g., U2100 Power IC
  final String partNumber; // e.g., PM-8350
  final double standardVoltage; // Target V
  final int standardDiodeValue; // Target Diode Ω
  final Offset boardCoordinate; // Pin Position on PCB Image
  final List<String> compatibleDonorBoards;
  ComponentFaultType faultState;
  double measuredVoltage;
  int measuredDiodeValue;
  double temperatureCelsius;

  BorneoComponent({
    required this.id,
    required this.componentName,
    required this.partNumber,
    required this.standardVoltage,
    required this.standardDiodeValue,
    required this.boardCoordinate,
    required this.compatibleDonorBoards,
    this.faultState = ComponentFaultType.normal,
    this.measuredVoltage = 0.0,
    this.measuredDiodeValue = 0,
    this.temperatureCelsius = 35.0,
  });
}
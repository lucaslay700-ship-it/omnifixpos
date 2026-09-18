// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class InspectionPoint {
  final double xRatio; // Percent coordinate for responsiveness
  final double yRatio;
  final String damageType; // 'Crack', 'Scratch', 'Dent'
  final String severity; // 'Low', 'Medium', 'High'

  InspectionPoint({
    required this.xRatio,
    required this.yRatio,
    required this.damageType,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'xRatio': xRatio,
        'yRatio': yRatio,
        'damageType': damageType,
        'severity': severity,
      };

  factory InspectionPoint.fromJson(Map<String, dynamic> json) => InspectionPoint(
        xRatio: json['xRatio'],
        yRatio: json['yRatio'],
        damageType: json['damageType'],
        severity: json['severity'],
      );
}
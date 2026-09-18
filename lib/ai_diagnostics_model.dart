import 'package:flutter/material.dart';

// ==========================================
// 1. ENUMS FOR AI SMART VISION DIAGNOSTICS
// ==========================================

enum FaultCategory {
  hardwareComponent,
  softwareFRP,
  kernelPanic,
  deadBoardPowerDrop, // Power မနိုး/သေနေသော ဖုန်းများအတွက်
}

enum HardwareComplexity {
  basicParts,
  chipLevelMicroSoldering,
  cpuRamReballing,
}

enum RomType {
  officialGlobal,
  chinaStable,
  customRom,
  vendorModified,
}

// ==========================================
// 2. GSMARENA & HARDWARE SPECS SUB-MODEL
// ==========================================

class GSMArenaSpecs {
  final String chipset;
  final String cpuArchitecture;
  final String gpu;
  final String storageType; // e.g., UFS 3.1 / eMMC 5.1
  final String releasedYear;

  const GSMArenaSpecs({
    required this.chipset,
    required this.cpuArchitecture,
    required this.gpu,
    required this.storageType,
    required this.releasedYear,
  });

  Map<String, dynamic> toJson() => {
        'chipset': chipset,
        'cpuArchitecture': cpuArchitecture,
        'gpu': gpu,
        'storageType': storageType,
        'releasedYear': releasedYear,
      };

  factory GSMArenaSpecs.fromJson(Map<String, dynamic> json) => GSMArenaSpecs(
        chipset: json['chipset'] ?? '',
        cpuArchitecture: json['cpuArchitecture'] ?? '',
        gpu: json['gpu'] ?? '',
        storageType: json['storageType'] ?? '',
        releasedYear: json['releasedYear'] ?? '',
      );
}

// ==========================================
// 3. FRP & BOOTLOADER UNLOCK AI MATRIX
// ==========================================

class FRPAndBootloaderStatus {
  final bool isBootloaderUnlockable;
  final bool isFRPBypassSupported;
  final RomType detectedRomType;
  final String targetTool; // e.g., UnlockTool, Pandora, Modern Meta
  final String bypassMethod; // e.g., EDL Mode 9008, BROM TestPoint, SPROM
  final String testPointLocation;
  final List<String> stepByStepSequence;

  const FRPAndBootloaderStatus({
    required this.isBootloaderUnlockable,
    required this.isFRPBypassSupported,
    required this.detectedRomType,
    required this.targetTool,
    required this.bypassMethod,
    required this.testPointLocation,
    required this.stepByStepSequence,
  });

  Map<String, dynamic> toJson() => {
        'isBootloaderUnlockable': isBootloaderUnlockable,
        'isFRPBypassSupported': isFRPBypassSupported,
        'detectedRomType': detectedRomType.name,
        'targetTool': targetTool,
        'bypassMethod': bypassMethod,
        'testPointLocation': testPointLocation,
        'stepByStepSequence': stepByStepSequence,
      };

  factory FRPAndBootloaderStatus.fromJson(Map<String, dynamic> json) =>
      FRPAndBootloaderStatus(
        isBootloaderUnlockable: json['isBootloaderUnlockable'] ?? false,
        isFRPBypassSupported: json['isFRPBypassSupported'] ?? false,
        detectedRomType: RomType.values.byName(
            json['detectedRomType'] ?? RomType.officialGlobal.name),
        targetTool: json['targetTool'] ?? '',
        bypassMethod: json['bypassMethod'] ?? '',
        testPointLocation: json['testPointLocation'] ?? '',
        stepByStepSequence: List<String>.from(json['stepByStepSequence'] ?? []),
      );
}

// ==========================================
// 4. POWER DEAD PHONE AI CHIP DIAGNOSTIC MODEL
// ==========================================

class PowerDeadDiagnosis {
  final double initialCurrentAmperage; // e.g., 0.02A or Full Short
  final String suspectedIC; // e.g., PM6150 Power IC, Sub-PMIC, CPU
  final String shortCircuitLine; // e.g., VPH_PWR, VBAT, VREG_LDO
  final String thermalScanHotspot; // Thermal Camera / AI Scanner မှ တွေ့သော အပူတက်သည့်နေရာ
  final List<String> recommendedFixSteps;

  const PowerDeadDiagnosis({
    required this.initialCurrentAmperage,
    required this.suspectedIC,
    required this.shortCircuitLine,
    required this.thermalScanHotspot,
    required this.recommendedFixSteps,
  });
}
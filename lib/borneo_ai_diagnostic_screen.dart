import 'package:flutter/material.dart';
import 'borneo_schematic_model.dart';

class BorneoAIDiagnosticScreen extends StatefulWidget {
  final String deviceModel;

  const BorneoAIDiagnosticScreen({
    super.key,
    this.deviceModel = "iPhone 13 Pro (PCB Board)",
  });

  @override
  State<BorneoAIDiagnosticScreen> createState() => _BorneoAIDiagnosticScreenState();
}

class _BorneoAIDiagnosticScreenState extends State<BorneoAIDiagnosticScreen> {
  BorneoComponent? _selectedComponent;
  final TextEditingController _voltageInput = TextEditingController();
  final TextEditingController _diodeInput = TextEditingController();
  final TextEditingController _tempInput = TextEditingController();

  String _aiAnalysisLog = "Borneo Smart AI Ready: Component တစ်ခုအား ရွေးချယ်ပြီး Data စစ်ဆေးပါ။";
  String _donorSearchResult = "";

  // Borneo PCB Component Master Database
  final List<BorneoComponent> _components = [
    BorneoComponent(
      id: "U2100",
      componentName: "Main Power IC (PMIC)",
      partNumber: "PM-8350-01",
      standardVoltage: 4.2,
      standardDiodeValue: 480,
      boardCoordinate: const Offset(120, 180),
      compatibleDonorBoards: ["iPhone 13", "iPhone 13 Mini", "iPhone 13 Pro Max"],
      temperatureCelsius: 36.5,
    ),
    BorneoComponent(
      id: "U3300",
      componentName: "USB/Charging IC (Tigris/Hydra)",
      partNumber: "SN261140A",
      standardVoltage: 5.0,
      standardDiodeValue: 390,
      boardCoordinate: const Offset(210, 110),
      compatibleDonorBoards: ["iPhone 12 Pro", "iPhone 13 Pro", "iPad Air 4"],
      temperatureCelsius: 38.0,
    ),
    BorneoComponent(
      id: "C2105",
      componentName: "VDD_MAIN Cap (Filtering)",
      partNumber: "CAP-0402-10UF",
      standardVoltage: 3.8,
      standardDiodeValue: 510,
      boardCoordinate: const Offset(150, 240),
      compatibleDonorBoards: ["Universal 0402 SMD Cap Package"],
      temperatureCelsius: 34.0,
    ),
    BorneoComponent(
      id: "Q2100",
      componentName: "VBUS Protection MOSFET",
      partNumber: "CSD17578Q3A",
      standardVoltage: 5.1,
      standardDiodeValue: 420,
      boardCoordinate: const Offset(250, 290),
      compatibleDonorBoards: ["iPhone 12", "iPhone 13"],
      temperatureCelsius: 35.5,
    ),
  ];

  @override
  void dispose() {
    _voltageInput.dispose();
    _diodeInput.dispose();
    _tempInput.dispose();
    super.dispose();
  }

  // Feature 2: Real-time Voltage & Resistance Reference Guide + AI Fault Detection
  void _runAIFaultDiagnosis() {
    if (_selectedComponent == null) return;

    double v = double.tryParse(_voltageInput.text) ?? 0.0;
    int d = int.tryParse(_diodeInput.text) ?? 0;
    double t = double.tryParse(_tempInput.text) ?? 35.0;

    _selectedComponent!.measuredVoltage = v;
    _selectedComponent!.measuredDiodeValue = d;
    _selectedComponent!.temperatureCelsius = t;

    setState(() {
      if (t >= 65.0) {
        // Feature 3 & 5: Overheating & Thermal Short Circuit
        _selectedComponent!.faultState = ComponentFaultType.overheating;
        _aiAnalysisLog = "🚨 CRITICAL THERMAL WARNING!\nComponent အပူချိန် ${t}°C သို့ မြင့်တက်နေသည်။ Main Short-Circuit သို့မဟုတ် Secondary Line ပူကန်နေပါသည်။";
      } else if (d < 30) {
        // Feature 3: Short To Ground
        _selectedComponent!.faultState = ComponentFaultType.shortToGround;
        _aiAnalysisLog = "⚡ SHORT-TO-GROUND DETECTED!\nDiode Value $d Ω သို့ ကျဆင်းနေသဖြင့် Ground အပြည့်ကျနေသည်။ VDD Line ရေဝင် သို့မဟုတ် Cap ပေါက်နေနိုင်သည်။";
      } else if (d > _selectedComponent!.standardDiodeValue + 250) {
        _selectedComponent!.faultState = ComponentFaultType.openCircuit;
        _aiAnalysisLog = "✂️ OPEN CIRCUIT / DISCONNECTED!\nDiode Value မရှိဘဲ လမ်းကြောင်း ပြတ်နေပါသည်။ Trace Line သို့မဟုတ် Resistor ပျက်နိုင်ပါသည်။";
      } else {
        _selectedComponent!.faultState = ComponentFaultType.normal;
        _aiAnalysisLog = "✅ NORMAL PASSED!\nတိုင်းတာချက်များ Borneo Standard တန်ဖိုးများနှင့် ကိုက်ညီပါသည်။";
      }
    });
  }// Feature 4: Component Part-Number & Multi-Option Interchange Search
  void _searchDonorBoards(String query) {
    if (query.isEmpty) {
      setState(() => _donorSearchResult = "");
      return;
    }

    final matched = _components.where((c) =>
      c.partNumber.toLowerCase().contains(query.toLowerCase()) ||
      c.componentName.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (matched.isNotEmpty) {
      final comp = matched.first;
      setState(() {
        _donorSearchResult = "🎯 Matching Part: ${comp.partNumber}\n• Donor Board အဟောင်းများ: ${comp.compatibleDonorBoards.join(", ")}";
      });
    } else {
      setState(() {
        _donorSearchResult = "⚠️ ကိုက်ညီသော Donor Board / IC Part Number မတွေ့ရှိပါ။";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step 6: Borneo Schematic AI Viewer (${widget.deviceModel})'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Left Side: Interactive Board Schematic Display (Zoom/Pan Simulation)
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black87,
              child: Stack(
                children: [
                  // PCB Board Vector Image / Box
                  Center(
                    child: Container(
                      width: 360,
                      height: 560,
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade700, width: 3),
                      ),
                      child: const Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Text('BORNEO HARDWARE SMART MAP', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Feature 1: Interactive Board Component Direct-Overlay Pins
                  ..._components.map((comp) {
                    Color pinColor = Colors.cyan;
                    if (comp.faultState == ComponentFaultType.shortToGround) pinColor = Colors.red;
                    if (comp.faultState == ComponentFaultType.overheating) pinColor = Colors.orangeAccent;
                    if (comp.faultState == ComponentFaultType.openCircuit) pinColor = Colors.purpleAccent;

                    return Positioned(
                      left: comp.boardCoordinate.dx + 40,
                      top: comp.boardCoordinate.dy + 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedComponent = comp;
                            _voltageInput.text = comp.standardVoltage.toString();
                            _diodeInput.text = comp.standardDiodeValue.toString();
                            _tempInput.text = comp.temperatureCelsius.toString();
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: pinColor,
                                shape: BoxShape.circle,boxShadow: [
                                  BoxShadow(
                                    color: pinColor.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.radio_button_checked, color: Colors.white, size: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              color: Colors.black87,
                              child: Text(comp.id, style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Right Side: Diagnostic Control, Dynamic AI Engine & Donor Search
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ListView(
                children: [
                  // Feature 4: Search IC & Donor Board Cross-Reference
                  const Text('🔍 Donor Board & IC Interchange Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: _searchDonorBoards,
                    decoration: const InputDecoration(
                      hintText: 'Enter IC Part (e.g., SN261140A or Power IC)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  if (_donorSearchResult.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.amber.shade50,
                      child: Text(_donorSearchResult, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const Divider(height: 24),

                  // Feature 2, 3 & 5: Diagnostic Analysis Panel
                  if (_selectedComponent == null)
                    const Center(child: Text('Schematic ပေါ်ရှိ Component Pin တစ်ခုအား နှိပ်ပါ'))
                  else ...[
                    Text(
                      '${_selectedComponent!.id}: ${_selectedComponent!.componentName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    Text('Part Number: ${_selectedComponent!.partNumber}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),

                    // Standard Reference Card
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📐 Borneo Reference Target:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('• Standard Voltage: ${_selectedComponent!.standardVoltage} V', style: const TextStyle(fontSize: 11)),
                          Text('• Standard Diode Mode: ${_selectedComponent!.standardDiodeValue} Ω', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),// Live Measurement Inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voltageInput,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Voltage (V)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _diodeInput,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Diode (Ω)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tempInput,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Thermal Cam Temp (°C)',
                        prefixIcon: Icon(Icons.thermostat),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
                      onPressed: _runAIFaultDiagnosis,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Run Borneo AI Diagnostic'),
                    ),
                    const SizedBox(height: 12),

                    // AI Result Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_aiAnalysisLog, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
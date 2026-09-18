import 'package:flutter/material.dart';
import 'inspection_point.dart';

class InspectionCanvasScreen extends StatefulWidget {
  final Function(List<InspectionPoint>) onSaveInspection;

  const InspectionCanvasScreen({super.key, required this.onSaveInspection});

  @override
  State<InspectionCanvasScreen> createState() => _InspectionCanvasScreenState();
}

class _InspectionCanvasScreenState extends State<InspectionCanvasScreen> {
  final List<InspectionPoint> _points = [];
  String _selectedDamageType = 'Crack';
  String _selectedSeverity = 'High';

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final double xRatio = details.localPosition.dx / constraints.maxWidth;
    final double yRatio = details.localPosition.dy / constraints.maxHeight;

    setState(() {
      _points.add(InspectionPoint(
        xRatio: xRatio,
        yRatio: yRatio,
        damageType: _selectedDamageType,
        severity: _selectedSeverity,
      ));
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Low':
        return Colors.yellow;
      case 'Medium':
        return Colors.orange;
      case 'High':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 1: AI Visual Device Inspection Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _points.isNotEmpty
                ? () => setState(() => _points.removeLast())
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onSaveInspection(_points);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedDamageType,
                  items: const [
                    DropdownMenuItem(value: 'Crack', child: Text('Crack (မှန်ကွဲ)')),
                    DropdownMenuItem(value: 'Scratch', child: Text('Scratch (ပွန်းရာ)')),
                    DropdownMenuItem(value: 'Dent', child: Text('Dent (ချိုင့်ရာ)')),
                  ],
                  onChanged: (v) => setState(() => _selectedDamageType = v!),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedSeverity,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (v) => setState(() => _selectedSeverity = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap on the Phone Diagram to record damage coordinates',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Interactive Interactive Canvas Engine
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double canvasWidth = constraints.maxWidth * 0.7;
                  final double canvasHeight = constraints.maxHeight * 0.9;

                  return GestureDetector(
                    onTapDown: (details) => _handleTapDown(details,
                      BoxConstraints.tightFor(width: canvasWidth, height: canvasHeight),
                    ),
                    child: Container(
                      width: canvasWidth,
                      height: canvasHeight,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.blueAccent, width: 3),
                      ),
                      child: Stack(
                        children: [
                          // Device Silhouette Canvas Body
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Icon(Icons.camera_alt_outlined, color: Colors.grey),
                                ),
                                Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12.0),
                                  child: Icon(Icons.circle_outlined, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // Custom Painter Overlay for Damage Coordinates
                          CustomPaint(
                            size: Size(canvasWidth, canvasHeight),
                            painter: DamageCanvasPainter(
                              points: _points,
                              colorResolver: _getSeverityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DamageCanvasPainter extends CustomPainter {
  final List<InspectionPoint> points;
  final Color Function(String severity) colorResolver;

  DamageCanvasPainter({required this.points, required this.colorResolver});

  @override
  void paint(Canvas canvas, Size size) {
    for (var point in points) {
      final dx = point.xRatio * size.width;
      final dy = point.yRatio * size.height;
      final paint = Paint()
        ..color = colorResolver(point.severity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), 8, paint);

      // Outer Pulse Ring Effect
      final ringPaint = Paint()
        ..color = colorResolver(point.severity).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(dx, dy), 14, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
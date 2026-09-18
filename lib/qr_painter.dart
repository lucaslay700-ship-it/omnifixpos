import 'package:flutter/material.dart';

class EncryptedQRPainter extends CustomPainter {
  final String data;

  EncryptedQRPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.fill;

    final bgPaint = Paint()
  ..color = Colors.white
  ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final double cellSize = size.width / 25;
    final int hash = data.hashCode.abs();

    // Structural QR Position Detection Patterns (Corners)
    _drawSquare(canvas, paint, 0, 0, cellSize * 6);
    _drawSquare(canvas, paint, size.width - (cellSize * 6), 0, cellSize * 6);
    _drawSquare(canvas, paint, 0, size.height - (cellSize * 6), cellSize * 6);

    // Dynamic Hash Data Bit Representation Simulation
    for (int x = 0; x < 25; x++) {
      for (int y = 0; y < 25; y++) {
        // Skip corner finder bounds
        if ((x < 7 && y < 7) || (x > 17 && y < 7) || (x < 7 && y > 17)) continue;

        if ((x * y + hash) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize - 0.5, cellSize - 0.5),
            paint,
          );
        }
      }
    }
  }

  void _drawSquare(Canvas canvas, Paint paint, double x, double y, double size) {
    final outer = Rect.fromLTWH(x, y, size, size);
    final innerBg = Rect.fromLTWH(x + size / 6, y + size / 6, size * 2 / 3, size * 2 / 3);
    final innerCenter = Rect.fromLTWH(x + size / 3, y + size / 3, size / 3, size / 3);

    final bgPaint = Paint()..color = Colors.white;

    canvas.drawRect(outer, paint);
    canvas.drawRect(innerBg, bgPaint);
    canvas.drawRect(innerCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
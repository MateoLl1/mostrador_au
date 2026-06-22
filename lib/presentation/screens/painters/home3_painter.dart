import 'package:flutter/material.dart';

class Home3Painter extends CustomPainter {
  final Color primaryColor;

  Home3Painter({super.repaint, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Path triangle({required Offset p1, required Offset p2, required Offset p3}) {
      return Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
    }

    fillPaint.color = primaryColor.withValues(alpha: 0.08);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.05, size.height * 0.10),
        p2: Offset(size.width * 0.32, size.height * 0.04),
        p3: Offset(size.width * 0.18, size.height * 0.34),
      ),
      fillPaint,
    );

    fillPaint.color = primaryColor.withValues(alpha: 0.06);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.78, size.height * 0.06),
        p2: Offset(size.width * 1.05, size.height * 0.22),
        p3: Offset(size.width * 0.72, size.height * 0.36),
      ),
      fillPaint,
    );

    fillPaint.color = primaryColor.withValues(alpha: 0.05);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.68, size.height * 0.72),
        p2: Offset(size.width * 1.02, size.height * 0.88),
        p3: Offset(size.width * 0.80, size.height * 1.08),
      ),
      fillPaint,
    );

    fillPaint.color = primaryColor.withValues(alpha: 0.045);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * -0.05, size.height * 0.82),
        p2: Offset(size.width * 0.25, size.height * 0.68),
        p3: Offset(size.width * 0.16, size.height * 1.02),
      ),
      fillPaint,
    );

    fillPaint.color = primaryColor.withValues(alpha: 0.035);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.42, size.height * 0.38),
        p2: Offset(size.width * 0.62, size.height * 0.48),
        p3: Offset(size.width * 0.36, size.height * 0.62),
      ),
      fillPaint,
    );

    strokePaint.color = primaryColor.withValues(alpha: 0.14);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.45, size.height * 0.12),
        p2: Offset(size.width * 0.58, size.height * 0.18),
        p3: Offset(size.width * 0.48, size.height * 0.28),
      ),
      strokePaint,
    );

    strokePaint.color = primaryColor.withValues(alpha: 0.12);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.18, size.height * 0.48),
        p2: Offset(size.width * 0.36, size.height * 0.54),
        p3: Offset(size.width * 0.22, size.height * 0.66),
      ),
      strokePaint,
    );

    strokePaint.color = primaryColor.withValues(alpha: 0.10);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.70, size.height * 0.46),
        p2: Offset(size.width * 0.88, size.height * 0.56),
        p3: Offset(size.width * 0.72, size.height * 0.66),
      ),
      strokePaint,
    );

    fillPaint.color = primaryColor.withValues(alpha: 0.07);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.52, size.height * 0.78),
        p2: Offset(size.width * 0.62, size.height * 0.82),
        p3: Offset(size.width * 0.54, size.height * 0.91),
      ),
      fillPaint,
    );

    strokePaint.color = primaryColor.withValues(alpha: 0.09);
    canvas.drawPath(
      triangle(
        p1: Offset(size.width * 0.08, size.height * 0.32),
        p2: Offset(size.width * 0.18, size.height * 0.38),
        p3: Offset(size.width * 0.08, size.height * 0.45),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant Home3Painter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor;

  @override
  bool shouldRebuildSemantics(covariant Home3Painter oldDelegate) => false;
}

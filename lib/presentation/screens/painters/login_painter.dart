import 'package:flutter/material.dart';

class LoginPainter extends CustomPainter {
  final Color primaryColor;

  LoginPainter({required this.primaryColor, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Large blob top-left
    paint.color = primaryColor.withValues(alpha: 0.18);
    canvas.drawCircle(Offset(size.width * -0.05, size.height * 0.05), size.width * 0.52, paint);

    // Medium blob top-right
    paint.color = primaryColor.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(size.width * 1.08, size.height * -0.02), size.width * 0.38, paint);

    // Small accent circle top-center
    paint.color = primaryColor.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.14), size.width * 0.10, paint);

    // Tiny dot cluster
    paint.color = primaryColor.withValues(alpha: 0.30);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.30), size.width * 0.025, paint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.36), size.width * 0.015, paint);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.38), size.width * 0.012, paint);

    // Arc swoosh at the hero/form divider
    final swooshPath = Path();
    swooshPath.moveTo(0, size.height * 0.42);
    swooshPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.50,
      size.width, size.height * 0.40,
    );
    swooshPath.lineTo(size.width, 0);
    swooshPath.lineTo(0, 0);
    swooshPath.close();

    paint.color = primaryColor.withValues(alpha: 0.07);
    canvas.drawPath(swooshPath, paint);

    // Stroke ring bottom-left decoration
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = primaryColor.withValues(alpha: 0.18);
    canvas.drawCircle(Offset(size.width * -0.04, size.height * 0.88), size.width * 0.22, strokePaint);
    strokePaint.color = primaryColor.withValues(alpha: 0.10);
    canvas.drawCircle(Offset(size.width * -0.04, size.height * 0.88), size.width * 0.32, strokePaint);
  }

  @override
  bool shouldRepaint(covariant LoginPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor;
}

import 'package:flutter/material.dart';

class GoogleLogoIcon extends StatelessWidget {
  final double size;
  const GoogleLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double r = w / 2;
    final center = Offset(r, r);
    final double stroke = w * 0.22;
    final rect = Rect.fromCircle(center: center, radius: r - stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Red (Top arc)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.65, 1.85, false, paint);

    // Yellow (Left arc)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.05, 1.6, false, paint);

    // Green (Bottom arc)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.45, 1.6, false, paint);

    // Blue (Right arc)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.65, 1.1, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    final barRect = Rect.fromLTWH(
      center.dx - 1,
      center.dy - stroke / 2,
      r + 0.5,
      stroke,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

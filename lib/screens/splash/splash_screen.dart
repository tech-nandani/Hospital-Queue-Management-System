import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../role/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071D32),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _MedicalBackgroundPainter(
                    progress: _animationController.value,
                  ),
                ),
                _floatingIcon(
                  Icons.favorite_rounded,
                  const Alignment(-0.76, -0.46),
                  0.8,
                ),
                _floatingIcon(
                  Icons.local_pharmacy_rounded,
                  const Alignment(0.78, -0.22),
                  1.15,
                ),
                _floatingIcon(
                  Icons.monitor_heart_rounded,
                  const Alignment(-0.72, 0.38),
                  1.35,
                ),
                _floatingIcon(
                  Icons.add_rounded,
                  const Alignment(0.75, 0.48),
                  0.55,
                ),
                child!,
              ],
            );
          },
          child: _content,
        ),
      ),
    );
  }

  Widget get _content {
    return Column(
      children: [
        const Spacer(flex: 3),
        Container(
          height: 166,
          width: 166,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF54D6C0).withValues(alpha: 0.22),
                blurRadius: 42,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 112,
                width: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F8F3),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF16806A),
                size: 70,
              ),
              Positioned(
                right: 28,
                bottom: 29,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16806A),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'CareFlow',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 42),
          child: Text(
            'Smarter queues. Calmer visits.\nBetter care for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB8C9D8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ),
        const Spacer(flex: 2),
        const Text(
          'YOUR HEALTH  •  OUR PRIORITY',
          style: TextStyle(
            color: Color(0xFF7991A5),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _floatingIcon(IconData icon, Alignment alignment, double phase) {
    final movement = math.sin(
      (_animationController.value * math.pi * 2) + phase,
    );
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, movement * 11),
        child: Opacity(
          opacity: 0.35,
          child: Icon(icon, color: const Color(0xFF8ED7C2), size: 27),
        ),
      ),
    );
  }
}

class _MedicalBackgroundPainter extends CustomPainter {
  final double progress;

  const _MedicalBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.39);
    final pulse = Paint()
      ..color = const Color(0xFF8ED7C2).withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var ring = 0; ring < 4; ring++) {
      final radius = 95 + ((progress * 180 + ring * 86) % 360);
      final opacity = (1 - radius / 455).clamp(0.03, 0.18);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF8ED7C2).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }

    final path = Path()..moveTo(0, size.height * 0.72);
    for (var x = 0.0; x <= size.width; x += 8) {
      final wave = math.sin(
        (x / size.width * math.pi * 5) + progress * math.pi * 2,
      );
      path.lineTo(x, size.height * 0.72 + wave * 10);
    }
    canvas.drawPath(path, pulse);

    final dotPaint = Paint()
      ..color = const Color(0xFF8ED7C2).withValues(alpha: 0.28);
    for (var index = 0; index < 18; index++) {
      final x = (index * 83.0) % size.width;
      final y = (index * 117.0 + progress * 55) % size.height;
      canvas.drawCircle(Offset(x, y), 1.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MedicalBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

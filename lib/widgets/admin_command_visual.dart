import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A professional, animated hospital management and administration visual widget.
///
/// Specifically represents an ADMIN portal:
/// - Hospital administration & control center
/// - Staff verification & professional account approval
/// - Hospital queue & operations monitoring
/// - Role-based security & audit control
/// - Calm, smooth, executive healthcare micro-animations
class AdminCommandVisual extends StatefulWidget {
  final bool isCompact;
  final double? height;

  const AdminCommandVisual({
    super.key,
    this.isCompact = false,
    this.height,
  });

  @override
  State<AdminCommandVisual> createState() => _AdminCommandVisualState();
}

class _AdminCommandVisualState extends State<AdminCommandVisual>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _shieldController;

  @override
  void initState() {
    super.initState();

    // Floating cards smooth sinusoidal easing (4s cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Status indicator soft pulse (2.6s cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // Security shield subtle pulse (3.2s cycle)
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactVisual();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: widget.height ?? constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF071728),
                Color(0xFF0C243B),
                Color(0xFF103352),
                Color(0xFF0A1E33),
              ],
              stops: [0.0, 0.35, 0.75, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background grid & ambient teal glowing orbs
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _AdminBackgroundPainter(
                      glowProgress: _pulseController.value,
                    ),
                  );
                },
              ),

              // 2. Main Executive Scene: Dashboard console & admin control desk
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 620,
                      height: 520,
                      child: Stack(
                        children: [
                          // Vector Control Center desk & administrator silhouette
                          CustomPaint(
                            size: const Size(620, 520),
                            painter: _AdminConsoleVectorPainter(),
                          ),

                          // Top-Center: Hospital Command Console HUD
                          Positioned(
                            left: 40,
                            top: 24,
                            child: _buildCommandCenterHud(),
                          ),

                          // Top-Right: Floating Staff Approval Card
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, _) {
                              final offset =
                                  math.sin(_floatController.value * math.pi) * 7.0;
                              return Positioned(
                                right: 24,
                                top: 60 + offset,
                                child: _buildStaffApprovalCard(),
                              );
                            },
                          ),

                          // Mid-Left: Floating Queue & Operations Monitoring Card
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, _) {
                              final offset = math.sin(
                                    (_floatController.value + 0.4) * math.pi,
                                  ) *
                                  6.5;
                              return Positioned(
                                left: 32,
                                bottom: 100 + offset,
                                child: _buildQueueTelemetryCard(),
                              );
                            },
                          ),

                          // Bottom-Right: Security & Role-Based Access Badge
                          AnimatedBuilder(
                            animation: _shieldController,
                            builder: (context, _) {
                              return Positioned(
                                right: 36,
                                bottom: 84,
                                child: _buildSecurityGuardBadge(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Bottom Audit Telemetry Strip
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomAuditBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // COMPACT MOBILE VISUAL
  // ==========================================
  Widget _buildCompactVisual() {
    return Container(
      height: widget.height ?? 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071728),
            Color(0xFF0C243B),
            Color(0xFF103352),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AdminBackgroundPainter(glowProgress: 0.5),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16806A).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFF34D399),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hospital Command & Security Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'STAFF APPROVALS • QUEUE AUDIT • 256-BIT SECURE',
                          style: TextStyle(
                            color: const Color(0xFF6EE7B7).withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HUD: HOSPITAL COMMAND CENTER METRICS
  // ==========================================
  Widget _buildCommandCenterHud() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF071728).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF34D399),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'HOSPITAL CONTROL CENTER',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE AUDIT',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Operational 3-Tile Row
          Row(
            children: [
              _buildMetricTile(
                title: 'STAFF ON DUTY',
                value: '18',
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 8),
              _buildMetricTile(
                title: 'ACTIVE QUEUE',
                value: '142',
                color: const Color(0xFF34D399),
              ),
              const SizedBox(width: 8),
              _buildMetricTile(
                title: 'DISPATCH RATE',
                value: '98%',
                color: const Color(0xFFA78BFA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0C243B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 6.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLOATING STAFF APPROVAL CARD
  // ==========================================
  Widget _buildStaffApprovalCard() {
    return Container(
      width: 215,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F33).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7490), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.how_to_reg_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'STAFF VERIFICATION',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dr. Alex Mitchell',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Cardiology • License Verified ✓',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING QUEUE & OPERATIONS MONITOR CARD
  // ==========================================
  Widget _buildQueueTelemetryCard() {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1C2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0E7490)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'QUEUE DISPATCH',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF34D399),
                      size: 11,
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Counters 01-04 Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Throughput Normal • Wait: 4m',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING SECURITY & ACCESS SHIELD BADGE
  // ==========================================
  Widget _buildSecurityGuardBadge() {
    final scale = 1.0 + (_shieldController.value * 0.04);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 195,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B192C).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.18),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFF34D399),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ROLE-BASED GUARD',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '256-Bit SSL • Audit Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM AUDIT TELEMETRY STRIP
  // ==========================================
  Widget _buildBottomAuditBar() {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF051322).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 280;
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 6,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF34D399),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'ADMINISTRATIVE CONTROL CONSOLE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF10B981),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    compact ? 'RESTRICTED' : 'SYSTEM RESTRICTED',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// PAINTER 1: BACKGROUND PERSPECTIVE GRID & AMBIENT GLOWS
// ============================================================================
class _AdminBackgroundPainter extends CustomPainter {
  final double glowProgress;

  _AdminBackgroundPainter({required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle perspective grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 2. Ambient radial glow orbs
    final pulseOpacity = 0.08 + (glowProgress * 0.06);

    // Center-Right teal glow
    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: pulseOpacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.35),
          radius: 190,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.35),
      190,
      glowPaint1,
    );

    // Center-Left cyan glow
    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00B4D8).withValues(alpha: pulseOpacity * 0.65),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.55),
          radius: 170,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.55),
      170,
      glowPaint2,
    );

    // 3. Hospital security crest watermark in the backdrop
    final shieldCenter = Offset(size.width * 0.5, size.height * 0.34);
    final shieldPath = Path()
      ..moveTo(shieldCenter.dx, shieldCenter.dy - 65)
      ..lineTo(shieldCenter.dx + 52, shieldCenter.dy - 35)
      ..lineTo(shieldCenter.dx + 52, shieldCenter.dy + 15)
      ..quadraticBezierTo(
        shieldCenter.dx,
        shieldCenter.dy + 72,
        shieldCenter.dx,
        shieldCenter.dy + 72,
      )
      ..quadraticBezierTo(
        shieldCenter.dx - 52,
        shieldCenter.dy + 15,
        shieldCenter.dx - 52,
        shieldCenter.dy + 15,
      )
      ..lineTo(shieldCenter.dx - 52, shieldCenter.dy - 35)
      ..close();

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.035)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _AdminBackgroundPainter oldDelegate) {
    return oldDelegate.glowProgress != glowProgress;
  }
}

// ============================================================================
// PAINTER 2: VECTOR CONTROL CONSOLE & ADMINISTRATOR SILHOUETTE
// ============================================================================
class _AdminConsoleVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------
    // A. EXECUTIVE COMMAND DESK & WORKSTATION
    // -------------------------------------------------------------
    final deskTopPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B3857), Color(0xFF10273F)],
      ).createShader(const Rect.fromLTWH(130, 360, 360, 35));

    // Curved executive desk
    final deskPath = Path()
      ..moveTo(130, 375)
      ..cubicTo(200, 360, 420, 360, 490, 375)
      ..lineTo(470, 440)
      ..cubicTo(410, 450, 210, 450, 150, 440)
      ..close();
    canvas.drawPath(deskPath, deskTopPaint);

    // Desk neon green/teal ambient LED edge
    final ledGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);

    final edgePath = Path()
      ..moveTo(140, 438)
      ..cubicTo(205, 448, 415, 448, 480, 438);
    canvas.drawPath(edgePath, ledGlow);

    // -------------------------------------------------------------
    // B. MULTI-MONITOR CONTROL SCREENS ON DESK
    // -------------------------------------------------------------
    // Center Primary Monitor
    _drawMonitor(
      canvas,
      rect: const Rect.fromLTWH(240, 240, 140, 95),
      accentColor: const Color(0xFF10B981),
      isPrimary: true,
    );

    // Left Secondary Monitor (Angled inward)
    _drawMonitor(
      canvas,
      rect: const Rect.fromLTWH(145, 255, 85, 75),
      accentColor: const Color(0xFF38BDF8),
      isPrimary: false,
    );

    // Right Secondary Monitor (Angled inward)
    _drawMonitor(
      canvas,
      rect: const Rect.fromLTWH(390, 255, 85, 75),
      accentColor: const Color(0xFFA78BFA),
      isPrimary: false,
    );

    // -------------------------------------------------------------
    // C. ADMINISTRATOR SILHOUETTE (Center-Right at desk)
    // -------------------------------------------------------------
    _drawAdministrator(canvas, const Offset(310, 320));
  }

  void _drawMonitor(
    Canvas canvas, {
    required Rect rect,
    required Color accentColor,
    required bool isPrimary,
  }) {
    // Monitor Stand
    final standPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(
      Rect.fromLTWH(rect.center.dx - 3, rect.bottom, 6, 20),
      standPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.center.dx - 18, rect.bottom + 18, 36, 4),
        const Radius.circular(2),
      ),
      standPaint,
    );

    // Bezel
    final bezelPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      bezelPaint,
    );

    // Screen display surface
    final screenPaint = Paint()
      ..color = const Color(0xFF08192C)
      ..style = PaintingStyle.fill;
    final innerRect = rect.deflate(4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      screenPaint,
    );

    // Glowing screen content / graph lines
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    if (isPrimary) {
      // Draw dashboard mini-charts on primary monitor
      canvas.drawLine(
        Offset(innerRect.left + 8, innerRect.top + 20),
        Offset(innerRect.right - 8, innerRect.top + 20),
        linePaint,
      );
      // Mini graph curve
      final graphPath = Path()
        ..moveTo(innerRect.left + 12, innerRect.bottom - 12)
        ..lineTo(innerRect.left + 35, innerRect.bottom - 32)
        ..lineTo(innerRect.left + 65, innerRect.bottom - 22)
        ..lineTo(innerRect.left + 95, innerRect.bottom - 48)
        ..lineTo(innerRect.right - 12, innerRect.bottom - 36);

      canvas.drawPath(
        graphPath,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    } else {
      // Mini data bar metrics
      for (double y = innerRect.top + 14; y < innerRect.bottom - 10; y += 10) {
        canvas.drawLine(
          Offset(innerRect.left + 8, y),
          Offset(innerRect.right - 16, y),
          linePaint,
        );
      }
    }
  }

  void _drawAdministrator(Canvas canvas, Offset pos) {
    // Professional Administrator Silhouette (Rear/profile facing monitors)
    final suitPaint = Paint()..color = const Color(0xFF0E2238);
    final collarPaint = Paint()..color = const Color(0xFFE2E8F0);
    final tiePaint = Paint()..color = const Color(0xFF10B981);
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final skinPaint = Paint()..color = const Color(0xFFE2B89B);

    // Hair
    canvas.drawCircle(Offset(pos.dx, pos.dy - 38), 16, hairPaint);

    // Head / neck
    canvas.drawCircle(Offset(pos.dx, pos.dy - 32), 14, skinPaint);

    // White shirt collar
    final collarPath = Path()
      ..moveTo(pos.dx - 8, pos.dy - 16)
      ..lineTo(pos.dx + 8, pos.dy - 16)
      ..lineTo(pos.dx, pos.dy - 6)
      ..close();
    canvas.drawPath(collarPath, collarPaint);

    // Green tie
    final tiePath = Path()
      ..moveTo(pos.dx - 2.5, pos.dy - 14)
      ..lineTo(pos.dx + 2.5, pos.dy - 14)
      ..lineTo(pos.dx + 3.5, pos.dy + 8)
      ..lineTo(pos.dx, pos.dy + 14)
      ..lineTo(pos.dx - 3.5, pos.dy + 8)
      ..close();
    canvas.drawPath(tiePath, tiePaint);

    // Executive Suit Torso
    final torsoPath = Path()
      ..moveTo(pos.dx - 28, pos.dy - 16)
      ..lineTo(pos.dx + 28, pos.dy - 16)
      ..lineTo(pos.dx + 34, pos.dy + 55)
      ..lineTo(pos.dx - 34, pos.dy + 55)
      ..close();
    canvas.drawPath(torsoPath, suitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WorkflowVisualMode {
  patientWorkflow,
  patientRegistration,
  staffRegistration,
}

/// A premium, modern hospital workflow illustration and animation widget.
///
/// Communicates:
/// - Modern hospital environment with architectural glass and clinical lighting
/// - Doctor in background reviewing patient chart
/// - Receptionist at a modern curved reception desk
/// - Patient registration and check-in interaction
/// - Queue/token management with digital wall display
/// - Appointment management status indicators
/// - Healthcare technology and telemetry
/// - Subtle, smooth, professional animated ECG medical pulse
class HospitalWorkflowVisual extends StatefulWidget {
  final bool showHeader;
  final bool isCompact;
  final double? height;
  final WorkflowVisualMode mode;
  final String activeToken;
  final String doctorName;
  final String department;
  final int estimatedWaitMinutes;
  final bool useIllustrationAsset;

  const HospitalWorkflowVisual({
    super.key,
    this.showHeader = true,
    this.isCompact = false,
    this.height,
    this.mode = WorkflowVisualMode.patientWorkflow,
    this.activeToken = 'A-104',
    this.doctorName = 'Dr. Sarah Jenkins',
    this.department = 'Cardiology & OPD',
    this.estimatedWaitMinutes = 4,
    this.useIllustrationAsset = false,
  });

  @override
  State<HospitalWorkflowVisual> createState() => _HospitalWorkflowVisualState();
}

class _HospitalWorkflowVisualState extends State<HospitalWorkflowVisual>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // ECG pulse trace animation (smooth 2.4s cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Floating cards micro-motion (subtle 4s breathing cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Ambient glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactVisual();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A192F),
                Color(0xFF0F2642),
                Color(0xFF143154),
                Color(0xFF0D223B),
              ],
              stops: [0.0, 0.35, 0.75, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Architectural background / Concept asset backdrop
              if (widget.useIllustrationAsset) ...[
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/hospital_workflow_visual.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return CustomPaint(
                        painter: _HospitalBackgroundPainter(
                          glowProgress: _glowController.value,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0A192F).withValues(alpha: 0.35),
                  ),
                ),
              ] else
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _HospitalBackgroundPainter(
                        glowProgress: _glowController.value,
                      ),
                    );
                  },
                ),

              // 2. Main Illustration Scene: Doctor, Receptionist at Desk, Patient
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: widget.showHeader ? 75.0 : 20.0,
                    bottom: 68.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 620,
                      height: 480,
                      child: Stack(
                        children: [
                          // Vector scene painting (rendered in vector mode)
                          if (!widget.useIllustrationAsset)
                            CustomPaint(
                              size: const Size(620, 480),
                              painter: _HospitalSceneVectorPainter(),
                            ),

                          // Live Digital Wall Queue Display (HUD)
                          Positioned(
                            left: 32,
                            top: 36,
                            child: _buildDigitalQueueDisplay(),
                          ),

                          // Floating Workflow Ribbon: PATIENT → RECEPTIONIST → QUEUE → DOCTOR
                          Positioned(
                            left: 260,
                            top: 22,
                            child: _buildWorkflowRibbon(),
                          ),

                          // Floating Token Card (Smooth hover)
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, _) {
                              final floatOffset =
                                  math.sin(_floatController.value * math.pi) * 7.0;
                              return Positioned(
                                right: 18,
                                top: 92 + floatOffset,
                                child: _buildTokenBadge(),
                              );
                            },
                          ),

                          // Floating Appointment Card (Staggered hover)
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, _) {
                              final floatOffset = math.sin(
                                    (_floatController.value + 0.5) * math.pi,
                                  ) *
                                  6.0;
                              return Positioned(
                                right: 30,
                                bottom: 58 + floatOffset,
                                child: _buildAppointmentBadge(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Top Header Branding (if enabled)
              if (widget.showHeader)
                Positioned(
                  top: 24,
                  left: 28,
                  right: 28,
                  child: _buildTopHeader(),
                ),

              // 4. Bottom Decorative Animated ECG / Medical Telemetry Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildEcgTelemetrySection(),
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
    final String title;
    final String subtitle;
    final IconData icon;

    switch (widget.mode) {
      case WorkflowVisualMode.patientRegistration:
        title = 'Patient Registration & Appointments';
        subtitle = 'PATIENT ACCOUNT • EASY QUEUE ACCESS';
        icon = Icons.person_rounded;
        break;
      case WorkflowVisualMode.staffRegistration:
        title = 'Staff Onboarding & Hospital Operations';
        subtitle = 'DOCTOR & RECEPTIONIST • ADMIN VERIFICATION';
        icon = Icons.badge_rounded;
        break;
      case WorkflowVisualMode.patientWorkflow:
        title = 'CareFlow Healthcare & Patient Flow';
        subtitle = 'SMART RECEPTION • TOKEN DISPATCH';
        icon = Icons.local_hospital_rounded;
        break;
    }

    return Container(
      height: widget.height ?? 210,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A192F),
            Color(0xFF0F2642),
            Color(0xFF143154),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HospitalBackgroundPainter(glowProgress: 0.5),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF38BDF8),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                          subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF6EE7B7).withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
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
  // TOP BRANDING & HEADER
  // ==========================================
  Widget _buildTopHeader() {
    final String subtitle;
    final String statusLabel;

    switch (widget.mode) {
      case WorkflowVisualMode.patientRegistration:
        subtitle = 'PATIENT ONBOARDING & REGISTRATION';
        statusLabel = 'PATIENT ACCESS';
        break;
      case WorkflowVisualMode.staffRegistration:
        subtitle = 'PROFESSIONAL STAFF REGISTRATION';
        statusLabel = 'STAFF ACCESS';
        break;
      case WorkflowVisualMode.patientWorkflow:
        subtitle = 'SMART RECEPTION & PATIENT FLOW';
        statusLabel = 'OPD LIVE';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00B4D8).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Color(0xFF38EF7D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CareFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF00B4D8).withValues(alpha: 0.85),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Hospital status chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Text(
                statusLabel,
                style: const TextStyle(
                  color: Color(0xFF6EE7B7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DIGITAL QUEUE DISPLAY (WALL HUD)
  // ==========================================
  Widget _buildDigitalQueueDisplay() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B192C).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF38EF7D),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'QUEUE BOARD',
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
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COUNTER 02',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active token indicator
          const Text(
            'NOW SERVING',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.activeToken,
                style: const TextStyle(
                  color: Color(0xFF38EF7D),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Color(0xFF10B981),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '• ${widget.doctorName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Next in queue & wait time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Next: A-105, A-106',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Wait ~${widget.estimatedWaitMinutes}m',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
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
  // FLOATING TOKEN MANAGEMENT BADGE
  // ==========================================
  Widget _buildTokenBadge() {
    final IconData icon;
    final String title;
    final String code;
    final String subtitle;

    switch (widget.mode) {
      case WorkflowVisualMode.patientRegistration:
        icon = Icons.verified_outlined;
        title = 'PATIENT PASS';
        code = '#PT-NEW • Digital Pass';
        subtitle = 'Instant Queue & Booking Link';
        break;
      case WorkflowVisualMode.staffRegistration:
        icon = Icons.badge_rounded;
        title = 'STAFF PROFILE';
        code = 'Doctor / Receptionist';
        subtitle = 'Admin Verification Pending';
        break;
      case WorkflowVisualMode.patientWorkflow:
        icon = Icons.confirmation_number_outlined;
        title = 'TOKEN ISSUED';
        code = '#A-104 • Check-In';
        subtitle = 'Receptionist Verified • Queue Assigned';
        break;
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF34D399),
                      size: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
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
  // FLOATING WORKFLOW RIBBON
  // ==========================================
  Widget _buildWorkflowRibbon() {
    final String text;
    switch (widget.mode) {
      case WorkflowVisualMode.patientRegistration:
        text = 'PATIENT → APPOINTMENT → TOKEN QUEUE → CARE';
        break;
      case WorkflowVisualMode.staffRegistration:
        text = 'DOCTOR / RECEPTIONIST → QUEUE OPS → ADMIN APPROVAL';
        break;
      case WorkflowVisualMode.patientWorkflow:
        text = 'PATIENT → RECEPTIONIST → QUEUE → DOCTOR';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E34).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.swap_horiz_rounded,
            color: Color(0xFF38BDF8),
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFBAE6FD),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING APPOINTMENT CARD
  // ==========================================
  Widget _buildAppointmentBadge() {
    final IconData icon;
    final String title;
    final String time;
    final String name;
    final String dept;

    switch (widget.mode) {
      case WorkflowVisualMode.patientRegistration:
        icon = Icons.calendar_today_rounded;
        title = 'CONFIRMED VISIT';
        time = '10:30 AM';
        name = widget.doctorName;
        dept = widget.department;
        break;
      case WorkflowVisualMode.staffRegistration:
        icon = Icons.health_and_safety_rounded;
        title = 'WORKFORCE';
        time = 'Active Shift';
        name = 'Doctor / Receptionist';
        dept = 'CareFlow Operations Desk';
        break;
      case WorkflowVisualMode.patientWorkflow:
        icon = Icons.calendar_today_rounded;
        title = 'APPOINTMENT';
        time = '10:30 AM';
        name = widget.doctorName;
        dept = widget.department;
        break;
    }

    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dept,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
  // ANIMATED ECG TELEMETRY BAR
  // ==========================================
  Widget _buildEcgTelemetrySection() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF061324).withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.22),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pulse icon and BPM label
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Color(0xFF34D399),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '72 BPM',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'SMART CLINICAL TELEMETRY',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Live ECG Waveform
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _EcgWavePainter(
                    progress: _pulseController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Tech connectivity pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_rounded,
                  color: Color(0xFF38BDF8),
                  size: 11,
                ),
                SizedBox(width: 4),
                Text(
                  'SYNCED',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAINTER 1: ARCHITECTURAL BACKGROUND & CLINICAL AMBIENCE
// ============================================================================
class _HospitalBackgroundPainter extends CustomPainter {
  final double glowProgress;

  _HospitalBackgroundPainter({required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle architectural perspective grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 2. Ambient orbs / clinical light glows
    final pulseOpacity = 0.07 + (glowProgress * 0.05);

    // Top-right glow
    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00B4D8).withValues(alpha: pulseOpacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.82, size.height * 0.22),
          radius: 170,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22),
      170,
      glowPaint1,
    );

    // Center-left glow (behind doctor area)
    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: pulseOpacity * 0.7),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.22, size.height * 0.45),
          radius: 190,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.45),
      190,
      glowPaint2,
    );

    // 3. Hospital cross emblem watermark (subtle frosted backdrop)
    final crossCenter = Offset(size.width * 0.78, size.height * 0.32);
    final crossPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: crossCenter, width: 28, height: 86),
        const Radius.circular(8),
      ),
      crossPaint,
    );
    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: crossCenter, width: 86, height: 28),
        const Radius.circular(8),
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HospitalBackgroundPainter oldDelegate) {
    return oldDelegate.glowProgress != glowProgress;
  }
}

// ============================================================================
// PAINTER 2: VECTOR ILLUSTRATION SCENE (DOCTOR, RECEPTIONIST, DESK, PATIENT)
// ============================================================================
class _HospitalSceneVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------
    // A. BACKGROUND ARCHITECTURE: CLINIC CORRIDOR & GLASS WALL
    // -------------------------------------------------------------
    // Doctor consultation doorway on left side
    final doorPaint = Paint()
      ..color = const Color(0xFF132B45)
      ..style = PaintingStyle.fill;
    final doorFramePaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final doorRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(80, 110, 110, 240),
      const Radius.circular(12),
    );
    canvas.drawRRect(doorRect, doorPaint);
    canvas.drawRRect(doorRect, doorFramePaint);

    // Doorway signage: "CLINIC 01 • CONSULTATION"
    final signBgPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(88, 120, 94, 16),
        const Radius.circular(4),
      ),
      signBgPaint,
    );

    // Soft clinic interior light inside doorway
    final innerLightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A5F), Color(0xFF10233B)],
      ).createShader(const Rect.fromLTWH(88, 142, 94, 200));
    canvas.drawRect(const Rect.fromLTWH(88, 142, 94, 200), innerLightPaint);

    // Hospital floor reflective plane
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0E2238), Color(0xFF081423)],
      ).createShader(Rect.fromLTWH(0, 330, size.width, 150));
    canvas.drawRect(Rect.fromLTWH(0, 330, size.width, 150), floorPaint);

    // Floor horizon line
    final horizonPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.25)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      const Offset(0, 330),
      Offset(size.width, 330),
      horizonPaint,
    );

    // -------------------------------------------------------------
    // B. DOCTOR IN BACKGROUND (Physician in white coat & stethoscope)
    // -------------------------------------------------------------
    _drawDoctor(canvas, const Offset(132, 175));

    // -------------------------------------------------------------
    // C. RECEPTION DESK (Modern curved hospital counter)
    // -------------------------------------------------------------
    _drawReceptionDesk(canvas);

    // -------------------------------------------------------------
    // D. RECEPTIONIST AT RECEPTION DESK (Not a nurse)
    // -------------------------------------------------------------
    _drawReceptionist(canvas, const Offset(330, 185));

    // -------------------------------------------------------------
    // E. PATIENT AT RECEPTION DESK (Registering / Check-in)
    // -------------------------------------------------------------
    _drawPatient(canvas, const Offset(468, 195));

    // -------------------------------------------------------------
    // F. DESK ACCESSORIES: COMPUTER TERMINAL, TOKEN PRINTER, LIGHTING
    // -------------------------------------------------------------
    _drawDeskAccessories(canvas);
  }

  // --------------------------------------------------------------------------
  // DOCTOR (Lab coat, stethoscope, tablet chart, professional stance)
  // --------------------------------------------------------------------------
  void _drawDoctor(Canvas canvas, Offset pos) {
    // Subtle shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx + 4, pos.dy + 155),
        width: 44,
        height: 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Head / Hair
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final facePaint = Paint()..color = const Color(0xFFF6D1BA);

    // Hair
    canvas.drawCircle(Offset(pos.dx, pos.dy - 6), 13, hairPaint);
    // Face
    canvas.drawCircle(Offset(pos.dx, pos.dy), 11, facePaint);

    // Professional glasses frame
    final glassesPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(pos.dx - 4, pos.dy - 1), 3.2, glassesPaint);
    canvas.drawCircle(Offset(pos.dx + 4, pos.dy - 1), 3.2, glassesPaint);
    canvas.drawLine(
      Offset(pos.dx - 1, pos.dy - 1),
      Offset(pos.dx + 1, pos.dy - 1),
      glassesPaint,
    );

    // Inner Scrubs (Teal)
    final scrubPaint = Paint()..color = const Color(0xFF0E7490);
    final scrubPath = Path()
      ..moveTo(pos.dx - 10, pos.dy + 12)
      ..lineTo(pos.dx + 10, pos.dy + 12)
      ..lineTo(pos.dx + 8, pos.dy + 45)
      ..lineTo(pos.dx - 8, pos.dy + 45)
      ..close();
    canvas.drawPath(scrubPath, scrubPaint);

    // White Lab Coat (Physician Coat)
    final coatPaint = Paint()..color = const Color(0xFFF8FAFC);
    final coatShadow = Paint()..color = const Color(0xFFCBD5E1);

    // Left lapel & coat
    final coatPath = Path()
      ..moveTo(pos.dx - 16, pos.dy + 16)
      ..lineTo(pos.dx - 4, pos.dy + 22)
      ..lineTo(pos.dx - 7, pos.dy + 95)
      ..lineTo(pos.dx - 19, pos.dy + 92)
      ..close();
    canvas.drawPath(coatPath, coatPaint);

    // Right lapel & coat
    final rightCoatPath = Path()
      ..moveTo(pos.dx + 16, pos.dy + 16)
      ..lineTo(pos.dx + 4, pos.dy + 22)
      ..lineTo(pos.dx + 7, pos.dy + 95)
      ..lineTo(pos.dx + 19, pos.dy + 92)
      ..close();
    canvas.drawPath(rightCoatPath, coatShadow);

    // Lab coat collar
    final collarPath = Path()
      ..moveTo(pos.dx - 15, pos.dy + 14)
      ..lineTo(pos.dx - 3, pos.dy + 28)
      ..lineTo(pos.dx, pos.dy + 20)
      ..lineTo(pos.dx + 3, pos.dy + 28)
      ..lineTo(pos.dx + 15, pos.dy + 14)
      ..close();
    canvas.drawPath(collarPath, coatPaint);

    // Stethoscope around neck
    final stethPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 18), width: 14, height: 16),
      0,
      math.pi,
      false,
      stethPaint,
    );
    // Stethoscope tube & bell
    canvas.drawLine(
      Offset(pos.dx + 5, pos.dy + 26),
      Offset(pos.dx + 2, pos.dy + 42),
      stethPaint,
    );
    canvas.drawCircle(
      Offset(pos.dx + 2, pos.dy + 44),
      3.2,
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Trousers / Pants (Navy)
    final pantsPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 14, pos.dy + 93, 12, 58),
        const Radius.circular(3),
      ),
      pantsPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 2, pos.dy + 93, 12, 58),
        const Radius.circular(3),
      ),
      pantsPaint,
    );

    // Doctor Shoes
    final shoePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 16, pos.dy + 149, 14, 7),
        const Radius.circular(3),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 2, pos.dy + 149, 14, 7),
        const Radius.circular(3),
      ),
      shoePaint,
    );

    // Digital Tablet / Medical Chart in hand
    final tabletPaint = Paint()..color = const Color(0xFF0F172A);
    final screenGlow = Paint()..color = const Color(0xFF38BDF8);
    canvas.save();
    canvas.translate(pos.dx + 12, pos.dy + 48);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 20, 28),
        const Radius.circular(3),
      ),
      tabletPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, 16, 24),
        const Radius.circular(2),
      ),
      screenGlow,
    );
    canvas.restore();
  }

  // --------------------------------------------------------------------------
  // RECEPTION DESK (Curved, bi-color, glowing LED base)
  // --------------------------------------------------------------------------
  void _drawReceptionDesk(Canvas canvas) {
    // Desk front body
    final deskBodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E3A5F), Color(0xFF11263F)],
      ).createShader(const Rect.fromLTWH(230, 270, 270, 115));

    final deskPath = Path()
      ..moveTo(230, 285)
      ..cubicTo(270, 275, 430, 275, 490, 288)
      ..lineTo(485, 375)
      ..cubicTo(430, 385, 275, 385, 235, 375)
      ..close();
    canvas.drawPath(deskPath, deskBodyPaint);

    // Counter top marble / slate trim
    final counterTopPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
      ).createShader(const Rect.fromLTWH(220, 265, 285, 18));

    final counterTopPath = Path()
      ..moveTo(222, 282)
      ..cubicTo(265, 270, 440, 270, 502, 285)
      ..lineTo(495, 296)
      ..cubicTo(435, 284, 265, 284, 227, 294)
      ..close();
    canvas.drawPath(counterTopPath, counterTopPaint);

    // Frosted glass accent panel on desk face
    final frostedPanelPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final panelBorderPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final panelPath = Path()
      ..moveTo(258, 304)
      ..cubicTo(295, 298, 415, 298, 460, 306)
      ..lineTo(456, 350)
      ..cubicTo(415, 344, 295, 344, 262, 350)
      ..close();
    canvas.drawPath(panelPath, frostedPanelPaint);
    canvas.drawPath(panelPath, panelBorderPaint);

    // Receptionist desk acrylic badge text
    final deskTextPainter = TextPainter(
      text: const TextSpan(
        text: 'RECEPTION & APPOINTMENTS',
        style: TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    deskTextPainter.paint(
      canvas,
      Offset(360 - (deskTextPainter.width / 2), 321),
    );

    // Desk LED under-glow line (Hospital Tech Accent)
    final ledGlowPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);

    final ledPath = Path()
      ..moveTo(238, 374)
      ..cubicTo(275, 384, 430, 384, 482, 374);
    canvas.drawPath(ledPath, ledGlowPaint);
  }

  // --------------------------------------------------------------------------
  // RECEPTIONIST (Professional corporate healthcare receptionist)
  // --------------------------------------------------------------------------
  void _drawReceptionist(Canvas canvas, Offset pos) {
    // Hair
    final hairPaint = Paint()..color = const Color(0xFF3E2723);
    final facePaint = Paint()..color = const Color(0xFFFFDFC4);

    // Hair bun / back
    canvas.drawCircle(Offset(pos.dx + 8, pos.dy - 12), 10, hairPaint);
    // Face
    canvas.drawCircle(Offset(pos.dx, pos.dy), 13, facePaint);
    // Front hair styling
    final frontHairPath = Path()
      ..moveTo(pos.dx - 12, pos.dy - 2)
      ..quadraticBezierTo(pos.dx, pos.dy - 16, pos.dx + 12, pos.dy - 4)
      ..quadraticBezierTo(pos.dx + 4, pos.dy - 10, pos.dx - 12, pos.dy - 2);
    canvas.drawPath(frontHairPath, hairPaint);

    // Welcoming facial expression (subtle smile & eye)
    final smilePaint = Paint()
      ..color = const Color(0xFFC47B62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx + 4, pos.dy + 3), width: 6, height: 4),
      0.1,
      math.pi * 0.8,
      false,
      smilePaint,
    );

    // Receptionist headset earpiece & mic (hospital appointment coordination)
    final headsetPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 6), width: 22, height: 16),
      -math.pi * 0.9,
      math.pi * 0.8,
      false,
      headsetPaint,
    );
    canvas.drawLine(
      Offset(pos.dx - 10, pos.dy - 4),
      Offset(pos.dx - 3, pos.dy + 7),
      headsetPaint,
    );
    canvas.drawCircle(
      Offset(pos.dx - 3, pos.dy + 7),
      1.6,
      Paint()..color = const Color(0xFF38BDF8),
    );

    // Professional Receptionist Uniform (Navy tailored jacket / blouse)
    final uniformPaint = Paint()..color = const Color(0xFF1E3A8A);
    final blousePaint = Paint()..color = Colors.white;

    // Body / Torso
    final torsoPath = Path()
      ..moveTo(pos.dx - 18, pos.dy + 15)
      ..lineTo(pos.dx + 18, pos.dy + 15)
      ..lineTo(pos.dx + 22, pos.dy + 85)
      ..lineTo(pos.dx - 18, pos.dy + 85)
      ..close();
    canvas.drawPath(torsoPath, uniformPaint);

    // White blouse collar inside jacket
    final collarPath = Path()
      ..moveTo(pos.dx - 6, pos.dy + 15)
      ..lineTo(pos.dx + 6, pos.dy + 15)
      ..lineTo(pos.dx, pos.dy + 30)
      ..close();
    canvas.drawPath(collarPath, blousePaint);

    // Corporate Hospital Lanyard & ID Badge
    final lanyardPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawLine(
      Offset(pos.dx - 4, pos.dy + 17),
      Offset(pos.dx, pos.dy + 36),
      lanyardPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + 4, pos.dy + 17),
      Offset(pos.dx, pos.dy + 36),
      lanyardPaint,
    );
    // Badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 4, pos.dy + 36, 9, 13),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 3, pos.dy + 38, 7, 3),
      Paint()..color = const Color(0xFF00B4D8),
    );

    // Right Arm: Welcoming gesture towards the counter & token
    final armPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pos.dx + 15, pos.dy + 25),
      Offset(pos.dx + 38, pos.dy + 56),
      armPaint,
    );
    // Hand
    canvas.drawCircle(Offset(pos.dx + 41, pos.dy + 58), 5.0, facePaint);
  }

  // --------------------------------------------------------------------------
  // PATIENT (Standing at desk, smart casual, holding check-in pass/phone)
  // --------------------------------------------------------------------------
  void _drawPatient(Canvas canvas, Offset pos) {
    // Floor shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx + 2, pos.dy + 168),
        width: 48,
        height: 12,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.38),
    );

    // Hair / Head
    final hairPaint = Paint()..color = const Color(0xFF27272A);
    final facePaint = Paint()..color = const Color(0xFFE0BB9B);

    canvas.drawCircle(Offset(pos.dx, pos.dy - 6), 13, hairPaint);
    canvas.drawCircle(Offset(pos.dx, pos.dy), 11, facePaint);

    // Patient Jacket / Shirt (Warm teal / smart slate jacket)
    final jacketPaint = Paint()..color = const Color(0xFF334155);
    final shirtPaint = Paint()..color = const Color(0xFFF1F5F9);

    // Torso
    final bodyPath = Path()
      ..moveTo(pos.dx - 16, pos.dy + 14)
      ..lineTo(pos.dx + 14, pos.dy + 14)
      ..lineTo(pos.dx + 16, pos.dy + 82)
      ..lineTo(pos.dx - 14, pos.dy + 82)
      ..close();
    canvas.drawPath(bodyPath, jacketPaint);

    // Inner t-shirt V-neck
    final innerPath = Path()
      ..moveTo(pos.dx - 6, pos.dy + 14)
      ..lineTo(pos.dx + 4, pos.dy + 14)
      ..lineTo(pos.dx - 1, pos.dy + 26)
      ..close();
    canvas.drawPath(innerPath, shirtPaint);

    // Left Arm holding registration pass / smartphone
    final armPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pos.dx - 12, pos.dy + 22),
      Offset(pos.dx - 26, pos.dy + 54),
      armPaint,
    );
    // Hand
    canvas.drawCircle(Offset(pos.dx - 27, pos.dy + 56), 4.8, facePaint);

    // Smartphone / Token pass in patient's hand
    final phonePaint = Paint()..color = const Color(0xFF0F172A);
    final phoneScreen = Paint()..color = const Color(0xFF34D399);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 36, pos.dy + 46, 12, 20),
        const Radius.circular(3),
      ),
      phonePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 34, pos.dy + 48, 8, 14),
        const Radius.circular(2),
      ),
      phoneScreen,
    );

    // Trousers
    final trousersPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 14, pos.dy + 82, 12, 78),
        const Radius.circular(3),
      ),
      trousersPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 2, pos.dy + 82, 12, 78),
        const Radius.circular(3),
      ),
      trousersPaint,
    );

    // Shoes
    final shoePaint = Paint()..color = const Color(0xFF020617);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 17, pos.dy + 160, 15, 8),
        const Radius.circular(3),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 2, pos.dy + 160, 15, 8),
        const Radius.circular(3),
      ),
      shoePaint,
    );
  }

  // --------------------------------------------------------------------------
  // DESK ACCESSORIES: COMPUTER MONITOR, TOKEN PRINTER, SCREEN GLOW
  // --------------------------------------------------------------------------
  void _drawDeskAccessories(Canvas canvas) {
    // Receptionist All-in-One Computer Monitor (facing receptionist)
    final monitorPaint = Paint()..color = const Color(0xFF0F172A);
    final standPaint = Paint()..color = const Color(0xFF94A3B8);
    final screenBackGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45);

    // Monitor stand
    canvas.drawRect(const Rect.fromLTWH(276, 260, 5, 20), standPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(270, 278, 18, 4),
        const Radius.circular(2),
      ),
      standPaint,
    );

    // Monitor bezel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(258, 230, 42, 32),
        const Radius.circular(4),
      ),
      monitorPaint,
    );

    // Soft glow emanating from receptionist's screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(261, 233, 36, 26),
        const Radius.circular(3),
      ),
      screenBackGlow,
    );

    // Mini appointment & queue schedule lines on receptionist's screen
    final uiLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(266, 239), const Offset(290, 239), uiLinePaint);
    canvas.drawLine(const Offset(266, 244), const Offset(284, 244), uiLinePaint);
    canvas.drawLine(
      const Offset(266, 249),
      const Offset(278, 249),
      Paint()
        ..color = const Color(0xFF38EF7D)
        ..strokeWidth = 1.2,
    );

    // Token Dispenser / Receipt Printer on Desk
    final printerPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(370, 268, 24, 18),
        const Radius.circular(4),
      ),
      printerPaint,
    );
    // Paper token slip coming out of printer
    final paperSlipPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(376, 262, 12, 8), paperSlipPaint);

    // Small RFID / Contactless Check-In Pad on counter
    final rfidPaint = Paint()..color = const Color(0xFF0F172A);
    final rfidIndicator = Paint()..color = const Color(0xFF34D399);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(425, 280, 22, 10),
        const Radius.circular(3),
      ),
      rfidPaint,
    );
    canvas.drawCircle(const Offset(436, 285), 2.2, rfidIndicator);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// PAINTER 3: ANIMATED ECG / MEDICAL PULSE WAVEFORM
// ============================================================================
class _EcgWavePainter extends CustomPainter {
  final double progress;

  _EcgWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    // Background faint guide grid
    final guidePaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), guidePaint);

    // Telemetry trace base path
    final path = Path();
    final width = size.width;

    // Wave template points (Normalized X from 0.0 to 1.0, Y offset from baseline)
    // P-Q-R-S-T wave pattern
    double getYForX(double xNorm) {
      // Repeat every 0.35 fraction of width
      final localX = (xNorm % 0.35) / 0.35;

      if (localX < 0.20) {
        return 0; // Baseline
      } else if (localX < 0.30) {
        // P Wave
        final p = (localX - 0.20) / 0.10;
        return -math.sin(p * math.pi) * 3.5;
      } else if (localX < 0.40) {
        return 0; // PR segment
      } else if (localX < 0.44) {
        // Q Dip
        final q = (localX - 0.40) / 0.04;
        return q * 3.0;
      } else if (localX < 0.52) {
        // R Spike (Large upward peak)
        final r = (localX - 0.44) / 0.08;
        return -math.sin(r * math.pi) * 16.0;
      } else if (localX < 0.58) {
        // S Drop
        final s = (localX - 0.52) / 0.06;
        return math.sin(s * math.pi) * 4.5;
      } else if (localX < 0.68) {
        return 0; // ST segment
      } else if (localX < 0.84) {
        // T Wave
        final t = (localX - 0.68) / 0.16;
        return -math.sin(t * math.pi) * 5.5;
      } else {
        return 0; // Baseline
      }
    }

    path.moveTo(0, midY);
    for (double x = 0; x <= width; x += 2.0) {
      final xNorm = x / width;
      final yOffset = getYForX(xNorm);
      path.lineTo(x, midY + yOffset);
    }

    // Draw full baseline trace in subtle teal
    final baseTracePaint = Paint()
      ..color = const Color(0xFF0E7490).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(path, baseTracePaint);

    // Active illuminated sweeping head & trail
    final sweepX = progress * width;
    final activeHeadX = sweepX;
    final activeHeadY = midY + getYForX(sweepX / width);

    // Trailing illuminated segment (last 55px)
    final trailLength = 55.0;
    final trailStart = (sweepX - trailLength).clamp(0.0, width);

    final trailPath = Path();
    trailPath.moveTo(trailStart, midY + getYForX(trailStart / width));
    for (double x = trailStart; x <= sweepX; x += 2.0) {
      trailPath.lineTo(x, midY + getYForX(x / width));
    }

    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF38EF7D).withValues(alpha: 0.0),
          const Color(0xFF38EF7D).withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromLTRB(trailStart, 0, sweepX + 1, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(trailPath, trailPaint);

    // Glowing point head
    final headGlowPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
    canvas.drawCircle(Offset(activeHeadX, activeHeadY), 3.5, headGlowPaint);

    final headCorePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(activeHeadX, activeHeadY), 1.8, headCorePaint);
  }

  @override
  bool shouldRepaint(covariant _EcgWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

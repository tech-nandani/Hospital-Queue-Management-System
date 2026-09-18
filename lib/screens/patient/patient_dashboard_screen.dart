import 'package:flutter/material.dart';

import '../../models/hospital_departments.dart';
import '../../models/patient_appointment.dart';
import '../../services/patient_api_service.dart';
import '../../services/patient_service.dart';
import '../../services/verification_service.dart';
import 'patient_records_screen.dart';
import 'symptom_assistant_screen.dart';
import '../../services/symptom_assistant_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final service = PatientService.instance;
  final verificationService = VerificationService.instance;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    service.addListener(_refresh);
    verificationService.addListener(_refresh);
    service.fetchProfileFromBackend();
    service.fetchAppointmentsFromBackend();
  }

  @override
  void dispose() {
    service.removeListener(_refresh);
    verificationService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F8FD),
      drawer: desktop
          ? null
          : Drawer(
              child: _PatientSideRail(
                selectedIndex: selectedIndex,
                onSelected: (index) {
                  setState(() => selectedIndex = index);
                  Navigator.pop(context);
                },
                onLogout: () => Navigator.pop(context),
                onHelpSupport: () {
                  Navigator.pop(context);
                  _showHelpSupportDialog(context);
                },
              ),
            ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (desktop)
                _PatientSideRail(
                  selectedIndex: selectedIndex,
                  onSelected: (index) => setState(() => selectedIndex = index),
                  onLogout: () => Navigator.pop(context),
                  onHelpSupport: () => _showHelpSupportDialog(context),
                ),
              Expanded(
                child: Column(
                  children: [
                    _PatientTopBar(
                      service: service,
                      onToggleDrawer: desktop
                          ? null
                          : () => _scaffoldKey.currentState?.openDrawer(),
                      onNavigate: (index) =>
                          setState(() => selectedIndex = index),
                      onNotifications: () => _showNotifications(context),
                      onLogout: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: [
                          _HomeTab(
                            service: service,
                            onBook: () => setState(() => selectedIndex = 2),
                            onQueue: () => setState(() => selectedIndex = 3),
                            onAssistant: () => setState(() => selectedIndex = 1),
                          ),
                          SymptomAssistantScreen(
                            onBookAppointment: (department) {
                              setState(() => selectedIndex = 2);
                            },
                          ),
                          _BookTab(
                            service: service,
                            verificationService: verificationService,
                            onNavigate: (index) =>
                                setState(() => selectedIndex = index),
                          ),
                          _AppointmentsTab(service: service),
                          PatientRecordsScreen(service: service),
                          _ProfileTab(
                            service: service,
                            onNavigate: (index) =>
                                setState(() => selectedIndex = index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (selectedIndex != 1)
            Positioned(
              bottom: 24,
              right: 28,
              child: _FloatingAIAssistantButton(
                onTap: () => setState(() => selectedIndex = 1),
              ),
            ),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE4F0FF),
              destinations: _patientDestinations,
            ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: Color(0xFF1D72FE)),
            SizedBox(width: 10),
            Text(
              'Help & Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HQM Care 24/7 Helpline',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text('📞 Toll-free: 1800-419-7890'),
            SizedBox(height: 12),
            Text(
              'Emergency Medical Services',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text('🚨 Emergency: 108 / 112'),
            SizedBox(height: 12),
            Text(
              'Email Support',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text('✉️ support@hqm-health.org'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static const List<NavigationDestination> _patientDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'AI Assistant',
    ),
    NavigationDestination(
      icon: Icon(Icons.add_box_outlined),
      selectedIcon: Icon(Icons.add_box_rounded),
      label: 'Book',
    ),
    NavigationDestination(
      icon: Icon(Icons.confirmation_number_outlined),
      selectedIcon: Icon(Icons.confirmation_number_rounded),
      label: 'My visits',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder_rounded),
      label: 'Records',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  void _showNotifications(BuildContext context) {
    final notifications = service.notifications;
    service.markNotificationsRead();
    final notificationWidgets = <Widget>[
      Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: service.markNotificationsRead,
              child: const Text('Mark read'),
            ),
        ],
      ),
      const SizedBox(height: 12),
    ];

    if (notifications.isEmpty) {
      notificationWidgets.add(
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.info_outline, color: Color(0xFF1976D2)),
          ),
          title: Text('No new notifications'),
          subtitle: Text('Your appointment updates will appear here.'),
        ),
      );
    } else {
      notificationWidgets.addAll(
        notifications
            .take(5)
            .map(
              (notification) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF3FF),
                  child: Icon(
                    notification.title.contains('cancel')
                        ? Icons.event_busy_outlined
                        : Icons.event_available_outlined,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                title: Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(notification.message),
              ),
            ),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notificationWidgets,
        ),
      ),
    );
  }
}

class _PatientAvatarPainter extends CustomPainter {
  final Color skinColor;
  final Color hairColor;
  final Color shirtColor;

  _PatientAvatarPainter({
    this.skinColor = const Color(0xFFFFDFC4),
    this.hairColor = const Color(0xFF2B2020),
    this.shirtColor = const Color(0xFFF472B6),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()..color = const Color(0xFFEDE9FE);
    canvas.drawCircle(center, radius, bgPaint);

    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    final shirtPaint = Paint()..color = shirtColor;
    final shirtRect = Rect.fromCenter(
      center: Offset(center.dx, size.height * 1.08),
      width: size.width * 0.95,
      height: size.height * 0.7,
    );
    canvas.drawOval(shirtRect, shirtPaint);

    final neckPaint = Paint()..color = skinColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.70),
        width: size.width * 0.22,
        height: size.height * 0.24,
      ),
      neckPaint,
    );

    final hairPaint = Paint()..color = hairColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.44),
        width: size.width * 0.65,
        height: size.height * 0.65,
      ),
      hairPaint,
    );

    final facePaint = Paint()..color = skinColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.48),
        width: size.width * 0.48,
        height: size.height * 0.48,
      ),
      facePaint,
    );

    final bangsPath = Path();
    bangsPath.moveTo(center.dx - size.width * 0.24, size.height * 0.42);
    bangsPath.quadraticBezierTo(
      center.dx - size.width * 0.12,
      size.height * 0.26,
      center.dx,
      size.height * 0.38,
    );
    bangsPath.quadraticBezierTo(
      center.dx + size.width * 0.12,
      size.height * 0.26,
      center.dx + size.width * 0.24,
      size.height * 0.42,
    );
    bangsPath.lineTo(center.dx + size.width * 0.30, size.height * 0.26);
    bangsPath.quadraticBezierTo(
      center.dx,
      size.height * 0.16,
      center.dx - size.width * 0.30,
      size.height * 0.26,
    );
    bangsPath.close();
    canvas.drawPath(bangsPath, hairPaint);

    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final leftEye = Offset(center.dx - size.width * 0.105, size.height * 0.48);
    final rightEye = Offset(center.dx + size.width * 0.105, size.height * 0.48);
    canvas.drawCircle(leftEye, size.width * 0.038, eyePaint);
    canvas.drawCircle(rightEye, size.width * 0.038, eyePaint);

    final catchPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(leftEye.dx - 1, leftEye.dy - 1),
      size.width * 0.014,
      catchPaint,
    );
    canvas.drawCircle(
      Offset(rightEye.dx - 1, rightEye.dy - 1),
      size.width * 0.014,
      catchPaint,
    );

    final blushPaint = Paint()
      ..color = const Color(0xFFFB7185).withOpacity(0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.15, size.height * 0.55),
        width: size.width * 0.09,
        height: size.height * 0.05,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.15, size.height * 0.55),
        width: size.width * 0.09,
        height: size.height * 0.05,
      ),
      blushPaint,
    );

    final smilePaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.032;
    final smilePath = Path();
    smilePath.moveTo(center.dx - size.width * 0.065, size.height * 0.56);
    smilePath.quadraticBezierTo(
      center.dx,
      size.height * 0.62,
      center.dx + size.width * 0.065,
      size.height * 0.56,
    );
    canvas.drawPath(smilePath, smilePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PatientAvatarWidget extends StatelessWidget {
  final double size;
  final bool showCameraBadge;

  const PatientAvatarWidget({
    super.key,
    required this.size,
    this.showCameraBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _PatientAvatarPainter(),
          ),
          if (showCameraBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D72FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientSideRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;
  final VoidCallback onHelpSupport;

  const _PatientSideRail({
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
    required this.onHelpSupport,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'AI Assistant'),
    (Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Book Appointment'),
    (Icons.description_outlined, Icons.description_rounded, 'My Visits'),
    (Icons.folder_outlined, Icons.folder_rounded, 'Medical Records'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFF43F5E),
                      size: 26,
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D72FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CareFlow',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // PATIENT SPACE Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PATIENT SPACE',
                        style: TextStyle(
                          color: Color(0xFF4338CA),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your Health, Our Priority',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Navigation Links & Support (Scrollable for responsiveness)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(_items.length, (index) {
                    final selected = selectedIndex == index;
                    final item = _items[index];
                    final isAiAssistant = index == 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () => onSelected(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1D72FE)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF1D72FE)
                                              .withValues(alpha: 0.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected ? item.$2 : item.$1,
                                    size: 20,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    item.$3,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                      fontSize: 13,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isAiAssistant && selected)
                          _buildAiAssistantSubmenu(),
                      ],
                    );
                  }),

                  // Help & Support
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: onHelpSupport,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.headset_mic_outlined,
                              size: 20,
                              color: Color(0xFF475569),
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Help & Support',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Items: Patient Account & Logout
          InkWell(
            onTap: () => onSelected(5),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: const Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Patient Account',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantSubmenu() {
    return ListenableBuilder(
      listenable: SymptomAssistantService.instance,
      builder: (context, _) {
        final aiService = SymptomAssistantService.instance;
        final recentSessions = aiService.sessions
            .where((s) => s.messages.isNotEmpty)
            .toList();

        return Container(
          margin: const EdgeInsets.only(top: 2, bottom: 8, left: 6, right: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // + New Chat button
              InkWell(
                onTap: () {
                  aiService.createNewSession();
                  onSelected(1);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCE7F5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 15,
                        color: Color(0xFF1D72FE),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '+ New Chat',
                        style: TextStyle(
                          color: Color(0xFF1D72FE),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (recentSessions.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 5),
                  child: Text(
                    'RECENT CHATS',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...recentSessions.take(4).map((session) {
                  final isActive = session.id == aiService.activeSessionId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: InkWell(
                      onTap: () {
                        aiService.selectSession(session.id);
                        onSelected(1);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE0EDFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 12,
                              color: isActive
                                  ? const Color(0xFF1D72FE)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFF1D72FE)
                                      : const Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PatientTopBar extends StatelessWidget {
  final PatientService service;
  final VoidCallback? onToggleDrawer;
  final ValueChanged<int> onNavigate;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  const _PatientTopBar({
    required this.service,
    this.onToggleDrawer,
    required this.onNavigate,
    required this.onNotifications,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final account = service.account;
    final name = (account != null && account.name.isNotEmpty)
        ? account.name
        : 'Nandani Singh';

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF334155), size: 24),
            onPressed: onToggleDrawer ?? () {},
            tooltip: 'Menu',
          ),
          const SizedBox(width: 12),
          // Search Pill
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search doctors, appointments, medical records...',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Notification Bell with dynamic unread badge
          IconButton(
            tooltip: 'Notifications',
            onPressed: onNotifications,
            icon: Badge(
              isLabelVisible: service.unreadNotificationCount > 0,
              label: Text(
                '${service.unreadNotificationCount}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFEF4444),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF334155),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Chip
          InkWell(
            onTap: () => onNavigate(5),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PatientAvatarWidget(size: 36),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Patient',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingAIAssistantButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingAIAssistantButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(38),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D72FE).withOpacity(0.38),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFF93C5FD), width: 2.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final PatientService service;
  final VoidCallback onBook;
  final VoidCallback onQueue;
  final VoidCallback onAssistant;

  const _HomeTab({
    required this.service,
    required this.onBook,
    required this.onQueue,
    required this.onAssistant,
  });

  @override
  Widget build(BuildContext context) {
    final account = service.account;
    final appointment = service.activeAppointment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        Text(
          'Hello, ${(account != null && account.name.trim().isNotEmpty) ? account.name.trim().split(' ').first : 'there'}',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage your visits with less waiting.',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        const SizedBox(height: 22),
        _QueueCard(appointment: appointment, onBook: onBook, onQueue: onQueue),
        const SizedBox(height: 24),
        InkWell(
          onTap: onAssistant,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F5F0),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFCDEBE2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFF16806A)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Not sure which doctor to choose? Ask the AI Care Assistant.',
                    style: TextStyle(
                      color: Color(0xFF16324F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: Color(0xFF16806A)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _showEmergency(context),
          icon: const Icon(Icons.emergency_rounded),
          label: const Text('Emergency assistance'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD95757),
            side: const BorderSide(color: Color(0xFFE9A7A7)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Book visit',
                color: const Color(0xFFEAF3FF),
                iconColor: const Color(0xFF1976D2),
                onTap: onBook,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.confirmation_number_rounded,
                title: 'My queue',
                color: const Color(0xFFE5F5F0),
                iconColor: const Color(0xFF16806A),
                onTap: onQueue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.medical_services_outlined,
                title: 'Find doctors',
                subtitle: 'Browse departments',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.access_time_rounded,
                title: 'Wait times',
                subtitle: 'Plan your visit',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEmergency(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency assistance'),
        content: const Text(
          'For severe or life-threatening symptoms, call your local emergency number or go to the nearest emergency department immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Call emergency'),
          ),
        ],
      ),
    );
  }
}

class _BookTab extends StatefulWidget {
  final PatientService service;
  final VerificationService verificationService;
  final ValueChanged<int>? onNavigate;

  const _BookTab({
    required this.service,
    required this.verificationService,
    this.onNavigate,
  });

  @override
  State<_BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<_BookTab> {
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _doctors = [];
  Map<String, dynamic>? _selectedDept;
  Map<String, dynamic>? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime = '09:30 AM';
  final TextEditingController _notesController = TextEditingController();

  bool _loadingDepts = true;
  bool _loadingDoctors = false;
  bool _isSubmitting = false;

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loadingDepts = true);
    try {
      final depts = await PatientApiService.instance.getDepartments(
        token: widget.service.authToken,
      );
      if (!mounted) return;
      if (depts.isNotEmpty) {
        setState(() {
          _departments = depts;
          _selectedDept = depts.first;
          _loadingDepts = false;
        });
        if (_selectedDept?['id'] != null) {
          _loadDoctors(_selectedDept!['id'] as int);
        }
      } else {
        _useFallbackDepartments();
      }
    } catch (_) {
      if (mounted) {
        _useFallbackDepartments();
      }
    }
  }

  void _useFallbackDepartments() {
    final fallback = hospitalDepartments.asMap().entries.map((e) => {
      'id': e.key + 1,
      'name': e.value,
      'description': 'Department of ${e.value}',
    }).toList();
    setState(() {
      _departments = fallback;
      _selectedDept = fallback.isNotEmpty ? fallback.first : null;
      _loadingDepts = false;
    });
    if (_selectedDept?['id'] != null) {
      _loadDoctors(_selectedDept!['id'] as int);
    }
  }

  Future<void> _loadDoctors(int deptId) async {
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
      _selectedDoctor = null;
    });
    try {
      final docs = await PatientApiService.instance.getDoctors(
        token: widget.service.authToken,
        departmentId: deptId,
      );
      if (!mounted) return;
      setState(() {
        _doctors = docs;
        if (docs.isNotEmpty) {
          _selectedDoctor = docs.first;
        }
        _loadingDoctors = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDoctors = false);
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} ${_shortMonths[dt.month - 1]} ${dt.year}';

  String _formatDateFull(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} ${_fullMonths[dt.month - 1]} ${dt.year}';

  String _weekday(DateTime dt) => _weekdays[dt.weekday - 1];
  String _month(DateTime dt) => _shortMonths[dt.month - 1];

  IconData _departmentIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cardio')) return Icons.favorite_rounded;
    if (lower.contains('derma')) return Icons.auto_awesome_rounded;
    if (lower.contains('pediatric') || lower.contains('child')) return Icons.child_care_rounded;
    if (lower.contains('gynec') || lower.contains('female')) return Icons.pregnant_woman_rounded;
    if (lower.contains('ortho') || lower.contains('bone')) return Icons.accessibility_new_rounded;
    if (lower.contains('neuro')) return Icons.psychology_rounded;
    if (lower.contains('dental')) return Icons.medication_rounded;
    if (lower.contains('eye') || lower.contains('ophthal')) return Icons.visibility_rounded;
    return Icons.medical_services_outlined;
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor to continue.')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preferred time slot.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final docId = _selectedDoctor!['id'] as int;
      final docName = _selectedDoctor!['name'] as String? ?? 'Doctor';
      final deptName = _selectedDept?['name'] as String? ?? 'General Medicine';

      final appointment = await widget.service.bookAppointmentWithBackend(
        doctorId: docId,
        departmentName: deptName,
        doctorName: docName,
        date: _selectedDate,
        time: _selectedTime!,
        reason: _notesController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _notesController.clear();

      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Queue Token #${appointment.queueNumber}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1D72FE)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _dialogInfoRow('Doctor', appointment.doctor),
                    const SizedBox(height: 6),
                    _dialogInfoRow('Department', appointment.department),
                    const SizedBox(height: 6),
                    _dialogInfoRow('Date & Time', '${_formatDate(appointment.date)}, ${appointment.time}'),
                    const SizedBox(height: 6),
                    _dialogInfoRow('Hospital', appointment.hospitalName),
                    const SizedBox(height: 6),
                    _dialogInfoRow('Estimated Wait', '~${appointment.estimatedWaitMinutes} mins'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigate?.call(3);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D72FE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View in My Visits', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done', style: TextStyle(color: Color(0xFF64748B))),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  static Widget _dialogInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _rescheduleAppointment(PatientAppointment apt) async {
    DateTime tempDate = apt.date.isBefore(DateTime.now()) ? DateTime.now() : apt.date;
    String tempTime = apt.time;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF1D72FE), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Reschedule Visit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment with ${apt.doctor} (${apt.department})',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Select New Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                            initialDate: tempDate,
                          );
                          if (picked != null) {
                            setDialogState(() => tempDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Color(0xFF1D72FE), size: 18),
                              const SizedBox(width: 10),
                              Text(_formatDateFull(tempDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Select New Time Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeSlots.map((slot) {
                          final isSelected = tempTime == slot;
                          return InkWell(
                            onTap: () => setDialogState(() => tempTime = slot),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1D72FE) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1D72FE)),
                  child: const Text('Confirm Reschedule'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true && mounted) {
      try {
        await widget.service.rescheduleAppointmentWithBackend(
          id: apt.id,
          date: tempDate,
          time: tempTime,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment rescheduled successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reschedule: $e')),
          );
        }
      }
    }
  }

  Future<void> _cancelAppointment(PatientAppointment apt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 10),
            Text('Cancel Appointment?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with ${apt.doctor} on ${_formatDate(apt.date)} at ${apt.time}?\nThis will release your queue token #${apt.queueNumber}.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Appointment', style: TextStyle(color: Color(0xFF64748B))),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.service.cancelAppointmentWithBackend(apt.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel appointment: $e')),
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDoctor = _doctors.isNotEmpty ? _doctors.first : null;
      _selectedDate = DateTime.now();
      _selectedTime = '09:30 AM';
      _notesController.clear();
    });
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF1D72FE),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book an Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Choose a department, doctor and a convenient time.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0EFFF), Color(0xFFF0F6FE)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Text(
                  'Your Health Our Priority',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    required String number,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF1D72FE),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D72FE),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDepartmentSection() {
    if (_loadingDepts) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D72FE)),
        ),
      );
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _departments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final dept = _departments[index];
          final isSelected = _selectedDept?['id'] == dept['id'];
          final name = dept['name'] as String? ?? 'Department';
          final icon = _departmentIcon(name);

          return InkWell(
            onTap: () {
              if (_selectedDept?['id'] != dept['id']) {
                setState(() => _selectedDept = dept);
                _loadDoctors(dept['id'] as int);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 130,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1D72FE).withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1D72FE).withOpacity(0.12)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsSection() {
    if (_loadingDoctors) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D72FE)),
            ),
            SizedBox(width: 10),
            Text('Finding available doctors...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    if (_doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'No approved doctors listed in ${_selectedDept?['name'] ?? 'this department'} currently.',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 580 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 2 ? 3.0 : 3.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
          ),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doc = _doctors[index];
            final isSelected = _selectedDoctor?['id'] == doc['id'];
            final name = doc['name'] as String? ?? 'Doctor';
            final qual = doc['qualification'] as String? ?? 'MBBS, MD';
            final specialty = doc['specialty'] as String? ??
                (_selectedDept?['name'] as String? ?? 'Specialist');

            return InkWell(
              onTap: () => setState(() => _selectedDoctor = doc),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1D72FE).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFF1F5F9),
                      child: Text(
                        name.replaceAll('Dr.', '').trim().isNotEmpty
                            ? name.replaceAll('Dr.', '').trim().substring(0, 1).toUpperCase()
                            : 'D',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$qual • $specialty',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1D72FE),
                        size: 20,
                      )
                    else
                      const Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimeSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 580;
        final dateWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              number: '3',
              title: 'Select Date',
              subtitle: 'Choose your appointment date',
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  initialDate: _selectedDate,
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Color(0xFF1D72FE), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDateFull(_selectedDate),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
                  ],
                ),
              ),
            ),
          ],
        );

        final timeWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              number: '4',
              title: 'Select Time',
              subtitle: 'Available time slots',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTime == slot;
                return InkWell(
                  onTap: () => setState(() => _selectedTime = slot),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1D72FE) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1D72FE) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1D72FE).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 42, child: dateWidget),
              const SizedBox(width: 20),
              Expanded(flex: 58, child: timeWidget),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateWidget,
              const SizedBox(height: 18),
              timeWidget,
            ],
          );
        }
      },
    );
  }

  Widget _buildNotesAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          number: '5',
          title: 'Add Notes (Optional)',
          subtitle: 'Briefly explain the reason for your visit',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'E.g. Briefly describe your symptoms or concern...',
            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D72FE), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _bookAppointment,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'Booking...' : 'Confirm Appointment',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D72FE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightSidebar() {
    final appointments = widget.service.appointments;
    final upcoming = appointments.where((a) =>
        a.status == PatientAppointmentStatus.upcoming ||
        a.status == PatientAppointmentStatus.waiting).toList();
    final past = appointments.where((a) =>
        a.status == PatientAppointmentStatus.completed ||
        a.status == PatientAppointmentStatus.cancelled).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: My Upcoming Appointments
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF1D72FE), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'My Upcoming Appointments',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => widget.onNavigate?.call(3),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'View All ➔',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1D72FE)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcoming.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text(
                    'No upcoming appointments scheduled.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcoming.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final apt = upcoming[index];
                    return _buildUpcomingAppointmentItem(apt);
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Card 2: Past Appointments
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_rounded, color: Color(0xFF64748B), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Past Appointments',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => widget.onNavigate?.call(3),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'View All ➔',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1D72FE)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (past.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: const Text(
                    'No past appointments.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: past.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final apt = past[index];
                    return _buildPastAppointmentItem(apt);
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Card 3: Need to cancel or reschedule?
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE6F7F9), Color(0xFFF0FAFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule_rounded, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need to cancel or reschedule?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You can reschedule or cancel appointments up to 2 hours before the scheduled time with no penalty.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF0284C7),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointmentItem(PatientAppointment apt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      apt.date.day.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D72FE),
                      ),
                    ),
                    Text(
                      _month(apt.date),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    Text(
                      _weekday(apt.date),
                      style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.doctor,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      apt.department,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF1D72FE)),
                        const SizedBox(width: 4),
                        Text(
                          apt.time,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D72FE)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            apt.hospitalName,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _rescheduleAppointment(apt),
                icon: const Icon(Icons.schedule_rounded, size: 14),
                label: const Text('Reschedule', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1D72FE),
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _cancelAppointment(apt),
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Cancel Appointment', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointmentItem(PatientAppointment apt) {
    final isCancelled = apt.status == PatientAppointmentStatus.cancelled;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  apt.date.day.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                Text(
                  _month(apt.date),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt.doctor,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${apt.department} • ${apt.time}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCancelled ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isCancelled ? 'Cancelled' : 'Completed',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;

        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            const SizedBox(height: 22),
            _buildStepHeader(
              number: '1',
              title: 'Select Department',
              subtitle: 'Choose the department you want to visit',
              actionLabel: 'View all departments ➔',
              onAction: () {},
            ),
            const SizedBox(height: 12),
            _buildDepartmentSection(),
            const SizedBox(height: 22),
            _buildStepHeader(
              number: '2',
              title: 'Select Doctor',
              subtitle: 'Choose a doctor from the selected department',
              actionLabel: 'View all doctors ➔',
              onAction: () {},
            ),
            const SizedBox(height: 12),
            _buildDoctorsSection(),
            const SizedBox(height: 22),
            _buildDateTimeSection(),
            const SizedBox(height: 22),
            _buildNotesAndActions(),
          ],
        );

        final rightColumn = _buildRightSidebar();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 63, child: leftColumn),
                    const SizedBox(width: 24),
                    Expanded(flex: 37, child: rightColumn),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftColumn,
                    const SizedBox(height: 32),
                    rightColumn,
                  ],
                ),
        );
      },
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final PatientService service;

  const _AppointmentsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final appointments = service.appointments;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _PageIntro(
          title: 'My visits',
          subtitle: 'Track active queues and appointment history.',
        ),
        const SizedBox(height: 18),
        if (appointments.isEmpty)
          const _EmptyState(
            icon: Icons.event_note_outlined,
            text: 'No appointments yet. Book your first visit to see it here.',
          )
        else
          ...appointments.reversed.map(
            (appointment) => _AppointmentTile(
              appointment: appointment,
              onCancel:
                  appointment.status == PatientAppointmentStatus.upcoming ||
                      appointment.status == PatientAppointmentStatus.waiting
                  ? () => _cancel(context, appointment)
                  : null,
              onReschedule:
                  appointment.status == PatientAppointmentStatus.upcoming ||
                      appointment.status == PatientAppointmentStatus.waiting
                  ? () => _reschedule(context, appointment)
                  : null,
              onFeedback:
                  appointment.status == PatientAppointmentStatus.completed
                  ? () => _feedback(context, appointment)
                  : null,
            ),
          ),
      ],
    );
  }

  void _cancel(BuildContext context, PatientAppointment appointment) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text('This will release your queue number.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () {
              service.cancelAppointmentWithBackend(appointment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled.')),
              );
            },
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
  }

  Future<void> _reschedule(
    BuildContext context,
    PatientAppointment appointment,
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDate: appointment.date.isBefore(DateTime.now())
          ? DateTime.now()
          : appointment.date,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;

    final formattedTime = time.format(context);
    await service.rescheduleAppointmentWithBackend(
      id: appointment.id,
      date: date,
      time: formattedTime,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment rescheduled.')));
    }
  }

  void _feedback(BuildContext context, PatientAppointment appointment) {
    int rating = 5;
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate your visit'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setDialogState(() => rating = index + 1),
                icon: Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFFB020),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () {
                service.addFeedback(
                  appointmentId: appointment.id,
                  rating: rating,
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final PatientService service;
  final ValueChanged<int> onNavigate;

  const _ProfileTab({
    required this.service,
    required this.onNavigate,
  });

  String _formatDob(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '12 March 2002';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = service.account;
    final name = (account != null && account.name.isNotEmpty)
        ? account.name
        : 'Nandani Singh';
    final email = (account != null && account.email.isNotEmpty)
        ? account.email
        : 'ashoknandanik@gmail.com';
    final mobile = (account != null && account.mobile.isNotEmpty)
        ? account.mobile
        : '8369725879';
    final gender = (account != null &&
            account.gender != null &&
            account.gender!.isNotEmpty)
        ? account.gender!
        : 'Female';
    final dob = _formatDob(account?.dateOfBirth);
    final address = (account != null &&
            account.address != null &&
            account.address!.trim().isNotEmpty)
        ? account.address!
        : 'Not provided';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. TOP HEADER: "My Profile" + "Good Health" Pill
              // ==========================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Keep your contact details ready for every visit.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Good Health Brighter Tomorrows Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFD6E6FB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEEF1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monitor_heart_rounded,
                            color: Color(0xFFF43F5E),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Health',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Brighter Tomorrows',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ==========================================
              // 2. HERO PROFILE SUMMARY CARD
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cute Avatar with camera badge
                    const PatientAvatarWidget(
                      size: 88,
                      showCameraBadge: true,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Patient',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Member since 07 Sept 2025',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '“Take care of your health, it’s the greatest wealth.”',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1D72FE),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================
              // 3. TWO-COLUMN DETAILS: Personal Info & Quick Actions
              // ==========================================
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildPersonalInfoCard(
                        context: context,
                        name: name,
                        email: email,
                        mobile: mobile,
                        dob: dob,
                        gender: gender,
                        address: address,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 5,
                      child: _buildQuickActionsCard(context),
                    ),
                  ],
                )
              else ...[
                _buildPersonalInfoCard(
                  context: context,
                  name: name,
                  email: email,
                  mobile: mobile,
                  dob: dob,
                  gender: gender,
                  address: address,
                ),
                const SizedBox(height: 20),
                _buildQuickActionsCard(context),
              ],

              const SizedBox(height: 22),

              // ==========================================
              // 4. BOTTOM BANNER: "Your Health Matters"
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF1F6FE), Color(0xFFF8FAFD)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EAF8)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEEF2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          color: Color(0xFFF43F5E),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Health Matters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Keep your profile updated for a smoother and faster experience at every visit.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Stay Healthy\nStay Happy ♡',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF818CF8).withOpacity(0.85),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoCard({
    required BuildContext context,
    required String name,
    required String email,
    required String mobile,
    required String dob,
    required String gender,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_outlined,
                color: Color(0xFF1D72FE),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showEditProfileDialog(context),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Color(0xFF1D72FE),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFF1D72FE),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.person_outline_rounded, 'Full Name', name),
          _infoRow(Icons.mail_outline_rounded, 'Email', email),
          _infoRow(Icons.phone_outlined, 'Mobile Number', mobile),
          _infoRow(Icons.calendar_month_outlined, 'Date of Birth', dob),
          _infoRow(Icons.female_rounded, 'Gender', gender),
          _infoRow(Icons.location_on_outlined, 'Address', address, isLast: true),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: Color(0xFF1D72FE),
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _actionTile(
            icon: Icons.calendar_today_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1D72FE),
            title: 'Book New Appointment',
            subtitle: 'Schedule your next visit',
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.receipt_long_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'View My Visits',
            subtitle: 'Check your appointment history',
            onTap: () => onNavigate(3),
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.folder_open_rounded,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: 'Access Medical Records',
            subtitle: 'View your reports and prescriptions',
            onTap: () => onNavigate(4),
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.settings_outlined,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'Update Profile',
            subtitle: 'Keep your information up to date',
            onTap: () => _showEditProfileDialog(context),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF1D72FE),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final account = service.account;
    final initialName = (account != null && account.name.isNotEmpty)
        ? account.name
        : 'Nandani Singh';
    final initialMobile = (account != null && account.mobile.isNotEmpty)
        ? account.mobile
        : '8369725879';
    final initialAddress = (account != null &&
            account.address != null &&
            account.address!.trim().isNotEmpty)
        ? account.address!
        : '';
    final initialDob = (account != null &&
            account.dateOfBirth != null &&
            account.dateOfBirth!.isNotEmpty)
        ? account.dateOfBirth!
        : '2002-03-12';
    String? initialGender = (account != null &&
            account.gender != null &&
            account.gender!.isNotEmpty)
        ? account.gender
        : 'Female';

    if (initialGender != null) {
      final normalized = initialGender.trim().toLowerCase();
      if (normalized == 'female' || normalized == 'f') {
        initialGender = 'Female';
      } else if (normalized == 'male' || normalized == 'm') {
        initialGender = 'Male';
      } else if (normalized == 'other' || normalized == 'o') {
        initialGender = 'Other';
      } else {
        initialGender = 'Female';
      }
    }
    String? selectedGender = initialGender;

    final nameController = TextEditingController(text: initialName);
    final mobileController = TextEditingController(text: initialMobile);
    final addressController = TextEditingController(text: initialAddress);
    final dobController = TextEditingController(text: initialDob);
    DateTime? selectedDate;
    try {
      selectedDate = DateTime.parse(initialDob);
    } catch (_) {
      selectedDate = DateTime(2002, 3, 12);
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogStateContext, setDialogState) {
            Future<void> pickDob() async {
              final picked = await showDatePicker(
                context: dialogStateContext,
                initialDate: selectedDate ?? DateTime(2002, 3, 12),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setDialogState(() {
                  selectedDate = picked;
                  dobController.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Color(0xFF1D72FE)),
                  SizedBox(width: 10),
                  Text(
                    'Edit Health Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: _dialogInputDecoration(
                          hint: 'Enter full name',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: _dialogInputDecoration(
                          hint: 'Enter mobile number',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        hint: const Text('Select gender'),
                        decoration: _dialogInputDecoration(
                          hint: 'Select gender',
                          icon: Icons.wc_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          setDialogState(() => selectedGender = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: pickDob,
                        borderRadius: BorderRadius.circular(14),
                        child: IgnorePointer(
                          child: TextField(
                            controller: dobController,
                            decoration: _dialogInputDecoration(
                              hint: 'Select date of birth',
                              icon: Icons.calendar_month_outlined,
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Color(0xFF6B7A8C),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: _dialogInputDecoration(
                          hint: 'Enter residential address',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        mobileController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name and mobile cannot be empty.')),
                      );
                      return;
                    }
                    try {
                      await service.updateProfileWithBackend(
                        name: nameController.text.trim(),
                        mobile: mobileController.text.trim(),
                        dateOfBirth: dobController.text.trim().isNotEmpty
                            ? dobController.text.trim()
                            : null,
                        gender: selectedGender,
                        address: addressController.text.trim().isNotEmpty
                            ? addressController.text.trim()
                            : null,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF10B981),
                            content: Text('Profile updated and saved to backend successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D72FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1D72FE), size: 20),
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E1EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E1EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1D72FE), width: 1.5),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final PatientAppointment? appointment;
  final VoidCallback onBook;
  final VoidCallback onQueue;

  const _QueueCard({
    required this.appointment,
    required this.onBook,
    required this.onQueue,
  });

  @override
  Widget build(BuildContext context) {
    if (appointment == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 14),
            const Text(
              'No active queue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Book an appointment to get your queue number.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1976D2),
                elevation: 0,
              ),
              child: const Text('Book appointment'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16324F),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: Color(0xFF8ED7C2),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'LIVE QUEUE STATUS',
                style: TextStyle(
                  color: Color(0xFF8ED7C2),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Queue #${appointment!.queueNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${appointment!.department} • ${appointment!.doctor}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appointment!.estimatedWaitMinutes} min estimated wait',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onQueue,
                child: const Text(
                  'View details',
                  style: TextStyle(color: Color(0xFF8ED7C2)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final PatientAppointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onFeedback;

  const _AppointmentTile({
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2EAF3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFEAF3FF),
              child: Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF1976D2),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appointment.department,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16324F),
                ),
              ),
            ),
            _StatusPill(status: appointment.status.name),
          ],
        ),
        const SizedBox(height: 12),
        Text('${appointment.doctor} • ${appointment.time}'),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF718096)),
            const SizedBox(width: 4),
            Text(
              appointment.hospitalName,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Queue #${appointment.queueNumber} • ${appointment.estimatedWaitMinutes} min estimated wait',
          style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
        ),
        if (onCancel != null)
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              if (onReschedule != null)
                TextButton.icon(
                  onPressed: onReschedule,
                  icon: const Icon(Icons.edit_calendar_outlined, size: 17),
                  label: const Text('Reschedule'),
                ),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 17),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD95757),
                ),
              ),
            ],
          )
        else if (onFeedback != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onFeedback,
              icon: const Icon(Icons.star_outline_rounded, size: 17),
              label: const Text('Rate visit'),
            ),
          ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'cancelled'
        ? const Color(0xFFD95757)
        : status == 'completed'
        ? const Color(0xFF16806A)
        : const Color(0xFF1976D2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageIntro({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: Color(0xFF718096))),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF34495E),
    ),
  );
}

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    hint: Text(hint),
    items: items
        .map((item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
        .toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
      ),
      prefixIcon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF1976D2),
      ),
    ),
  );
}

class _InputShell extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InputShell({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2EAF3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2)),
        const SizedBox(width: 12),
        Text(text),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF16324F),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE2EAF3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16324F),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2EAF3)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 38, color: const Color(0xFF9AA8B7)),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF718096)),
        ),
      ],
    ),
  );
}

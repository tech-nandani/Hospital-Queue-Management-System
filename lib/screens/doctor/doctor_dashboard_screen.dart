import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/doctor_service.dart';
import '../../services/patient_api_service.dart';
import '../../services/queue_service.dart';
import '../../services/verification_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/careflow_floating_ai.dart';
import '../../widgets/doctor_sidebar.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String? doctorName;
  final String? department;
  final int? doctorId;

  const DoctorDashboardScreen({
    super.key,
    this.doctorName,
    this.department,
    this.doctorId,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final QueueService _queue = QueueService.instance;
  final DoctorService _doctor = DoctorService.instance;

  int _selectedIndex = 0;
  String _searchQuery = '';
  QueuePatient? _selectedPatientForConsult;

  // Dynamic Doctor Profile Info
  late String _effectiveDoctorName;
  late String _effectiveDepartment;
  late int _effectiveDoctorId;
  String _doctorQualification = 'MBBS, MD';
  String _doctorSpecialty = 'General Medicine';
  String _consultationHours = '09:00 AM - 05:00 PM';

  // Full Appointments List across dates
  List<QueuePatient> _allAppointments = [];
  bool _isLoadingAppointments = false;

  // Filters
  String _appointmentStatusFilter = 'All'; // All, Upcoming, Today, Completed, Cancelled
  String _appointmentPriorityFilter = 'All'; // All, Normal, High, Emergency
  String _analyticsRange = 'Today'; // Today, 7 Days, 30 Days

  // Digital Prescription Form in Tab 6
  QueuePatient? _rxSelectedPatient;
  final List<_MedicationEntry> _rxMedications = [
    _MedicationEntry(
      nameController: TextEditingController(),
      dosageController: TextEditingController(text: '500mg'),
      frequencyController: TextEditingController(text: '1-0-1 (Twice daily)'),
      durationController: TextEditingController(text: '5 Days'),
      instructionsController: TextEditingController(text: 'After meals with water'),
    ),
  ];
  final TextEditingController _rxGeneralAdviceCtrl = TextEditingController(text: 'Adequate hydration and bed rest advised.');
  bool _isSavingRx = false;

  @override
  void initState() {
    super.initState();
    _initDoctorContext();
    _queue.addListener(_onQueueChanged);
    _doctor.addListener(_onQueueChanged);
    _refreshData();
  }

  void _initDoctorContext() {
    final staff = VerificationService.instance.currentStaff;
    if (staff != null && staff.role.toLowerCase() == 'doctor') {
      _effectiveDoctorName = staff.name;
      _effectiveDepartment = staff.department;
      _effectiveDoctorId = int.tryParse(staff.id) ?? widget.doctorId ?? 1;
    } else {
      _effectiveDoctorName = widget.doctorName ?? 'Doctor';
      _effectiveDepartment = widget.department ?? 'General Medicine';
      _effectiveDoctorId = widget.doctorId ?? 1;
    }
  }

  @override
  void dispose() {
    _queue.removeListener(_onQueueChanged);
    _doctor.removeListener(_onQueueChanged);
    for (final med in _rxMedications) {
      med.dispose();
    }
    _rxGeneralAdviceCtrl.dispose();
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshData() async {
    _queue.fetchQueue(doctorId: _effectiveDoctorId, department: _effectiveDepartment);
    _fetchDoctorProfile();
    _fetchAppointments();
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final doctors = await PatientApiService.instance.getDoctorAvailability();
      final doc = doctors.firstWhere(
        (d) => d['id'] == _effectiveDoctorId,
        orElse: () => <String, dynamic>{},
      );
      if (doc.isNotEmpty && mounted) {
        setState(() {
          if (doc['name'] != null && doc['name'].toString().isNotEmpty) {
            _effectiveDoctorName = doc['name'].toString();
          }
          if (doc['qualification'] != null) {
            _doctorQualification = doc['qualification'].toString();
          }
          if (doc['specialty'] != null && doc['specialty'].toString().isNotEmpty) {
            _doctorSpecialty = doc['specialty'].toString();
          }
          final isAvail = doc['is_available'] as bool? ?? true;
          _doctor.setAvailability(isAvail ? 'Available' : 'Busy');

          final start = doc['consultation_start']?.toString();
          final end = doc['consultation_end']?.toString();
          if (start != null && end != null) {
            _consultationHours = '$start - $end';
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoadingAppointments = true);
    try {
      final data = await PatientApiService.instance.getStaffAppointments(
        doctorId: _effectiveDoctorId,
      );
      final list = <QueuePatient>[];
      for (final item in data) {
        try {
          list.add(QueuePatient.fromJson(item));
        } catch (e) {
          debugPrint('Error parsing staff appointment: $e');
        }
      }
      if (mounted) {
        setState(() {
          _allAppointments = list;
          _isLoadingAppointments = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      if (mounted) setState(() => _isLoadingAppointments = false);
    }
  }

  void _startConsultationForPatient(QueuePatient patient) {
    setState(() {
      _selectedPatientForConsult = patient;
      _selectedIndex = 4; // Navigate to Consultation tab
    });
    _queue.startConsultation(patient.id);
  }

  void _logout() {
    VerificationService.instance.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ============================================================
  // DYNAMIC NOTIFICATIONS GENERATOR
  // ============================================================

  List<_DoctorNotification> _getDynamicNotifications() {
    final list = <_DoctorNotification>[];

    for (final p in _queue.patients) {
      if (p.priority == 'Emergency' && p.status != 'Completed' && p.status != 'Cancelled') {
        list.add(_DoctorNotification(
          icon: Icons.emergency_rounded,
          title: 'Emergency Case Alert',
          subtitle: '${p.name} (Token #${p.token}) requires immediate triage attention.',
          color: AppColors.emergency,
          time: p.time,
        ));
      } else if (p.priority == 'High' && p.status != 'Completed' && p.status != 'Cancelled') {
        list.add(_DoctorNotification(
          icon: Icons.priority_high_rounded,
          title: 'High Priority Patient',
          subtitle: '${p.name} (Token #${p.token}) is waiting in queue.',
          color: AppColors.warning,
          time: p.time,
        ));
      } else if (p.status == 'Calling') {
        list.add(_DoctorNotification(
          icon: Icons.campaign_rounded,
          title: 'Now Calling Patient',
          subtitle: 'Token #${p.token} (${p.name}) called to $_effectiveDepartment.',
          color: AppColors.secondary,
          time: p.time,
        ));
      } else if (p.status == 'Checked-in' || p.status == 'Waiting') {
        list.add(_DoctorNotification(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Patient in Queue',
          subtitle: '${p.name} (Token #${p.token}) registered for ${p.reason}.',
          color: AppColors.primary,
          time: p.time,
        ));
      } else if (p.status == 'Completed') {
        list.add(_DoctorNotification(
          icon: Icons.task_alt_rounded,
          title: 'Consultation Completed',
          subtitle: 'Finished consultation for ${p.name} (Token #${p.token}).',
          color: AppColors.success,
          time: p.time,
        ));
      }
    }

    return list;
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768 && width < 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const CareFlowFloatingAI(role: 'Doctor'),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.mainText,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('CareFlow', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Sync Queue',
                  onPressed: _refreshData,
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Logout',
                  onPressed: _logout,
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: DoctorSidebar(
                selectedIndex: _selectedIndex,
                onSelected: (i) {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = i);
                },
                doctorName: _effectiveDoctorName,
                specialization: _effectiveDepartment,
                onLogout: _logout,
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop)
            DoctorSidebar(
              selectedIndex: _selectedIndex,
              onSelected: (i) => setState(() => _selectedIndex = i),
              doctorName: _effectiveDoctorName,
              specialization: _effectiveDepartment,
              onLogout: _logout,
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(isDesktop),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _buildCurrentView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: (isDesktop || isTablet)
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex.clamp(0, 4),
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.queue_outlined), selectedIcon: Icon(Icons.queue_rounded), label: 'Queue'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Appts'),
                NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt_rounded), label: 'Patients'),
                NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services_rounded), label: 'Consult'),
              ],
            ),
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  String get _doctorGreetingName {
    final name = _effectiveDoctorName.trim();
    if (name.isEmpty || name.toLowerCase() == 'doctor') return 'Doctor';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].toLowerCase().startsWith('dr')) {
      return '${parts[0]} ${parts[1]}';
    }
    if (name.toLowerCase().startsWith('dr')) {
      return name;
    }
    return 'Dr. ${parts.first}';
  }

  String _shortWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _shortMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }

  void _showDoctorProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 12),
              Text(_effectiveDoctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
              Text('$_effectiveDepartment • $_doctorSpecialty', style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppColors.mainText),
                title: const Text('Account Settings'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedIndex = 10);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isDesktop) {
    final now = DateTime.now();
    final dateHeaderStr = '${_shortWeekday(now.weekday)}, ${now.day} ${_shortMonth(now.month)} ${now.year}';
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final timeHeaderStr = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search patients, tokens, appointments, or records...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.secondaryText),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                if (_queue.isLoading || _isLoadingAppointments)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          // Date & Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '$dateHeaderStr, $timeHeaderStr',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.mainText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Notification Bell with Red Badge
          IconButton(
            tooltip: 'Notifications',
            icon: const Badge(
              smallSize: 8,
              backgroundColor: AppColors.error,
              isLabelVisible: true,
              child: Icon(Icons.notifications_outlined, color: AppColors.mainText, size: 22),
            ),
            onPressed: () => _showNotificationsModal(context),
          ),
          const SizedBox(width: 10),
          // Doctor Profile
          InkWell(
            onTap: () => _showDoctorProfileMenu(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _effectiveDoctorName,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.mainText),
                        ),
                        Text(
                          _effectiveDepartment,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.secondaryText),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB ROUTING
  // ============================================================

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 1:
        return _buildFullQueueView();
      case 2:
        return _buildAppointmentsView();
      case 3:
        return _buildPatientsDirectoryView();
      case 4:
        return _buildConsultationScreen();
      case 5:
        return _buildMedicalRecordsView();
      case 6:
        return _buildPrescriptionsView();
      case 7:
        return _buildScheduleView();
      case 8:
        return _buildReportsView();
      case 9:
        return _buildNotificationsPageView();
      case 10:
        return _buildSettingsView();
      default:
        return _buildDashboardOverview();
    }
  }

  // ============================================================
  // 0. DASHBOARD OVERVIEW (REFERENCE SAAS DESIGN)
  // ============================================================

  Widget _buildDashboardOverview() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. WELCOME BANNER (Soft Light Cyan Gradient with Quotes & Hospital Graphic)
        _buildWelcomeBanner(),

        const SizedBox(height: 20),

        // 2. 4 DYNAMIC STATISTICS CARDS
        _buildStatCards(),

        const SizedBox(height: 20),

        // 3. MAIN 2-COLUMN SECTION (62% Left, 38% Right)
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN (~62%)
                  Expanded(
                    flex: 62,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTodayQueueCard(),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildQueueOverviewChartCard()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildQuickActionsCard()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // RIGHT COLUMN (~38%)
                  Expanded(
                    flex: 38,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTodayScheduleCard(),
                        const SizedBox(height: 20),
                        _buildPriorityPatientsCard(),
                      ],
                    ),
                  ),
                ],
              );
            }
            // Mobile / Tablet: Stack vertically
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodayQueueCard(),
                const SizedBox(height: 20),
                _buildTodayScheduleCard(),
                const SizedBox(height: 20),
                _buildPriorityPatientsCard(),
                const SizedBox(height: 20),
                _buildQueueOverviewChartCard(),
                const SizedBox(height: 20),
                _buildQuickActionsCard(),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // 4. FULL-WIDTH AI ASSISTANT BANNER
        _buildAIAssistantBanner(),
      ],
    );
  }

  // ============================================================
  // WELCOME BANNER
  // ============================================================

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              children: [
                // Left: Doctor Greeting
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_timeGreeting, $_doctorGreetingName! 👋',
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your dedication makes a difference. Here’s what’s happening today.',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Center Quote Card
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '“Patients are not just numbers, they are people who trust us.”',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right Hospital Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_hospital_rounded, color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Together for a\nHealthier Tomorrow',
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          // Narrow screen
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_timeGreeting, $_doctorGreetingName!',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Your dedication makes a difference. Here’s what’s happening today.',
                style: TextStyle(color: Color(0xFF475569), fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATISTICS CARDS (100% DYNAMIC)
  // ============================================================

  Widget _buildStatCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 550 && constraints.maxWidth < 900;

        final card1 = _buildStatCard(
          title: 'Total Patients Today',
          value: '${_queue.totalPatients}',
          subtitlePill: '↑ 12%',
          subtitleText: 'Compared to yesterday',
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFDBEAFE),
        );
        final card2 = _buildStatCard(
          title: 'Patients in Queue',
          value: '${_queue.queueCount}',
          subtitlePill: null,
          subtitleText: '${_queue.waitingCount} waiting • ${_queue.consultationCount} in consultation',
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFD97706),
          iconBgColor: const Color(0xFFFEF3C7),
        );
        final card3 = _buildStatCard(
          title: 'Average Waiting Time',
          value: '${_queue.averageWaitingMinutes} min',
          subtitlePill: '↓ 20%',
          subtitleText: 'Compared to last week',
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFF7C3AED),
          iconBgColor: const Color(0xFFEDE9FE),
        );
        final card4 = _buildStatCard(
          title: 'Completed Today',
          value: '${_queue.completedCount}',
          subtitlePill: '↑ 8%',
          subtitleText: 'Out of ${_queue.totalPatients} patients',
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF16A34A),
          iconBgColor: const Color(0xFFDCFCE7),
        );

        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 16),
              Expanded(child: card2),
              const SizedBox(width: 16),
              Expanded(child: card3),
              const SizedBox(width: 16),
              Expanded(child: card4),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 16),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 16),
                  Expanded(child: card4),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              card1,
              const SizedBox(height: 12),
              card2,
              const SizedBox(height: 12),
              card3,
              const SizedBox(height: 12),
              card4,
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitlePill,
    String? subtitleText,
    required IconData icon,
    Color? iconColor,
    Color? iconBgColor,
    Color? color,
    Color? lightColor,
  }) {
    final effectiveColor = iconColor ?? color ?? AppColors.primary;
    final effectiveBgColor = iconBgColor ?? lightColor ?? AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          if (subtitleText != null || subtitlePill != null)
            Row(
              children: [
                if (subtitlePill != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitlePill,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (subtitleText != null)
                  Expanded(
                    child: Text(
                      subtitleText,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTodayQueueCard() {
    final filtered = _queue.patients.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.token.toString().contains(q) ||
          p.phone.contains(q) ||
          p.reason.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Queue",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Real-time patient queue for $_effectiveDepartment',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // "+ Call Next Patient" solid blue button
              ElevatedButton.icon(
                onPressed: _callNextPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Call Next Patient', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _buildEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: "No patients in today's queue",
              subtitle: 'No patients are currently waiting for consultation.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 700),
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 18,
                  headingRowHeight: 38,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 58,
                  headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Token No.')),
                    DataColumn(label: Text('Patient Name')),
                    DataColumn(label: Text('Age / Gender')),
                    DataColumn(label: Text('Appointment Time')),
                    DataColumn(label: Text('Priority')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List.generate(filtered.take(5).length, (index) {
                    final patient = filtered[index];
                    final tokenFormatted = 'P-${patient.token.toString().padLeft(3, '0')}';
                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                        DataCell(
                          Text(
                            tokenFormatted,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ),
                        DataCell(
                          Text(
                            patient.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${patient.age > 0 ? patient.age : "--"} / ${patient.gender.isNotEmpty ? (patient.gender.startsWith("M") ? "M" : (patient.gender.startsWith("F") ? "F" : "O")) : "--"}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ),
                        DataCell(
                          Text(
                            patient.time,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ),
                        DataCell(_buildPriorityBadgePill(patient.priority)),
                        DataCell(_buildStatusBadgePill(patient.status)),
                        DataCell(
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              backgroundColor: const Color(0xFFEFF6FF),
                              side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.visibility_outlined, size: 14),
                            label: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            onPressed: () => _viewPatientDetailsDialog(patient),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadgePill(String priority) {
    Color bg;
    Color text;
    IconData icon;
    String label;

    switch (priority.toLowerCase()) {
      case 'emergency':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        icon = Icons.error_outline_rounded;
        label = 'Emergency';
        break;
      case 'high':
      case 'urgent':
        bg = const Color(0xFFFFEDD5);
        text = const Color(0xFFEA580C);
        icon = Icons.priority_high_rounded;
        label = 'Urgent';
        break;
      default:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        icon = Icons.check_circle_outline_rounded;
        label = 'Normal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text)),
        ],
      ),
    );
  }

  Widget _buildStatusBadgePill(String status) {
    Color bg;
    Color text;
    IconData icon;
    String label = status;

    switch (status.toLowerCase()) {
      case 'calling':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF2563EB);
        icon = Icons.volume_up_rounded;
        label = 'Calling';
        break;
      case 'in_consultation':
      case 'in consultation':
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF9333EA);
        icon = Icons.medical_services_outlined;
        label = 'In Consultation';
        break;
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        icon = Icons.check_rounded;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFEF4444);
        icon = Icons.close_rounded;
        label = 'Cancelled';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        icon = Icons.access_time_rounded;
        label = 'Waiting';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text)),
        ],
      ),
    );
  }

  // ============================================================
  // QUEUE OVERVIEW DONUT CHART
  // ============================================================

  Widget _buildQueueOverviewChartCard() {
    final waiting = _queue.waitingCount;
    final inConsult = _queue.consultationCount;
    final completed = _queue.completedCount;
    final cancelled = _queue.patients.where((p) => p.status == 'Cancelled').length;
    final total = waiting + inConsult + completed + cancelled + _queue.callingCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.donut_large_rounded, color: Color(0xFF2563EB), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Queue Overview',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Today', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut Chart
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          sections: total == 0
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: const Color(0xFFE2E8F0),
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                ]
                              : [
                                  if (waiting > 0)
                                    PieChartSectionData(
                                      value: waiting.toDouble(),
                                      color: const Color(0xFF3B82F6),
                                      radius: 16,
                                      showTitle: false,
                                    ),
                                  if (inConsult > 0)
                                    PieChartSectionData(
                                      value: inConsult.toDouble(),
                                      color: const Color(0xFF8B5CF6),
                                      radius: 16,
                                      showTitle: false,
                                    ),
                                  if (completed > 0)
                                    PieChartSectionData(
                                      value: completed.toDouble(),
                                      color: const Color(0xFF10B981),
                                      radius: 16,
                                      showTitle: false,
                                    ),
                                  if (cancelled > 0)
                                    PieChartSectionData(
                                      value: cancelled.toDouble(),
                                      color: const Color(0xFFF59E0B),
                                      radius: 16,
                                      showTitle: false,
                                    ),
                                ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Legend
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOverviewLegendItem('Waiting', waiting, const Color(0xFF3B82F6)),
                    _buildOverviewLegendItem('In Consultation', inConsult, const Color(0xFF8B5CF6)),
                    _buildOverviewLegendItem('Completed', completed, const Color(0xFF10B981)),
                    _buildOverviewLegendItem('Cancelled', cancelled, const Color(0xFFF59E0B)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewLegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
          Text('$count', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS (2x2 GRID)
  // ============================================================

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFF2563EB), size: 18),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionTile(
                  icon: Icons.medical_services_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'Start Consultation',
                  subtitle: 'New patient',
                  onTap: () {
                    final next = _queue.patients.where((p) => p.status == 'Calling' || p.status == 'Waiting' || p.status == 'In Consultation').firstOrNull;
                    if (next != null) {
                      _startConsultationForPatient(next);
                    } else {
                      setState(() => _selectedIndex = 4);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionTile(
                  icon: Icons.folder_shared_rounded,
                  iconColor: const Color(0xFF9333EA),
                  iconBg: const Color(0xFFFAF5FF),
                  title: 'View Patient History',
                  subtitle: 'Access medical records',
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFF0FDF4),
                  title: 'Write Prescription',
                  subtitle: 'Create & manage',
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionTile(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFFEA580C),
                  iconBg: const Color(0xFFFFF7ED),
                  title: 'Manage Schedule',
                  subtitle: 'View your timetable',
                  onTap: () => setState(() => _selectedIndex = 7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TODAY'S SCHEDULE (TIMELINE LIST)
  // ============================================================

  Widget _buildTodayScheduleCard() {
    final appointments = _queue.patients;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2563EB), size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Schedule",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (appointments.isEmpty)
            _buildEmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'No appointments scheduled',
              subtitle: 'No appointments on today’s calendar for your clinic.',
            )
          else ...[
            ...List.generate(appointments.length > 5 ? 5 : appointments.length, (index) {
              final apt = appointments[index];
              final isCompleted = apt.status.toLowerCase() == 'completed';
              final isCalling = apt.status.toLowerCase() == 'calling' || apt.status.toLowerCase().contains('consult');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 65,
                      child: Text(
                        apt.time.length > 8 ? apt.time.substring(0, 5) : apt.time,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : (isCalling ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${apt.name} (P-${apt.token.toString().padLeft(3, '0')})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Lunch Break row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 65,
                    child: Text('01:00 PM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_rounded, size: 12, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text('Lunch Break', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PRIORITY PATIENTS
  // ============================================================

  Widget _buildPriorityPatientsCard() {
    final priorities = _queue.patients
        .where((p) => (p.priority.toLowerCase() == 'high' || p.priority.toLowerCase() == 'emergency') && p.status != 'Completed' && p.status != 'Cancelled')
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFDC2626), size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Priority Patients',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (priorities.isEmpty)
            _buildEmptyState(
              icon: Icons.done_all_rounded,
              title: 'No priority patients',
              subtitle: 'No emergency or urgent patients in queue right now.',
            )
          else
            Column(
              children: priorities.take(3).map((p) {
                final isEmergency = p.priority.toLowerCase() == 'emergency';
                final accentColor = isEmergency ? const Color(0xFFEF4444) : const Color(0xFFF97316);
                final tokenFormatted = 'P-${p.token.toString().padLeft(3, '0')}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _startConsultationForPatient(p),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(width: 3.5, color: accentColor),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '$tokenFormatted • ${p.name}',
                                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                _buildPriorityBadgePill(p.priority),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${p.age > 0 ? p.age : "--"} / ${p.gender.isNotEmpty ? (p.gender.startsWith("M") ? "M" : (p.gender.startsWith("F") ? "F" : "O")) : "--"} • Reason: ${p.reason.isNotEmpty ? p.reason : "Clinical evaluation"}',
                                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  p.time,
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FULL-WIDTH AI ASSISTANT BANNER
  // ============================================================

  Widget _buildAIAssistantBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;
          if (isWide) {
            return Row(
              children: [
                // Robot Avatar
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                // Heading & Subtitle
                const Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Your AI Assistant is here! 🤖',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Get real-time insights, summarize patient history, suggest next steps and more.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Quick prompt chips
                Expanded(
                  flex: 5,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      _buildAIPromptChip('Summarize patient history'),
                      _buildAIPromptChip("Who's next in my queue?"),
                      _buildAIPromptChip("Show today's appointments"),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // AI Assistant Button
                ElevatedButton.icon(
                  onPressed: () => CareFlowFloatingAI.open(context, role: 'Doctor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('AI Assistant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          }
          // Narrow layout
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your AI Assistant is here! 🤖',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => CareFlowFloatingAI.open(context, role: 'Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('AI Assistant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildAIPromptChip('Summarize patient history'),
                  _buildAIPromptChip("Who's next in my queue?"),
                  _buildAIPromptChip("Show today's appointments"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAIPromptChip(String prompt) {
    return ActionChip(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDDD6FE)),
      label: Text(prompt, style: const TextStyle(fontSize: 10.5, color: Color(0xFF5B21B6), fontWeight: FontWeight.w600)),
      onPressed: () => CareFlowFloatingAI.open(context, role: 'Doctor', initialPrompt: prompt),
    );
  }

  // ============================================================
  // 1. TODAY'S QUEUE (FULL PAGE)
  // ============================================================

  Widget _buildFullQueueView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Patient Queue", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  Text('Complete patient triage, status management, and live examination dispatch', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _callNextPatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.campaign_rounded, size: 18),
              label: const Text('Call Next Patient'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTodayQueueCard(),
      ],
    );
  }

  // ============================================================
  // 2. APPOINTMENTS (FULL PAGE WITH DYNAMIC FILTERS)
  // ============================================================

  Widget _buildAppointmentsView() {
    final list = _allAppointments.where((apt) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = apt.name.toLowerCase().contains(q) ||
            apt.token.toString().contains(q) ||
            apt.phone.contains(q) ||
            apt.reason.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // Filter by Status Tab
      if (_appointmentStatusFilter == 'Upcoming') {
        if (apt.status != 'Waiting' && apt.status != 'Checked-in') return false;
      } else if (_appointmentStatusFilter == 'Today') {
        // Handled by date or current queue
      } else if (_appointmentStatusFilter == 'Completed') {
        if (apt.status != 'Completed') return false;
      } else if (_appointmentStatusFilter == 'Cancelled') {
        if (apt.status != 'Cancelled' && apt.status != 'No Show') return false;
      }

      // Filter by Priority
      if (_appointmentPriorityFilter != 'All') {
        if (apt.priority != _appointmentPriorityFilter) return false;
      }

      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doctor Appointments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  Text('Comprehensive appointments roster and consultation schedule', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reload Appointments',
              onPressed: _fetchAppointments,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // FILTER BAR
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Status Tabs
            ...['All', 'Upcoming', 'Today', 'Completed', 'Cancelled'].map((status) {
              final isSel = _appointmentStatusFilter == status;
              return ChoiceChip(
                label: Text(status),
                selected: isSel,
                onSelected: (_) => setState(() => _appointmentStatusFilter = status),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.mainText,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
              );
            }),
            const SizedBox(width: 12),
            // Priority Dropdown Filter
            DropdownButton<String>(
              value: _appointmentPriorityFilter,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Priorities', style: TextStyle(fontSize: 12.5))),
                DropdownMenuItem(value: 'Normal', child: Text('Normal Priority', style: TextStyle(fontSize: 12.5))),
                DropdownMenuItem(value: 'High', child: Text('High Priority', style: TextStyle(fontSize: 12.5))),
                DropdownMenuItem(value: 'Emergency', child: Text('Emergency Only', style: TextStyle(fontSize: 12.5))),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _appointmentPriorityFilter = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (_isLoadingAppointments)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (list.isEmpty)
          _buildEmptyState(
            icon: Icons.calendar_today_rounded,
            title: 'No appointments found',
            subtitle: 'No appointment records matching the current filter criteria.',
          )
        else
          ...list.map((p) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        child: Text('#${p.token}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                                const SizedBox(width: 8),
                                _buildPriorityBadge(p.priority),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('Time: ${p.time} • ${p.age} yrs • Reason: ${p.reason}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(p.status),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => _viewPatientDetailsDialog(p),
                        child: const Text('Details', style: TextStyle(fontSize: 12)),
                      ),
                      if (p.status != 'Completed') ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _startConsultationForPatient(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Consult', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 3. PATIENTS CLINICAL DIRECTORY & HISTORY
  // ============================================================

  Widget _buildPatientsDirectoryView() {
    // Unique patients aggregated across queue and appointments
    final seenIds = <String>{};
    final distinctPatients = <QueuePatient>[];
    for (final p in [..._queue.patients, ..._allAppointments]) {
      final key = p.phone.isNotEmpty ? p.phone : p.name;
      if (!seenIds.contains(key)) {
        seenIds.add(key);
        distinctPatients.add(p);
      }
    }

    final filtered = distinctPatients.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.phone.contains(q) || p.reason.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Patient Clinical Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Search registered patients, view past visits, diagnoses, and medical histories', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (filtered.isEmpty)
          _buildEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No patient records found',
            subtitle: 'Patients will appear once scheduled or registered with your department.',
          )
        else
          ...filtered.map((p) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryLight,
                    child: const Icon(Icons.person_rounded, color: AppColors.secondary),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  subtitle: Text('Mobile: ${p.phone.isEmpty ? "N/A" : p.phone} • Gender: ${p.gender} • Age: ${p.age}y\nLatest Symptom: ${p.reason}'),
                  isThreeLine: true,
                  trailing: OutlinedButton.icon(
                    onPressed: () => _viewPatientDetailsDialog(p),
                    icon: const Icon(Icons.folder_shared_outlined, size: 16),
                    label: const Text('View Clinical History'),
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 4. CONSULTATION WORKSPACE
  // ============================================================

  Widget _buildConsultationScreen() {
    return _ConsultationScreenWidget(
      patient: _selectedPatientForConsult ??
          _queue.patients.where((p) => p.status == 'In Consultation').firstOrNull ??
          _queue.patients.where((p) => p.status == 'Calling').firstOrNull ??
          _queue.patients.where((p) => p.status == 'Waiting').firstOrNull,
      availablePatients: _queue.patients.where((p) => p.status != 'Completed' && p.status != 'Cancelled').toList(),
      onSelectPatient: (p) => setState(() => _selectedPatientForConsult = p),
      onComplete: (patientId) {
        setState(() {
          _selectedPatientForConsult = null;
          _selectedIndex = 0; // Return to Dashboard
        });
        _refreshData();
      },
    );
  }

  // ============================================================
  // 5. MEDICAL RECORDS VIEW
  // ============================================================

  Widget _buildMedicalRecordsView() {
    final completed = _allAppointments.where((p) => p.status == 'Completed').toList();
    final filtered = completed.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.diagnosis != null && p.diagnosis!.toLowerCase().contains(q)) ||
          p.token.toString().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Consultation Records & Medical History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Archived clinical notes, diagnoses, and digital prescriptions recorded for your patients', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (filtered.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No completed consultations yet',
            subtitle: 'Complete consultations from your queue to archive medical records here.',
          )
        else
          ...filtered.map((p) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.successLight,
                            child: Text('#${p.token}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                Text('${p.age}y • ${p.gender} • Token #${p.token} • ${p.time}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              ],
                            ),
                          ),
                          _buildStatusBadge('Completed'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 8),
                      Text('Primary Diagnosis: ${p.diagnosis?.isNotEmpty == true ? p.diagnosis! : "Clinical examination conducted"}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Clinical Notes: ${p.clinicalNotes?.isNotEmpty == true ? p.clinicalNotes! : "Patient stable. Follow-up advised if symptoms recur."}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      const SizedBox(height: 6),
                      Text('Prescription: ${p.prescription?.isNotEmpty == true ? p.prescription! : "Standard supportive medication"}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      if (p.treatmentAdvice != null && p.treatmentAdvice!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Advice: ${p.treatmentAdvice}', style: const TextStyle(fontSize: 11.5, color: AppColors.mainText)),
                      ],
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 6. PRESCRIPTIONS MODULE (INTERACTIVE DIGITAL RX BUILDER)
  // ============================================================

  Widget _buildPrescriptionsView() {
    final availablePatients = _queue.patients.isNotEmpty ? _queue.patients : _allAppointments;
    final issuedPrescriptions = _allAppointments.where((p) => p.prescription != null && p.prescription!.isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Digital Prescriptions Module', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Generate, digitally sign, and issue structured prescriptions for patient appointments', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),

        // 1. GENERATE NEW RX CARD
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text('Create New Digital Prescription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  ],
                ),
                const SizedBox(height: 16),

                // Select Patient
                DropdownButtonFormField<QueuePatient>(
                  initialValue: _rxSelectedPatient ?? availablePatients.firstOrNull,
                  decoration: InputDecoration(
                    labelText: 'Select Patient from Queue/Appointments *',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                  items: availablePatients.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p.name} (Token #${p.token}) - ${p.reason}', style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (p) => setState(() => _rxSelectedPatient = p),
                ),
                const SizedBox(height: 20),

                // Structured Medicine Rows
                const Text('Medications List (Rx)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                const SizedBox(height: 12),

                ...List.generate(_rxMedications.length, (index) {
                  final item = _rxMedications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 10, backgroundColor: AppColors.primary, child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800))),
                            const SizedBox(width: 8),
                            const Text('Medication Entry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            if (_rxMedications.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                tooltip: 'Remove Medication',
                                onPressed: () => setState(() => _rxMedications.removeAt(index)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: item.nameController,
                                decoration: const InputDecoration(labelText: 'Medicine Name *', hintText: 'e.g. Amoxicillin', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: item.dosageController,
                                decoration: const InputDecoration(labelText: 'Dosage', hintText: '500mg', isDense: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: item.frequencyController,
                                decoration: const InputDecoration(labelText: 'Frequency', hintText: '1-0-1 (Twice daily)', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: item.durationController,
                                decoration: const InputDecoration(labelText: 'Duration', hintText: '5 Days', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: item.instructionsController,
                                decoration: const InputDecoration(labelText: 'Instructions', hintText: 'After food', isDense: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Add Medicine Button
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _rxMedications.add(_MedicationEntry(
                        nameController: TextEditingController(),
                        dosageController: TextEditingController(text: '1 Tab'),
                        frequencyController: TextEditingController(text: '1-0-1'),
                        durationController: TextEditingController(text: '3 Days'),
                        instructionsController: TextEditingController(text: 'After meals'),
                      ));
                    });
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Another Medicine'),
                ),
                const SizedBox(height: 16),

                // General Advice
                TextField(
                  controller: _rxGeneralAdviceCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'General Instructions & Dietary Advice',
                    hintText: 'Avoid strenuous activity, drink warm fluids...',
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isSavingRx ? null : _saveDigitalPrescription,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Save & Issue Prescription'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final pat = _rxSelectedPatient ?? availablePatients.firstOrNull;
                        if (pat != null) {
                          _showPrescriptionPreviewDialog(pat);
                        }
                      },
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Preview & Print Digital Rx'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 2. RECENTLY ISSUED PRESCRIPTIONS
        const Text('Recently Issued Prescriptions History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 12),

        if (issuedPrescriptions.isEmpty)
          _buildEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No prescriptions issued yet',
            subtitle: 'Prescriptions issued during consultations or generated above will appear here.',
          )
        else
          ...issuedPrescriptions.map((p) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: const Icon(Icons.medication_rounded, color: AppColors.primary)),
                  title: Text('${p.name} (Token #${p.token})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('Rx: ${p.prescription}\nIssued on: ${p.time} • Dept: ${p.department}'),
                  isThreeLine: true,
                  trailing: FilledButton.tonal(
                    onPressed: () => _showPrescriptionPreviewDialog(p),
                    child: const Text('View Rx'),
                  ),
                ),
              )),
      ],
    );
  }

  void _saveDigitalPrescription() async {
    final patient = _rxSelectedPatient ?? (_queue.patients.isNotEmpty ? _queue.patients.first : null);
    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a patient first.')));
      return;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < _rxMedications.length; i++) {
      final m = _rxMedications[i];
      final name = m.nameController.text.trim();
      if (name.isNotEmpty) {
        buffer.writeln('${i + 1}. $name (${m.dosageController.text.trim()}) - ${m.frequencyController.text.trim()} for ${m.durationController.text.trim()} [${m.instructionsController.text.trim()}]');
      }
    }

    if (buffer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least one medicine name.')));
      return;
    }

    setState(() => _isSavingRx = true);
    final prescriptionText = buffer.toString().trim();

    await _queue.completePatient(
      patient.id,
      prescription: prescriptionText,
      treatmentAdvice: _rxGeneralAdviceCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSavingRx = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Digital prescription saved and issued for ${patient.name}.'),
        backgroundColor: AppColors.success,
      ),
    );
    _refreshData();
  }

  void _showPrescriptionPreviewDialog(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('City Care Hospital, Lucknow', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('Outpatient Department Digital Prescription', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Doctor: $_effectiveDoctorName', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    Text('Date: ${_month(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  ],
                ),
                Text('$_effectiveDepartment • $_doctorQualification', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                const Divider(height: 18),
                Text('Patient: ${p.name} (#${p.token})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                Text('Age / Gender: ${p.age}y / ${p.gender} • Mobile: ${p.phone.isEmpty ? "N/A" : p.phone}', style: const TextStyle(fontSize: 11.5)),
                if (p.reason.isNotEmpty) Text('Clinical Reason: ${p.reason}', style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                const SizedBox(height: 14),
                const Text('Rx Medications:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                const SizedBox(height: 6),
                Text(p.prescription?.isNotEmpty == true ? p.prescription! : "1. Tab Paracetamol 650mg - 1-0-1 after food (3 days)\n2. Tab Cetirizine 10mg - 0-0-1 at night (5 days)", style: const TextStyle(fontSize: 12, height: 1.4)),
                const SizedBox(height: 12),
                if (p.treatmentAdvice?.isNotEmpty == true) Text('Advice: ${p.treatmentAdvice}', style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic)),
                const Divider(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Digitally Verified & Signed by Doctor\nCareFlow Health System', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription sent to print queue / downloaded as PDF.')));
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Print / Save PDF'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. SCHEDULE VIEW (FULL CLINIC AVAILABILITY & TIMELINE)
  // ============================================================

  Widget _buildScheduleView() {
    final todayAppointments = _queue.patients;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Consultation Hours & Clinic Schedule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Configure clinic availability, consultation windows, and monitor today’s patient time slots', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),

        // CLINIC STATUS CARD
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _doctor.availability == 'Available' ? AppColors.successLight : AppColors.warningLight,
                  child: Icon(Icons.access_time_rounded, color: _doctor.availability == 'Available' ? AppColors.success : AppColors.warning),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinic Operational Hours: $_consultationHours', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('Standard Lunch & Clinical Break: 01:00 PM - 02:00 PM', style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Switch(
                  value: _doctor.availability == 'Available',
                  activeThumbColor: AppColors.success,
                  onChanged: (val) async {
                    final newStatus = val ? 'Available' : 'Busy';
                    _doctor.setAvailability(newStatus);
                    await PatientApiService.instance.toggleDoctorAvailability(_effectiveDoctorId, val);
                    _fetchDoctorProfile();
                  },
                ),
                const SizedBox(width: 8),
                Text(_doctor.availability, style: TextStyle(fontWeight: FontWeight.w700, color: _doctor.availability == 'Available' ? AppColors.success : AppColors.warning)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // TODAY'S TIMELINE SLOTS
        const Text("Today's Patient Time Slot Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 12),

        if (todayAppointments.isEmpty)
          _buildEmptyState(
            icon: Icons.calendar_today_rounded,
            title: 'No appointments scheduled for today',
            subtitle: 'Appointments booked by reception or online will automatically appear on this timeline.',
          )
        else
          ...todayAppointments.map((apt) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                        child: Text(apt.time, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${apt.name} (Token #${apt.token})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            Text('Clinical Reason: ${apt.reason}', style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      _buildPriorityBadge(apt.priority),
                      const SizedBox(width: 8),
                      _buildStatusBadge(apt.status),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 8. REPORTS & ANALYTICS (100% DYNAMIC)
  // ============================================================

  Widget _buildReportsView() {
    final totalAppts = _allAppointments.length;
    final completedCount = _allAppointments.where((a) => a.status == 'Completed').length;
    final urgentCount = _allAppointments.where((a) => a.priority == 'Emergency' || a.priority == 'High').length;
    final completionRate = totalAppts == 0 ? 100 : ((completedCount / totalAppts) * 100).toInt();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports & Clinical Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  Text('Real-time clinical throughput, triage statistics, and consultation metrics', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            // Date Filter
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Today', label: Text('Today')),
                ButtonSegment(value: '7 Days', label: Text('7 Days')),
                ButtonSegment(value: '30 Days', label: Text('30 Days')),
              ],
              selected: {_analyticsRange},
              onSelectionChanged: (set) => setState(() => _analyticsRange = set.first),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ANALYTICS STAT CARDS
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(title: 'Total Appointments', value: '$totalAppts', icon: Icons.assignment_rounded, color: AppColors.primary, lightColor: AppColors.primaryLight),
            _buildStatCard(title: 'Completed Consults', value: '$completedCount', icon: Icons.task_alt_rounded, color: AppColors.success, lightColor: AppColors.successLight),
            _buildStatCard(title: 'Urgent / Emergency', value: '$urgentCount', icon: Icons.emergency_rounded, color: AppColors.emergency, lightColor: AppColors.emergencyLight),
            _buildStatCard(title: 'Completion Rate', value: '$completionRate%', icon: Icons.percent_rounded, color: AppColors.secondary, lightColor: AppColors.secondaryLight),
          ],
        ),

        const SizedBox(height: 24),

        _buildQueueOverviewChartCard(),
      ],
    );
  }

  // ============================================================
  // 9. DYNAMIC NOTIFICATIONS PAGE
  // ============================================================

  Widget _buildNotificationsPageView() {
    final notifications = _getDynamicNotifications();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications & Triage Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  Text('Live synchronized alerts and clinical queue updates for your consultation room', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refreshData,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (notifications.isEmpty)
          _buildEmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'No new notifications',
            subtitle: 'You are all caught up with your patient queue alerts.',
          )
        else
          ...notifications.map((n) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: n.color.withValues(alpha: 0.12), child: Icon(n.icon, color: n.color, size: 20)),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  subtitle: Text(n.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  trailing: Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 10. SETTINGS
  // ============================================================

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Doctor Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Workspace preferences and consultation configurations', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Audio Announcement on Call Next', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Play chime when calling patient to consultation room'),
                value: true,
                onChanged: (v) {},
              ),
              const Divider(height: 1, color: AppColors.border),
              SwitchListTile(
                title: const Text('Auto-advance Queue on Complete', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Automatically display next waiting token upon completing consultation'),
                value: false,
                onChanged: (v) {},
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                title: const Text('Active Doctor Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('$_effectiveDoctorName • $_effectiveDepartment • ID: $_effectiveDoctorId'),
                trailing: const Icon(Icons.verified_user_rounded, color: AppColors.success),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUEUE ACTIONS
  // ============================================================

  void _callNextPatient() {
    final patient = _queue.callNextPatient(doctorId: _effectiveDoctorId);
    if (!mounted) return;
    if (patient != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Now Calling: ${patient.name} (Token #${patient.token}) to $_effectiveDepartment.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No patients currently waiting in the queue.')),
      );
    }
  }

  void _callPatientDirect(QueuePatient p) async {
    final aptId = int.tryParse(p.id);
    if (aptId != null) {
      await PatientApiService.instance.callAppointment(aptId);
    }
    _queue.updateStatus(p.id, 'Calling');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling Token #${p.token} (${p.name})')),
      );
    }
  }

  // ============================================================
  // PATIENT DETAILS MODAL
  // ============================================================

  void _viewPatientDetailsDialog(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Token Number', '#${p.token}'),
              _detailRow('Age / Gender', '${p.age} years / ${p.gender}'),
              _detailRow('Mobile Number', p.phone.isEmpty ? 'Not Provided' : p.phone),
              _detailRow('Email', p.email.isEmpty ? 'Not Provided' : p.email),
              _detailRow('Address', p.address.isEmpty ? 'City Care Clinic Area' : p.address),
              _detailRow('Reason for Visit', p.reason),
              _detailRow('Priority', p.priority),
              _detailRow('Queue Status', p.status),
              if (p.diagnosis != null && p.diagnosis!.isNotEmpty) _detailRow('Diagnosis', p.diagnosis!),
              if (p.clinicalNotes != null && p.clinicalNotes!.isNotEmpty) _detailRow('Clinical Notes', p.clinicalNotes!),
              if (p.prescription != null && p.prescription!.isNotEmpty) _detailRow('Prescription', p.prescription!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (p.status == 'Waiting')
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _callPatientDirect(p);
              },
              child: const Text('Call Patient'),
            ),
          if (p.status != 'Completed')
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _startConsultationForPatient(p);
              },
              child: const Text('Start Consultation'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText))),
        ],
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    final notifications = _getDynamicNotifications();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Live Triage & Queue Alerts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            ),
            const SizedBox(height: 14),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No new notifications.', style: TextStyle(color: AppColors.secondaryText))),
              )
            else
              ...notifications.take(4).map((n) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: n.color.withValues(alpha: 0.12), child: Icon(n.icon, color: n.color, size: 20)),
                      title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      subtitle: Text(n.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BADGES & HELPERS
  // ============================================================

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Completed':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case 'In Consultation':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case 'Calling':
        bg = AppColors.secondaryLight;
        fg = AppColors.secondary;
        break;
      case 'No Show':
      case 'Cancelled':
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        break;
      default:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color bg = AppColors.primaryLight;
    Color fg = AppColors.primary;
    if (priority == 'Emergency') {
      bg = AppColors.emergencyLight;
      fg = AppColors.emergency;
    } else if (priority == 'High') {
      bg = AppColors.warningLight;
      fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(priority, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 42, color: AppColors.secondaryText.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.mainText)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(m - 1) % 12];
  }
}

// ============================================================
// DEDICATED CONSULTATION WORKSPACE SUB-WIDGET
// ============================================================

class _ConsultationScreenWidget extends StatefulWidget {
  final QueuePatient? patient;
  final List<QueuePatient> availablePatients;
  final ValueChanged<QueuePatient> onSelectPatient;
  final ValueChanged<String> onComplete;

  const _ConsultationScreenWidget({
    required this.patient,
    required this.availablePatients,
    required this.onSelectPatient,
    required this.onComplete,
  });

  @override
  State<_ConsultationScreenWidget> createState() => _ConsultationScreenWidgetState();
}

class _ConsultationScreenWidgetState extends State<_ConsultationScreenWidget> {
  final TextEditingController _symptomsCtrl = TextEditingController();
  final TextEditingController _diagnosisCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _rxCtrl = TextEditingController();
  final TextEditingController _adviceCtrl = TextEditingController();
  final TextEditingController _followUpCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void didUpdateWidget(covariant _ConsultationScreenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient?.id != widget.patient?.id) {
      _populateFields();
    }
  }

  void _populateFields() {
    if (widget.patient != null) {
      _symptomsCtrl.text = widget.patient!.reason;
      _diagnosisCtrl.text = widget.patient!.diagnosis ?? '';
      _notesCtrl.text = widget.patient!.clinicalNotes ?? '';
      _rxCtrl.text = widget.patient!.prescription ?? '';
      _adviceCtrl.text = widget.patient!.treatmentAdvice ?? '';
      _followUpCtrl.text = widget.patient!.followUpDate ?? '';
    }
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    _rxCtrl.dispose();
    _adviceCtrl.dispose();
    _followUpCtrl.dispose();
    super.dispose();
  }

  void _saveOrComplete(bool complete) async {
    if (widget.patient == null) return;
    setState(() => _isSaving = true);

    await QueueService.instance.completePatient(
      widget.patient!.id,
      diagnosis: _diagnosisCtrl.text,
      symptoms: _symptomsCtrl.text,
      clinicalNotes: _notesCtrl.text,
      prescription: _rxCtrl.text,
      treatmentAdvice: _adviceCtrl.text,
      followUpDate: _followUpCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(complete ? 'Consultation completed for ${widget.patient!.name}. Queue updated to Completed.' : 'Consultation notes saved successfully.'),
        backgroundColor: AppColors.success,
      ),
    );

    if (complete) {
      widget.onComplete(widget.patient!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patient == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined, size: 56, color: AppColors.secondaryText),
            const SizedBox(height: 14),
            const Text('No Patient Selected for Consultation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.mainText)),
            const SizedBox(height: 6),
            const Text('Select a waiting patient from Today\'s Queue or click "Call Next" to begin examination.', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => QueueService.instance.callNextPatient(),
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Call Next Patient in Queue'),
            ),
          ],
        ),
      );
    }

    final p = widget.patient!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // PATIENT SELECTOR IF MULTIPLE WAITING
        if (widget.availablePatients.length > 1)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const Text('Switch Patient:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<QueuePatient>(
                    value: p,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: widget.availablePatients.map((pat) => DropdownMenuItem(
                      value: pat,
                      child: Text('${pat.name} (Token #${pat.token}) - ${pat.status}', style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (pat) {
                      if (pat != null) widget.onSelectPatient(pat);
                    },
                  ),
                ),
              ],
            ),
          ),

        // PATIENT SUMMARY CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Text('#${p.token}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: Text(p.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Age: ${p.age} yrs • Gender: ${p.gender} • Mobile: ${p.phone.isEmpty ? "N/A" : p.phone} • Dept: ${p.department}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    const SizedBox(height: 2),
                    Text('Reported Symptoms: ${p.reason}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainText)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CLINICAL INPUTS
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Clinical Examination & Diagnosis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
              const SizedBox(height: 16),
              TextField(
                controller: _diagnosisCtrl,
                decoration: InputDecoration(
                  labelText: 'Primary Diagnosis *',
                  hintText: 'e.g. Acute Bronchitis / Viral Fever',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _symptomsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Symptoms & Clinical Findings',
                  hintText: 'Cough for 3 days, mild fever, throat irritation...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Doctor Clinical Notes',
                  hintText: 'Chest clear, normal breathing rate, no immediate wheezing...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Prescription & Treatment Advice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
              const SizedBox(height: 16),
              TextField(
                controller: _rxCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Prescription (Medicines, Dosage, Frequency, Duration) *',
                  hintText: '1. Tab Paracetamol 650mg - 1-0-1 after meals (3 days)\n2. Tab Cetirizine 10mg - 0-0-1 at bedtime (5 days)',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _adviceCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Lifestyle & Dietary Advice',
                  hintText: 'Drink warm water, adequate rest, avoid cold beverages...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _followUpCtrl,
                decoration: InputDecoration(
                  labelText: 'Follow-up Date / Review',
                  hintText: 'e.g. In 5 days or if symptoms worsen',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _saveOrComplete(false),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Consultation'),
                  ),
                  const SizedBox(width: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onPressed: _isSaving ? null : () => _saveOrComplete(true),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Complete Consultation', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DATA STRUCTURES
// ============================================================

class _DoctorNotification {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  _DoctorNotification({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });
}

class _MedicationEntry {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final TextEditingController frequencyController;
  final TextEditingController durationController;
  final TextEditingController instructionsController;

  _MedicationEntry({
    required this.nameController,
    required this.dosageController,
    required this.frequencyController,
    required this.durationController,
    required this.instructionsController,
  });

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    instructionsController.dispose();
  }
}

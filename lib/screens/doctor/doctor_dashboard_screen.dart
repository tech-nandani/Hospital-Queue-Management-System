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
  final String doctorName;
  final String department;
  final int? doctorId;

  const DoctorDashboardScreen({
    super.key,
    this.doctorName = 'Dr. Priya Sharma',
    this.department = 'General Medicine',
    this.doctorId = 1,
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

  @override
  void initState() {
    super.initState();
    _queue.addListener(_onQueueChanged);
    _doctor.addListener(_onQueueChanged);
    _refreshData();
  }

  @override
  void dispose() {
    _queue.removeListener(_onQueueChanged);
    _doctor.removeListener(_onQueueChanged);
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  void _refreshData() {
    _queue.fetchQueue(doctorId: widget.doctorId, department: widget.department);
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
                doctorName: widget.doctorName,
                specialization: widget.department,
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
              doctorName: widget.doctorName,
              specialization: widget.department,
              onLogout: _logout,
            ),
          Expanded(
            child: Column(
              children: [
                // Top Header bar
                _buildTopHeader(isDesktop),
                // Main Content View
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshData(),
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

  Widget _buildTopHeader(bool isDesktop) {
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
                Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  height: 42,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search patients, tokens, or records...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.secondaryText),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                if (_queue.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          // Doctor Info & Quick Availability
          InkWell(
            onTap: () {
              final newStatus = _doctor.availability == 'Available' ? 'Busy' : 'Available';
              _doctor.setAvailability(newStatus);
              if (widget.doctorId != null) {
                PatientApiService.instance.toggleDoctorAvailability(widget.doctorId!, newStatus == 'Available');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _doctor.availability == 'Available' ? AppColors.successLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _doctor.availability == 'Available' ? AppColors.success : AppColors.warning,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: _doctor.availability == 'Available' ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _doctor.availability,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _doctor.availability == 'Available' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Notifications
          IconButton(
            icon: Badge(
              isLabelVisible: _queue.priorityCount > 0,
              label: Text('${_queue.priorityCount}'),
              backgroundColor: AppColors.emergency,
              child: const Icon(Icons.notifications_none_rounded, color: AppColors.mainText),
            ),
            onPressed: () => _showNotificationsModal(context),
          ),
          const SizedBox(width: 8),
          // Doctor Profile
          Row(
            children: [
              CircleAvatar(
                radius: 18,
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
                      widget.doctorName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    Text(
                      widget.department,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

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
  // 1. DASHBOARD OVERVIEW
  // ============================================================

  Widget _buildDashboardOverview() {
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // WELCOME BANNER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dateStr,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Good Morning, ${widget.doctorName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.department} Specialist • You have ${_queue.waitingCount} patient(s) waiting in your queue today. Triage priority cases first.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _callNextPatient(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.campaign_rounded, size: 20),
                label: const Text('Call Next Patient', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // STATISTICS CARDS
        _buildStatCards(),

        const SizedBox(height: 24),

        // QUICK ACTIONS
        _buildQuickActions(),

        const SizedBox(height: 24),

        // MAIN GRID: QUEUE TABLE + QUEUE VISUALIZATION
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildTodayQueueCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildQueueOverviewChartCard()),
                ],
              );
            }
            return Column(
              children: [
                _buildTodayQueueCard(),
                const SizedBox(height: 20),
                _buildQueueOverviewChartCard(),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // SECONDARY GRID: PRIORITY PATIENTS + TODAY'S SCHEDULE
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPriorityPatientsCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTodayScheduleCard()),
                ],
              );
            }
            return Column(
              children: [
                _buildPriorityPatientsCard(),
                const SizedBox(height: 20),
                _buildTodayScheduleCard(),
              ],
            );
          },
        ),
      ],
    );
  }

  // STATISTICS
  Widget _buildStatCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Patients Today',
              value: '${_queue.totalPatients}',
              icon: Icons.groups_rounded,
              color: AppColors.primary,
              lightColor: AppColors.primaryLight,
            ),
            _buildStatCard(
              title: 'Patients in Queue',
              value: '${_queue.waitingCount}',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              lightColor: AppColors.warningLight,
            ),
            _buildStatCard(
              title: 'Average Waiting Time',
              value: '${_queue.averageWaitingMinutes} mins',
              icon: Icons.timer_outlined,
              color: AppColors.secondary,
              lightColor: AppColors.secondaryLight,
            ),
            _buildStatCard(
              title: 'Completed Today',
              value: '${_queue.completedCount}',
              icon: Icons.task_alt_rounded,
              color: AppColors.success,
              lightColor: AppColors.successLight,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.mainText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: lightColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  // QUICK ACTIONS
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Text(
            'Quick Actions:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.medical_services_rounded, size: 16, color: AppColors.primary),
                  label: const Text('Start Consultation'),
                  backgroundColor: AppColors.primaryLight,
                  side: BorderSide.none,
                  onPressed: () {
                    final next = _queue.patients.where((p) => p.status == 'Calling' || p.status == 'Waiting').firstOrNull;
                    if (next != null) {
                      _startConsultationForPatient(next);
                    } else {
                      setState(() => _selectedIndex = 4);
                    }
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.secondary),
                  label: const Text('View Patient History'),
                  backgroundColor: AppColors.secondaryLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 3),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.success),
                  label: const Text('View Appointments'),
                  backgroundColor: AppColors.successLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 2),
                ),
                ActionChip(
                  avatar: const Icon(Icons.queue_rounded, size: 16, color: AppColors.warning),
                  label: const Text('View Full Queue'),
                  backgroundColor: AppColors.warningLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODAY'S QUEUE TABLE
  Widget _buildTodayQueueCard() {
    final filtered = _queue.patients.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.token.toString().contains(q) ||
          p.phone.contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Patient Queue",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.mainText),
                    ),
                    Text(
                      'Live synchronized triage stream for your consultation room',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selectedIndex = 1),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _buildEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'No patients in queue',
              subtitle: 'No patients are currently waiting for consultation.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 640),
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 18,
                  headingRowHeight: 42,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 58,
                  columns: const [
                    DataColumn(label: Text('TOKEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('PATIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('AGE / GEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('PRIORITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                  ],
                  rows: filtered.take(6).map((patient) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: patient.priority == 'Emergency'
                                  ? AppColors.emergencyLight
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${patient.token}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: patient.priority == 'Emergency'
                                    ? AppColors.emergency
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.mainText)),
                              Text(patient.reason, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        DataCell(Text('${patient.age}y / ${patient.gender}', style: const TextStyle(fontSize: 12, color: AppColors.mainText))),
                        DataCell(Text(patient.time, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText))),
                        DataCell(_buildPriorityBadge(patient.priority)),
                        DataCell(_buildStatusBadge(patient.status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.secondaryText),
                                tooltip: 'View Profile',
                                onPressed: () => _viewPatientDetailsDialog(patient),
                              ),
                              if (patient.status == 'Waiting')
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _callPatientDirect(patient),
                                  child: const Text('Call', style: TextStyle(fontSize: 11)),
                                ),
                              if (patient.status == 'Calling' || patient.status == 'Waiting') ...[
                                const SizedBox(width: 6),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _startConsultationForPatient(patient),
                                  child: const Text('Consult', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // QUEUE OVERVIEW DONUT CHART
  Widget _buildQueueOverviewChartCard() {
    final total = _queue.totalPatients == 0 ? 1 : _queue.totalPatients;
    final waiting = _queue.waitingCount;
    final inConsult = _queue.consultationCount;
    final completed = _queue.completedCount;
    final calling = _queue.callingCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Queue Overview',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.mainText),
          ),
          const Text(
            'Patient distribution by clinical status',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 42,
                          sectionsSpace: 3,
                          sections: [
                            PieChartSectionData(
                              value: waiting == 0 ? 0.01 : waiting.toDouble(),
                              color: AppColors.warning,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: calling == 0 ? 0.01 : calling.toDouble(),
                              color: AppColors.secondary,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: inConsult == 0 ? 0.01 : inConsult.toDouble(),
                              color: AppColors.primary,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: completed == 0 ? 0.01 : completed.toDouble(),
                              color: AppColors.success,
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_queue.totalPatients}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText),
                          ),
                          const Text('Total', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Waiting', waiting, AppColors.warning),
                      _buildLegendItem('Calling', calling, AppColors.secondary),
                      _buildLegendItem('Consulting', inConsult, AppColors.primary),
                      _buildLegendItem('Completed', completed, AppColors.success),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
          Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText)),
        ],
      ),
    );
  }

  // PRIORITY PATIENTS
  Widget _buildPriorityPatientsCard() {
    final priorities = _queue.patients
        .where((p) => (p.priority == 'High' || p.priority == 'Emergency') && p.status != 'Completed' && p.status != 'Cancelled')
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.emergencyLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.emergency_rounded, color: AppColors.emergency, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Priority / Emergency Patients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
                ),
              ),
              Text(
                '${priorities.length} Urgent',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emergency),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (priorities.isEmpty)
            _buildEmptyState(
              icon: Icons.done_all_rounded,
              title: 'No urgent cases',
              subtitle: 'No emergency or high priority patients waiting.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: priorities.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final p = priorities[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: p.priority == 'Emergency' ? AppColors.emergencyLight : AppColors.warningLight,
                    child: Text(
                      '#${p.token}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: p.priority == 'Emergency' ? AppColors.emergency : AppColors.warning,
                      ),
                    ),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.mainText)),
                  subtitle: Text('${p.reason} • ${p.time}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.priority == 'Emergency' ? AppColors.emergency : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _startConsultationForPatient(p),
                    child: const Text('Treat Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // TODAY'S SCHEDULE
  Widget _buildTodayScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Consultation Schedule",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
                ),
              ),
              Text(
                _doctor.consultationHours,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildScheduleRow('09:00 AM - 10:30 AM', 'Morning Outpatient OPD', 'General Consultation & Follow-ups', true),
          _buildScheduleRow('10:30 AM - 01:00 PM', 'Queue Consultations', 'Live patient queue examinations', true),
          _buildScheduleRow('01:00 PM - 02:00 PM', 'Lunch & Clinical Break', 'Room sanitization & chart reviews', false),
          _buildScheduleRow('02:00 PM - 05:00 PM', 'Afternoon Specialized Clinic', 'Priority investigations & discharge advice', true),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String time, String title, String subtitle, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? AppColors.primary : AppColors.secondaryText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. TODAY'S QUEUE (FULL PAGE)
  // ============================================================

  Widget _buildFullQueueView() {
    final list = _queue.patients;
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
                  Text('Complete patient triage and status management', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _callNextPatient(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
  // 3. APPOINTMENTS (FULL PAGE)
  // ============================================================

  Widget _buildAppointmentsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Doctor Appointments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Review scheduled visits and consultation slots for today', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (_queue.patients.isEmpty)
          _buildEmptyState(icon: Icons.calendar_today_rounded, title: 'No appointments', subtitle: 'No appointments scheduled for today.')
        else
          ..._queue.patients.map((p) => Card(
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
                            Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                            const SizedBox(height: 3),
                            Text('Time: ${p.time} • ${p.age} yrs • Reason: ${p.reason}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(p.status),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _startConsultationForPatient(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Consult'),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 4. PATIENTS DIRECTORY (DOCTOR VIEW)
  // ============================================================

  Widget _buildPatientsDirectoryView() {
    final list = _queue.patients;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Patient Clinical Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Search patients, view medical history, previous visits, and prescriptions', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (list.isEmpty)
          _buildEmptyState(icon: Icons.people_outline_rounded, title: 'No patient records', subtitle: 'Patients will appear once checked in or registered.')
        else
          ...list.map((p) => Card(
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
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('Mobile: ${p.phone.isEmpty ? "N/A" : p.phone} • Gender: ${p.gender} • Age: ${p.age}y\nReason: ${p.reason}'),
                  isThreeLine: true,
                  trailing: OutlinedButton.icon(
                    onPressed: () => _viewPatientDetailsDialog(p),
                    icon: const Icon(Icons.folder_shared_outlined, size: 16),
                    label: const Text('View Profile'),
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 5. DOCTOR CONSULTATION MODULE
  // ============================================================

  Widget _buildConsultationScreen() {
    return _ConsultationScreenWidget(
      patient: _selectedPatientForConsult ?? _queue.patients.where((p) => p.status == 'In Consultation' || p.status == 'Calling').firstOrNull,
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
  // 6. MEDICAL RECORDS VIEW
  // ============================================================

  Widget _buildMedicalRecordsView() {
    final completed = _queue.patients.where((p) => p.status == 'Completed').toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Consultation Records & Medical History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Archived clinical notes, diagnoses, and prescriptions', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (completed.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No completed consultations yet',
            subtitle: 'Complete consultations from your queue to archive medical records here.',
          )
        else
          ...completed.map((p) => Card(
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
                      Text('Diagnosis: ${p.diagnosis ?? "Routine examination normal"}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Clinical Notes: ${p.clinicalNotes ?? "Patient presented with standard symptoms. Follow-up advised if symptoms persist."}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Text('Prescription: ${p.prescription ?? "Paracetamol 500mg, Rest & hydration"}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 7. PRESCRIPTIONS VIEW
  // ============================================================

  Widget _buildPrescriptionsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Prescriptions Issued', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Medications and dosage plans generated for your patients', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medication_rounded, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Active Digital Rx Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('All prescriptions generated during consultations are digitally signed and recorded against the patient appointment in the CareFlow database.', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 4),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create New Prescription in Consultation'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 8. SCHEDULE VIEW
  // ============================================================

  Widget _buildScheduleView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Consultation Hours & Schedule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Configure clinic availability, break times, and appointment slots', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        _buildTodayScheduleCard(),
      ],
    );
  }

  // ============================================================
  // 9. REPORTS & ANALYTICS
  // ============================================================

  Widget _buildReportsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Reports & Queue Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Real-time performance indicators and triage statistics', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        _buildStatCards(),
        const SizedBox(height: 20),
        _buildQueueOverviewChartCard(),
      ],
    );
  }

  Widget _buildNotificationsPageView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Notifications & Triage Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 20),
        _buildNotificationTile(Icons.emergency_rounded, 'Emergency Patient in Queue', '1 patient tagged with Emergency priority waiting at triage desk.', AppColors.emergency),
        _buildNotificationTile(Icons.schedule_rounded, 'Shift Schedule On Time', 'Consultation room operating within planned schedule.', AppColors.success),
        _buildNotificationTile(Icons.info_outline_rounded, 'Queue System Synchronized', 'All patient tokens are synchronized in real-time with backend SQLite.', AppColors.primary),
      ],
    );
  }

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
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HELPERS & ACTIONS
  // ============================================================

  void _callNextPatient() async {
    final patient = await _queue.callNextPatient(doctorId: widget.doctorId);
    if (!mounted) return;
    if (patient != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Now Calling: ${patient.name} (Token #${patient.token}) to ${widget.department}.'),
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
    p.status = 'Calling';
    _queue.notifyListeners();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling Token #${p.token} (${p.name})')),
      );
    }
  }

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
              if (p.diagnosis != null) _detailRow('Previous Diagnosis', p.diagnosis!),
              if (p.prescription != null) _detailRow('Prescription', p.prescription!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Triage Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildNotificationTile(Icons.emergency_rounded, 'Priority Patients', '${_queue.priorityCount} urgent patient(s) waiting in queue.', AppColors.emergency),
            _buildNotificationTile(Icons.groups_rounded, 'Waiting Patients', '${_queue.waitingCount} patient(s) checked-in at reception.', AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      ),
    );
  }

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

  String _weekday(int d) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(d - 1) % 7];
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
  final ValueChanged<String> onComplete;

  const _ConsultationScreenWidget({
    required this.patient,
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
    if (widget.patient != null) {
      _symptomsCtrl.text = widget.patient!.reason;
      if (widget.patient!.diagnosis != null) _diagnosisCtrl.text = widget.patient!.diagnosis!;
      if (widget.patient!.clinicalNotes != null) _notesCtrl.text = widget.patient!.clinicalNotes!;
      if (widget.patient!.prescription != null) _rxCtrl.text = widget.patient!.prescription!;
      if (widget.patient!.treatmentAdvice != null) _adviceCtrl.text = widget.patient!.treatmentAdvice!;
      if (widget.patient!.followUpDate != null) _followUpCtrl.text = widget.patient!.followUpDate!;
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
                          child: const Text('Active In Consultation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
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

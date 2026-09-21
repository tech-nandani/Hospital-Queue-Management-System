import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/patient_api_service.dart';
import '../../services/queue_service.dart';
import '../../services/verification_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/careflow_floating_ai.dart';
import '../../widgets/receptionist_sidebar.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  final String receptionistName;

  const ReceptionistDashboardScreen({
    super.key,
    this.receptionistName = 'Sunita Rao',
  });

  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {
  final QueueService _queue = QueueService.instance;
  int _selectedIndex = 0;
  String _searchQuery = '';

  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoadingStaffData = false;

  @override
  void initState() {
    super.initState();
    _queue.addListener(_onQueueChanged);
    _loadMetadata();
    _queue.fetchQueue();
  }

  @override
  void dispose() {
    _queue.removeListener(_onQueueChanged);
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  void _loadMetadata() async {
    setState(() => _isLoadingStaffData = true);
    try {
      final depts = await PatientApiService.instance.getDepartments();
      final docs = await PatientApiService.instance.getDoctorAvailability();
      if (mounted) {
        setState(() {
          _departments = depts;
          _doctors = docs;
          _isLoadingStaffData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStaffData = false);
    }
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
      floatingActionButton: const CareFlowFloatingAI(role: 'Receptionist'),
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
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('CareFlow Reception', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Queue',
                  onPressed: () {
                    _queue.fetchQueue();
                    _loadMetadata();
                  },
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
              child: ReceptionistSidebar(
                selectedIndex: _selectedIndex,
                onSelected: (i) {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = i);
                },
                receptionistName: widget.receptionistName,
                onLogout: _logout,
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop)
            ReceptionistSidebar(
              selectedIndex: _selectedIndex,
              onSelected: (i) => setState(() => _selectedIndex = i),
              receptionistName: widget.receptionistName,
              onLogout: _logout,
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(isDesktop),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _queue.fetchQueue();
                      _loadMetadata();
                    },
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
                NavigationDestination(icon: Icon(Icons.person_add_outlined), selectedIcon: Icon(Icons.person_add_rounded), label: 'Register'),
                NavigationDestination(icon: Icon(Icons.format_list_numbered_rounded), selectedIcon: Icon(Icons.format_list_numbered_rounded), label: 'Queue'),
                NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number_rounded), label: 'Token'),
                NavigationDestination(icon: Icon(Icons.directions_walk_rounded), selectedIcon: Icon(Icons.directions_walk_rounded), label: 'Walk-in'),
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
                      hintText: 'Search patient name, token, mobile...',
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
                if (_queue.isLoading || _isLoadingStaffData)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                  ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() => _selectedIndex = 5), // Generate Token
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Generate Token', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondaryLight,
            child: const Icon(Icons.support_agent_rounded, color: AppColors.secondary, size: 20),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.receptionistName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                const Text('Front Desk Lead', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 1:
        return _buildPatientRegistrationView();
      case 2:
        return _buildFullQueueManagementView();
      case 3:
        return _buildAppointmentsManagementView();
      case 4:
        return _buildWalkInPatientsView();
      case 5:
        return _buildGenerateTokenView();
      case 6:
        return _buildCheckInOutView();
      case 7:
        return _buildAdministrativePatientsView();
      case 8:
        return _buildDepartmentsView();
      case 9:
        return _buildDoctorAvailabilityView();
      case 10:
        return _buildNotificationsView();
      case 11:
        return _buildSettingsView();
      default:
        return _buildDashboardOverview();
    }
  }

  // ============================================================
  // 1. RECEPTIONIST DASHBOARD OVERVIEW
  // ============================================================

  Widget _buildDashboardOverview() {
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // WELCOME
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.25),
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
                      'Good Morning, ${widget.receptionistName}',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Front Desk Command Center • ${_queue.waitingCount} patient(s) waiting in reception queue. Register walk-ins and coordinate triage smoothly.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => setState(() => _selectedIndex = 4), // Walk-ins
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.directions_walk_rounded, size: 20),
                label: const Text('Add Walk-in', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // STATISTICS
        _buildStatCards(),

        const SizedBox(height: 24),

        // QUICK ACTIONS
        _buildQuickActions(),

        const SizedBox(height: 24),

        // TODAY'S QUEUE SECTION
        _buildQueueSection(),
      ],
    );
  }

  Widget _buildStatCards() {
    final checkedIn = _queue.patients.where((p) => p.status == 'Checked-in' || p.status == 'Waiting' || p.status == 'In Consultation').length;

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
            _buildStatCard('Total Patients Today', '${_queue.totalPatients}', Icons.people_alt_rounded, AppColors.primary, AppColors.primaryLight),
            _buildStatCard('Waiting Patients', '${_queue.waitingCount}', Icons.hourglass_top_rounded, AppColors.warning, AppColors.warningLight),
            _buildStatCard('Checked-in Patients', '$checkedIn', Icons.how_to_reg_rounded, AppColors.secondary, AppColors.secondaryLight),
            _buildStatCard('Appointments Today', '${_queue.totalPatients}', Icons.calendar_month_rounded, AppColors.success, AppColors.successLight),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color lightColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600), maxLines: 1),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.mainText)),
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
          const Text('Front Desk Actions:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: AppColors.secondary),
                  label: const Text('Patient Registration'),
                  backgroundColor: AppColors.secondaryLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
                ActionChip(
                  avatar: const Icon(Icons.confirmation_number_rounded, size: 16, color: AppColors.primary),
                  label: const Text('Generate Token'),
                  backgroundColor: AppColors.primaryLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 5),
                ),
                ActionChip(
                  avatar: const Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.warning),
                  label: const Text('Walk-in Triage'),
                  backgroundColor: AppColors.warningLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 4),
                ),
                ActionChip(
                  avatar: const Icon(Icons.event_available_rounded, size: 16, color: AppColors.success),
                  label: const Text('Doctor Availability'),
                  backgroundColor: AppColors.successLight,
                  side: BorderSide.none,
                  onPressed: () => setState(() => _selectedIndex = 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueSection() {
    final filtered = _queue.patients.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.token.toString().contains(q) ||
          p.phone.contains(q) ||
          p.doctorName.toLowerCase().contains(q) ||
          p.department.toLowerCase().contains(q);
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
                    Text("Today's Reception Queue", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                    Text('Live tokens, doctor assignment, and check-in statuses', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text('Manage Full Queue'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _buildEmptyPlaceholder('No patients in queue', 'Use "Patient Registration" or "Walk-in Patients" to generate tokens.')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 18,
                  headingRowHeight: 42,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 58,
                  columns: const [
                    DataColumn(label: Text('TOKEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('PATIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('DOCTOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('PRIORITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText))),
                  ],
                  rows: filtered.map((patient) {
                    final isEmergency = patient.priority == 'Emergency';
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isEmergency ? AppColors.emergencyLight : AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${patient.token}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isEmergency ? AppColors.emergency : AppColors.secondary,
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
                              Text(patient.phone.isEmpty ? 'Walk-in' : patient.phone, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                        DataCell(Text(patient.department, style: const TextStyle(fontSize: 12, color: AppColors.mainText))),
                        DataCell(Text(patient.doctorName, style: const TextStyle(fontSize: 12, color: AppColors.mainText, fontWeight: FontWeight.w600))),
                        DataCell(Text(patient.time, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText))),
                        DataCell(_buildPriorityBadge(patient.priority)),
                        DataCell(_buildStatusBadge(patient.status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (patient.status == 'Upcoming' || patient.status == 'Waiting')
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _checkIn(patient),
                                  child: const Text('Check-in', style: TextStyle(fontSize: 11)),
                                ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.secondaryText),
                                tooltip: 'View Details',
                                onPressed: () => _viewPatientDetails(patient),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                                tooltip: 'Cancel Token',
                                onPressed: () => _confirmCancel(patient),
                              ),
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

  // ============================================================
  // 2. PATIENT REGISTRATION FORM
  // ============================================================

  Widget _buildPatientRegistrationView() {
    return _PatientRegistrationForm(
      departments: _departments,
      doctors: _doctors,
      onRegistered: (newPatient) {
        setState(() => _selectedIndex = 2); // Jump to Today's Queue
      },
    );
  }

  // ============================================================
  // 3. GENERATE TOKEN SCREEN
  // ============================================================

  Widget _buildGenerateTokenView() {
    return _GenerateTokenScreen(
      departments: _departments,
      doctors: _doctors,
      onGenerated: (patient) {
        setState(() => _selectedIndex = 2);
      },
    );
  }

  // ============================================================
  // 4. WALK-IN PATIENTS SCREEN
  // ============================================================

  Widget _buildWalkInPatientsView() {
    return _WalkInPatientsScreen(
      departments: _departments,
      doctors: _doctors,
      onWalkInAdded: (patient) {
        setState(() => _selectedIndex = 2);
      },
    );
  }

  // ============================================================
  // 5. CHECK-IN / CHECK-OUT MODULE
  // ============================================================

  Widget _buildCheckInOutView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Check-in / Check-out Desk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Verify patient arrivals and mark consultation status progression', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        _buildQueueSection(),
      ],
    );
  }

  // ============================================================
  // 6. APPOINTMENT MANAGEMENT
  // ============================================================

  Widget _buildAppointmentsManagementView() {
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
                  Text('Appointment Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                  Text('Book, reschedule, search, and manage clinic appointments', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => setState(() => _selectedIndex = 1),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Book New Appointment'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (list.isEmpty)
          _buildEmptyPlaceholder('No appointments found', 'No patient appointments exist for the selected date.')
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
                        backgroundColor: AppColors.primaryLight,
                        child: Text('#${p.token}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('Dept: ${p.department} • Doctor: ${p.doctorName} • Time: ${p.time}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(p.status),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => _rescheduleDialog(p),
                        child: const Text('Reschedule'),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                        tooltip: 'Cancel Appointment',
                        onPressed: () => _confirmCancel(p),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ============================================================
  // 7. DOCTOR AVAILABILITY MODULE
  // ============================================================

  Widget _buildDoctorAvailabilityView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Doctor Availability & Clinic Rosters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Check doctors on-duty to book appointments and triage queue tokens appropriately', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (_doctors.isEmpty)
          _buildEmptyPlaceholder('No doctors found', 'Doctors will appear once registered in the system.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: _doctors.length,
                itemBuilder: (context, i) {
                  final doc = _doctors[i];
                  final isAvailable = doc['is_available'] as bool? ?? true;
                  final queueCount = doc['current_queue_count'] as int? ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isAvailable ? AppColors.successLight : const Color(0xFFF1F5F9),
                              child: Icon(Icons.medical_information_rounded, color: isAvailable ? AppColors.success : AppColors.secondaryText),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc['name'] ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  Text(doc['specialization'] ?? 'General Medicine', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAvailable ? AppColors.successLight : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Busy',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isAvailable ? AppColors.success : AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Divider(color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Queue: $queueCount patient(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText)),
                            Text('Today: 9 AM - 5 PM', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ============================================================
  // 8. ADMINISTRATIVE PATIENTS VIEW (NON-CLINICAL)
  // ============================================================

  Widget _buildAdministrativePatientsView() {
    final list = _queue.patients;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Registered Patients Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Administrative record lookup (Clinical notes are restricted to Doctor Module)', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (list.isEmpty)
          _buildEmptyPlaceholder('No patients found', 'Registered patients will be displayed here.')
        else
          ...list.map((p) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryLight,
                    child: Text(p.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Mobile: ${p.phone.isEmpty ? "N/A" : p.phone} • Age: ${p.age} • Gender: ${p.gender} • Dept: ${p.department}'),
                  trailing: OutlinedButton(
                    onPressed: () => _viewPatientDetails(p),
                    child: const Text('View Record'),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildFullQueueManagementView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Queue Management Console', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Manage token sequence and check in waiting patients for all doctors', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        _buildQueueSection(),
      ],
    );
  }

  Widget _buildDepartmentsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Hospital Departments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 20),
        if (_departments.isEmpty)
          _buildEmptyPlaceholder('No departments found', 'Departments will appear once initialized.')
        else
          ..._departments.map((d) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                  title: Text(d['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(d['description'] ?? 'Consultation, Outpatient & Inpatient care'),
                ),
              )),
      ],
    );
  }

  Widget _buildNotificationsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Receptionist Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 20),
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
          leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          title: const Text('Live Queue Synchronization Active'),
          subtitle: const Text('All token additions and doctor status transitions update automatically.'),
        ),
      ],
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Reception Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Auto-print Token Slip', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Send token directly to receipt printer on registration'),
                value: false,
                onChanged: (v) {},
              ),
              const Divider(height: 1, color: AppColors.border),
              SwitchListTile(
                title: const Text('SMS Notification to Patient', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Send SMS with token and estimated waiting time'),
                value: true,
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

  void _checkIn(QueuePatient p) async {
    await _queue.checkInPatient(p.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked-in ${p.name} (Token #${p.token}). Doctor notified.'), backgroundColor: AppColors.success),
    );
  }

  void _confirmCancel(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment / Token?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to cancel the queue token for ${p.name}? This will update status to Cancelled without deleting records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No, Keep')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              _queue.cancelPatient(p.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Token #${p.token} cancelled.'), backgroundColor: AppColors.danger),
              );
            },
            child: const Text('Yes, Cancel Token'),
          ),
        ],
      ),
    );
  }

  void _rescheduleDialog(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reschedule Appointment', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Rescheduling for ${p.name}. Please select a new slot.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment rescheduled and updated in system.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _viewPatientDetails(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Token Number', '#${p.token}'),
            _row('Mobile', p.phone.isEmpty ? 'N/A' : p.phone),
            _row('Department', p.department),
            _row('Doctor Assigned', p.doctorName),
            _row('Priority', p.priority),
            _row('Status', p.status),
            _row('Reason', p.reason),
            const SizedBox(height: 10),
            const Text(
              'Notice: Clinical records and diagnoses are restricted to licensed Doctors only.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.secondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(l, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText))),
          ],
        ),
      );

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
      case 'Checked-in':
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

  Widget _buildEmptyPlaceholder(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 40, color: AppColors.border),
            const SizedBox(height: 8),
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
// PATIENT REGISTRATION FORM SUB-WIDGET
// ============================================================

class _PatientRegistrationForm extends StatefulWidget {
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> doctors;
  final ValueChanged<QueuePatient> onRegistered;

  const _PatientRegistrationForm({
    required this.departments,
    required this.doctors,
    required this.onRegistered,
  });

  @override
  State<_PatientRegistrationForm> createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<_PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  String _gender = 'Male';
  String _priority = 'Normal';
  int? _selectedDoctorId;
  String? _selectedDepartment;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctors.isNotEmpty) {
      _selectedDoctorId = widget.doctors.first['id'] as int?;
    }
    if (widget.departments.isNotEmpty) {
      _selectedDepartment = widget.departments.first['name'] as String?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameCtrl.clear();
    _dobCtrl.clear();
    _mobileCtrl.clear();
    _emailCtrl.clear();
    _addressCtrl.clear();
    _symptomsCtrl.clear();
    setState(() {
      _gender = 'Male';
      _priority = 'Normal';
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final doctorId = _selectedDoctorId ?? 1;

    try {
      final patient = await QueueService.instance.addPatient(
        name: _nameCtrl.text.trim(),
        age: 32, // Default estimated from DOB if parsed
        gender: _gender,
        phone: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        reason: _symptomsCtrl.text.trim().isEmpty ? 'General OPD Consultation' : _symptomsCtrl.text.trim(),
        priority: _priority,
        doctorId: doctorId,
        isWalkIn: false,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient registered successfully! Assigned Token #${patient.token}. Added to Queue.'),
          backgroundColor: AppColors.success,
        ),
      );

      widget.onRegistered(patient);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Patient Registration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Create official patient record and generate appointment queue token', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dobCtrl,
                        decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', prefixIcon: Icon(Icons.cake_outlined)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: 'Gender *'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mobileCtrl,
                        decoration: const InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone_outlined)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact number' : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Residential Address', prefixIcon: Icon(Icons.home_outlined)),
                ),
                const SizedBox(height: 24),
                const Text('Appointment & Doctor Assignment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment ?? (widget.departments.isNotEmpty ? widget.departments.first['name'] : 'General Medicine'),
                        decoration: const InputDecoration(labelText: 'Department *', prefixIcon: Icon(Icons.apartment_rounded)),
                        items: (widget.departments.isNotEmpty ? widget.departments : [
                          {'name': 'General Medicine'},
                          {'name': 'Cardiology'},
                          {'name': 'Pediatrics'},
                        ]).map((d) => DropdownMenuItem(value: d['name'] as String, child: Text(d['name'] as String))).toList(),
                        onChanged: (v) => setState(() => _selectedDepartment = v),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedDoctorId ?? (widget.doctors.isNotEmpty ? widget.doctors.first['id'] as int : 1),
                        decoration: const InputDecoration(labelText: 'Doctor *', prefixIcon: Icon(Icons.medical_services_outlined)),
                        items: (widget.doctors.isNotEmpty ? widget.doctors : [
                          {'id': 1, 'name': 'Dr. Priya Sharma'},
                        ]).map((doc) => DropdownMenuItem<int>(value: doc['id'] as int, child: Text(doc['name'] as String))).toList(),
                        onChanged: (v) => setState(() => _selectedDoctorId = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Triage & Clinical Reason', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _symptomsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Symptoms / Reason for Visit *', prefixIcon: Icon(Icons.note_alt_outlined)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe symptoms' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Triage Priority *'),
                  items: const [
                    DropdownMenuItem(value: 'Normal', child: Text('Normal Priority')),
                    DropdownMenuItem(value: 'High', child: Text('High Priority (Elderly/Infant)')),
                    DropdownMenuItem(value: 'Emergency', child: Text('Emergency Priority (Immediate Treatment)')),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: _clearForm, child: const Text('Clear Form')),
                    const SizedBox(width: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text('Register Patient & Generate Token', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// GENERATE TOKEN SUB-WIDGET
// ============================================================

class _GenerateTokenScreen extends StatefulWidget {
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> doctors;
  final ValueChanged<QueuePatient> onGenerated;

  const _GenerateTokenScreen({
    required this.departments,
    required this.doctors,
    required this.onGenerated,
  });

  @override
  State<_GenerateTokenScreen> createState() => _GenerateTokenScreenState();
}

class _GenerateTokenScreenState extends State<_GenerateTokenScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String _priority = 'Normal';
  int? _doctorId;
  QueuePatient? _generatedTokenResult;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctors.isNotEmpty) {
      _doctorId = widget.doctors.first['id'] as int?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter patient name.')));
      return;
    }
    setState(() => _isGenerating = true);

    final patient = await QueueService.instance.addPatient(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: 28,
      gender: 'Other',
      reason: _reasonCtrl.text.trim().isEmpty ? 'Token Consultation' : _reasonCtrl.text.trim(),
      priority: _priority,
      doctorId: _doctorId ?? 1,
      isWalkIn: false,
    );

    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _generatedTokenResult = patient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Generate Queue Token', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Issue immediate real-time sequential token with live queue calculation', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        if (_generatedTokenResult != null) ...[
          _buildTokenConfirmationCard(_generatedTokenResult!),
          const SizedBox(height: 24),
        ],
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Patient Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _doctorId ?? (widget.doctors.isNotEmpty ? widget.doctors.first['id'] as int : 1),
                decoration: const InputDecoration(labelText: 'Assigned Doctor *', prefixIcon: Icon(Icons.medical_services_outlined)),
                items: (widget.doctors.isNotEmpty ? widget.doctors : [
                  {'id': 1, 'name': 'Dr. Priya Sharma (General Medicine)'},
                ]).map((doc) => DropdownMenuItem<int>(value: doc['id'] as int, child: Text(doc['name'] as String))).toList(),
                onChanged: (v) => setState(() => _doctorId = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Triage Priority *'),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal Priority')),
                  DropdownMenuItem(value: 'High', child: Text('High Priority')),
                  DropdownMenuItem(value: 'Emergency', child: Text('Emergency Priority')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _isGenerating ? null : _generate,
                icon: const Icon(Icons.confirmation_number_rounded),
                label: const Text('Generate Token Now', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenConfirmationCard(QueuePatient p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 48),
          const SizedBox(height: 8),
          const Text('Token Generated Successfully', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          const SizedBox(height: 16),
          Text('#${p.token}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.mainText)),
          Text('Patient: ${p.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Doctor: ${p.doctorName} (${p.department})', style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Estimated Wait: 15 mins • Position: In Queue', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.mainText)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.onGenerated(p),
            icon: const Icon(Icons.queue_rounded),
            label: const Text('Go to Live Queue'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WALK-IN PATIENTS SUB-WIDGET
// ============================================================

class _WalkInPatientsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> doctors;
  final ValueChanged<QueuePatient> onWalkInAdded;

  const _WalkInPatientsScreen({
    required this.departments,
    required this.doctors,
    required this.onWalkInAdded,
  });

  @override
  State<_WalkInPatientsScreen> createState() => _WalkInPatientsScreenState();
}

class _WalkInPatientsScreenState extends State<_WalkInPatientsScreen> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String _priority = 'Normal';
  int? _doctorId;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctors.isNotEmpty) {
      _doctorId = widget.doctors.first['id'] as int?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  void _addWalkIn() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isAdding = true);

    final patient = await QueueService.instance.addPatient(
      name: _nameCtrl.text.trim(),
      phone: _mobileCtrl.text.trim(),
      age: 30,
      gender: 'Other',
      reason: _symptomsCtrl.text.trim().isEmpty ? 'Walk-in Triage' : _symptomsCtrl.text.trim(),
      priority: _priority,
      doctorId: _doctorId ?? 1,
      isWalkIn: true,
    );

    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Walk-in patient ${patient.name} added with Token #${patient.token}!'), backgroundColor: AppColors.success),
    );
    widget.onWalkInAdded(patient);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Walk-in Patient Triage', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.mainText)),
        const Text('Fast registration for immediate walk-in queue placement', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _priority == 'Emergency' ? AppColors.emergency : AppColors.border,
              width: _priority == 'Emergency' ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_priority == 'Emergency')
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.emergencyLight, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.emergency),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'EMERGENCY CASE: Patient will be prioritized to the front of the doctor queue.',
                          style: TextStyle(color: AppColors.emergency, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Walk-in Patient Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _doctorId ?? (widget.doctors.isNotEmpty ? widget.doctors.first['id'] as int : 1),
                decoration: const InputDecoration(labelText: 'Assign Doctor *', prefixIcon: Icon(Icons.medical_services_outlined)),
                items: (widget.doctors.isNotEmpty ? widget.doctors : [
                  {'id': 1, 'name': 'Dr. Priya Sharma (General Medicine)'},
                ]).map((doc) => DropdownMenuItem<int>(value: doc['id'] as int, child: Text(doc['name'] as String))).toList(),
                onChanged: (v) => setState(() => _doctorId = v),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _symptomsCtrl,
                decoration: const InputDecoration(labelText: 'Chief Complaint / Symptoms *', prefixIcon: Icon(Icons.medical_information_outlined)),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Triage Priority *'),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal Priority')),
                  DropdownMenuItem(value: 'High', child: Text('High Priority')),
                  DropdownMenuItem(value: 'Emergency', child: Text('Emergency (Highlighted Red)')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _priority == 'Emergency' ? AppColors.emergency : AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _isAdding ? null : _addWalkIn,
                icon: const Icon(Icons.add_to_queue_rounded),
                label: const Text('Add to Live Queue', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

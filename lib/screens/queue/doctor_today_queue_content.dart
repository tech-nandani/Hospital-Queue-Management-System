import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/patient_api_service.dart';
import '../../services/queue_service.dart';
import '../../services/verification_service.dart';
import '../../theme/app_colors.dart';

class DoctorTodayQueueContent extends StatefulWidget {
  final int? doctorId;
  final String? doctorName;
  final String? department;
  final void Function(QueuePatient patient)? onStartConsultation;
  final VoidCallback? onNavigateToDashboard;

  const DoctorTodayQueueContent({
    super.key,
    this.doctorId,
    this.doctorName,
    this.department,
    this.onStartConsultation,
    this.onNavigateToDashboard,
  });

  @override
  State<DoctorTodayQueueContent> createState() => _DoctorTodayQueueContentState();
}

class _DoctorTodayQueueContentState extends State<DoctorTodayQueueContent> {
  final QueueService _queue = QueueService.instance;

  // Active Tab: 0 = Queue List, 1 = Called Patients
  int _activeTab = 0;

  // Filter States
  String _selectedDateFilter = 'Today';
  String _selectedPriorityFilter = 'All Priorities';
  String _selectedStatusFilter = 'All Statuses';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 8;

  // Context Info
  late int _effectiveDoctorId;
  late String _effectiveDoctorName;
  late String _effectiveDepartment;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _initDoctorContext();
    _queue.addListener(_onQueueChanged);
    _refreshData();
  }

  @override
  void dispose() {
    _queue.removeListener(_onQueueChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
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

  Future<void> _refreshData() async {
    // Re-resolve doctor from backend availability if needed
    try {
      final doctors = await PatientApiService.instance.getDoctorAvailability();
      final staff = VerificationService.instance.currentStaff;
      final match = doctors.firstWhere(
        (d) {
          if (staff != null && staff.email.isNotEmpty && d['email']?.toString().toLowerCase() == staff.email.toLowerCase()) {
            return true;
          }
          if (d['name']?.toString().toLowerCase() == _effectiveDoctorName.toLowerCase()) {
            return true;
          }
          if (widget.doctorId != null && d['id'] == widget.doctorId) {
            return true;
          }
          return false;
        },
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty && match['id'] != null && mounted) {
        setState(() {
          _effectiveDoctorId = (match['id'] as num).toInt();
          if (match['name'] != null && match['name'].toString().isNotEmpty) {
            _effectiveDoctorName = match['name'].toString();
          }
          if (match['department_name'] != null) {
            _effectiveDepartment = match['department_name'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error matching doctor in queue content: $e');
    }

    await _queue.fetchQueue(
      doctorId: _effectiveDoctorId,
      department: _effectiveDepartment,
    );
  }

  // ============================================================
  // QUEUE FILTERING & PAGINATION
  // ============================================================

  List<QueuePatient> get _allDoctorPatients {
    // Queue patients belonging to this doctor
    return _queue.patients.where((p) {
      if (p.doctorId != null && p.doctorId != _effectiveDoctorId) {
        return false;
      }
      return true;
    }).toList();
  }

  List<QueuePatient> get _filteredPatients {
    final baseList = _allDoctorPatients;

    // 1. Tab filtering
    List<QueuePatient> tabFiltered;
    if (_activeTab == 0) {
      // Queue List: All relevant patients for today
      tabFiltered = baseList;
    } else {
      // Called Patients: patients who have already been called
      tabFiltered = baseList.where((p) {
        final st = p.status.toLowerCase();
        return st == 'calling' || st == 'in consultation' || st == 'completed';
      }).toList();
    }

    // 2. Search query filter (by name, token, phone)
    final q = _searchQuery.trim().toLowerCase();
    final searchFiltered = tabFiltered.where((p) {
      if (q.isEmpty) return true;
      final nameMatch = p.name.toLowerCase().contains(q);
      final tokenMatch = p.token.toString().contains(q) ||
          'p-${p.token}'.contains(q) ||
          't-${p.token}'.contains(q);
      final phoneMatch = p.phone.contains(q);
      final reasonMatch = p.reason.toLowerCase().contains(q);
      return nameMatch || tokenMatch || phoneMatch || reasonMatch;
    }).toList();

    // 3. Priority filter
    final priorityFiltered = searchFiltered.where((p) {
      if (_selectedPriorityFilter == 'All Priorities') return true;
      if (_selectedPriorityFilter == 'Normal') {
        return p.priority.toLowerCase() == 'normal';
      }
      if (_selectedPriorityFilter == 'Urgent') {
        return p.priority.toLowerCase() == 'high' || p.priority.toLowerCase() == 'urgent';
      }
      if (_selectedPriorityFilter == 'Emergency') {
        return p.priority.toLowerCase() == 'emergency';
      }
      return true;
    }).toList();

    // 4. Status filter
    final statusFiltered = priorityFiltered.where((p) {
      if (_selectedStatusFilter == 'All Statuses') return true;
      final pStatus = p.status.toLowerCase();
      final filterStatus = _selectedStatusFilter.toLowerCase();
      if (filterStatus == 'waiting') {
        return pStatus == 'waiting' || pStatus == 'checked-in' || pStatus == 'upcoming';
      }
      return pStatus == filterStatus;
    }).toList();

    return statusFiltered;
  }

  // ============================================================
  // ACTIONS: CALL NEXT PATIENT
  // ============================================================

  Future<void> _handleCallNextPatient() async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);

    try {
      // 1. Find eligible waiting patients
      final waitingPool = _allDoctorPatients.where((p) {
        final st = p.status.toLowerCase();
        return st == 'waiting' || st == 'checked-in' || st == 'upcoming';
      }).toList();

      if (waitingPool.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No patients currently waiting in today\'s queue.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 2. Select according to priority: Emergency > High/Urgent > Normal, then lowest token
      QueuePatient? next;
      for (final p in waitingPool) {
        if (next == null) {
          next = p;
        } else if (p.priority.toLowerCase() == 'emergency' && next.priority.toLowerCase() != 'emergency') {
          next = p;
        } else if ((p.priority.toLowerCase() == 'high' || p.priority.toLowerCase() == 'urgent') &&
            (next.priority.toLowerCase() != 'high' && next.priority.toLowerCase() != 'urgent' && next.priority.toLowerCase() != 'emergency')) {
          next = p;
        } else if (p.priority.toLowerCase() == next.priority.toLowerCase() && p.token < next.token) {
          next = p;
        }
      }

      if (next == null) return;

      // 3. Update local queue status to "Calling" immediately
      _queue.updateStatus(next.id, 'Calling');

      // 4. Update patient queue status in backend via API
      final aptId = int.tryParse(next.id);
      if (aptId != null) {
        try {
          await PatientApiService.instance.callAppointment(aptId);
        } catch (e) {
          debugPrint('Backend call appointment note: $e');
        }
      }

      // 5. Refresh the queue from backend
      try {
        await _refreshData();
      } catch (e) {
        debugPrint('Queue refresh note: $e');
      }

      // 6. Notify Doctor
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Now Calling: Token #${next.token} (${next.name}) to $_effectiveDepartment',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in callNextPatient: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to call patient: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  // ============================================================
  // ACTIONS: START CONSULTATION
  // ============================================================

  Future<void> _handleStartConsultation(QueuePatient patient) async {
    final aptId = int.tryParse(patient.id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.startConsultation(aptId);
      } catch (e) {
        debugPrint('Error starting consultation in backend: $e');
      }
    }
    _queue.startConsultation(patient.id);
    if (widget.onStartConsultation != null) {
      widget.onStartConsultation!(patient);
    } else {
      await _refreshData();
    }
  }

  // ============================================================
  // PATIENT DETAILS MODAL
  // ============================================================

  void _showPatientDetailsModal(QueuePatient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Token #${p.token} • ${p.gender} • ${p.age > 0 ? "${p.age} yrs" : "Age N/A"}',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            _buildPriorityBadge(p.priority),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                _modalSectionTitle('Patient Information'),
                const SizedBox(height: 8),
                _modalRow('Mobile Phone', p.phone.isNotEmpty ? p.phone : 'Not provided'),
                _modalRow('Email Address', p.email.isNotEmpty ? p.email : 'Not provided'),
                _modalRow('Address', p.address.isNotEmpty ? p.address : 'Hospital OPD Walk-in'),
                _modalRow('Reason for Visit', p.reason.isNotEmpty ? p.reason : 'General Consultation'),
                const SizedBox(height: 16),
                _modalSectionTitle('Queue & Appointment Details'),
                const SizedBox(height: 8),
                _modalRow('Appointment Time', p.time),
                _modalRow('Department', p.department),
                _modalRow('Doctor In-charge', p.doctorName),
                _modalRowWidget('Current Status', _buildStatusBadge(p.status)),
                if (p.diagnosis != null && p.diagnosis!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _modalSectionTitle('Clinical Notes & Diagnosis'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      p.diagnosis!,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                    ),
                  ),
                ],
                if (p.prescription != null && p.prescription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _modalSectionTitle('Prescription'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      p.prescription!,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          if (p.status == 'Waiting' || p.status == 'Checked-in' || p.status == 'Upcoming')
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.campaign_rounded, size: 16),
              label: const Text('Call Patient'),
              onPressed: () async {
                Navigator.pop(ctx);
                final aptId = int.tryParse(p.id);
                if (aptId != null) {
                  await PatientApiService.instance.callAppointment(aptId);
                }
                _queue.updateStatus(p.id, 'Calling');
                await _refreshData();
              },
            ),
          if (p.status != 'Completed')
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.medical_services_rounded, size: 16),
              label: const Text('Start Consultation'),
              onPressed: () {
                Navigator.pop(ctx);
                _handleStartConsultation(p);
              },
            ),
        ],
      ),
    );
  }

  Widget _modalSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _modalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modalRowWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          ),
          widget,
        ],
      ),
    );
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;
    final totalPatients = filtered.length;
    final totalPages = (totalPatients / _pageSize).ceil().clamp(1, 999);
    final validPage = _currentPage.clamp(1, totalPages);
    final pagedList = filtered.skip((validPage - 1) * _pageSize).take(_pageSize).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet = constraints.maxWidth >= 640 && constraints.maxWidth < 1024;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 28 : (isTablet ? 20 : 14),
            vertical: 22,
          ),
          children: [
            // 1. PAGE HEADER (with Title, Subtitle, and Breadcrumb)
            _buildPageHeader(isDesktop),

            const SizedBox(height: 20),

            // 2. FOUR DYNAMIC SUMMARY CARDS
            _buildSummaryCards(isDesktop, isTablet),

            const SizedBox(height: 24),

            // 3. MAIN QUEUE CARD (Tabs, Call Next Button, Filters, Table, Empty State, Pagination)
            _buildMainQueueCard(pagedList, totalPatients, validPage, totalPages, isDesktop),

            const SizedBox(height: 22),

            // 4. QUEUE MANAGEMENT TIPS CARD
            _buildQueueTipsCard(),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ============================================================
  // 1. PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Blue circular icon badge
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x332563EB),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        // Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Queue",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage and monitor today\'s patient queue in real-time',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Breadcrumb on the right
        if (isDesktop)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: widget.onNavigateToDashboard,
                borderRadius: BorderRadius.circular(4),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
              ),
              const Text(
                "Today's Queue",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ============================================================
  // 2. FOUR QUEUE SUMMARY CARDS (DYNAMIC)
  // ============================================================

  Widget _buildSummaryCards(bool isDesktop, bool isTablet) {
    final baseList = _allDoctorPatients;

    // 1. Total Patients Today
    final totalCount = baseList.length;

    // 2. Currently Waiting
    final waitingCount = baseList.where((p) {
      final st = p.status.toLowerCase();
      return st == 'waiting' || st == 'checked-in' || st == 'upcoming';
    }).length;

    // 3. Average Waiting Time
    final avgWaitMinutes = waitingCount == 0 ? 0 : waitingCount * 12;

    // 4. Completed Today
    final completedCount = baseList.where((p) => p.status.toLowerCase() == 'completed').length;

    final card1 = _buildSummaryCard(
      icon: Icons.people_alt_rounded,
      iconColor: const Color(0xFF2563EB),
      iconBgColor: const Color(0xFFEFF6FF),
      title: 'Total Patients Today',
      value: '$totalCount',
      subtitle: 'From today\'s appointments',
    );

    final card2 = _buildSummaryCard(
      icon: Icons.access_time_rounded,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFFFBEB),
      title: 'Currently Waiting',
      value: '$waitingCount',
      subtitle: 'In queue now',
    );

    final card3 = _buildSummaryCard(
      icon: Icons.hourglass_top_rounded,
      iconColor: const Color(0xFF7C3AED),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Average Waiting Time',
      value: '$avgWaitMinutes min',
      subtitle: 'Based on today\'s data',
    );

    final card4 = _buildSummaryCard(
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF059669),
      iconBgColor: const Color(0xFFECFDF5),
      title: 'Completed Today',
      value: '$completedCount',
      subtitle: 'Consultations completed',
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
              const SizedBox(width: 14),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 14),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          card1,
          const SizedBox(height: 10),
          card2,
          const SizedBox(height: 10),
          card3,
          const SizedBox(height: 10),
          card4,
        ],
      );
    }
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. MAIN QUEUE CARD
  // ============================================================

  Widget _buildMainQueueCard(
    List<QueuePatient> pagedList,
    int totalCount,
    int currentPage,
    int totalPages,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ================= A. TOP TAB ROW + CALL NEXT PATIENT BUTTON =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // Tabs
                Row(
                  children: [
                    _buildQueueTab(title: 'Queue List', index: 0),
                    const SizedBox(width: 24),
                    _buildQueueTab(title: 'Called Patients', index: 1),
                  ],
                ),
                const Spacer(),
                // Prominent Call Next Patient Button
                ElevatedButton.icon(
                  onPressed: _isActionInProgress ? null : _handleCallNextPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Call Next Patient',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFE2E8F0), height: 1),

          // ================= B. FILTER & SEARCH CONTROLS ROW =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;

                final dateDropdown = _buildDateDropdown();
                final priorityDropdown = _buildPriorityDropdown();
                final statusDropdown = _buildStatusDropdown();
                final searchInput = _buildSearchField();
                final refreshBtn = _buildRefreshButton();

                if (isWide) {
                  return Row(
                    children: [
                      dateDropdown,
                      const SizedBox(width: 10),
                      priorityDropdown,
                      const SizedBox(width: 10),
                      statusDropdown,
                      const SizedBox(width: 10),
                      Expanded(child: searchInput),
                      const SizedBox(width: 10),
                      refreshBtn,
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: dateDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: priorityDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: statusDropdown),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: searchInput),
                        const SizedBox(width: 8),
                        refreshBtn,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // ================= C. TABLE OR EMPTY STATE =================
          if (_queue.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            )
          else if (pagedList.isEmpty)
            _buildEmptyState()
          else
            _buildQueueTable(pagedList),

          const Divider(color: Color(0xFFE2E8F0), height: 1),

          // ================= D. FOOTER WITH PAGINATION =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // "Showing X of Y patients"
                Text(
                  totalCount == 0
                      ? 'Showing 0 of 0 patients'
                      : 'Showing ${((currentPage - 1) * _pageSize) + 1} to ${((currentPage - 1) * _pageSize) + pagedList.length} of $totalCount patients',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Pagination Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: currentPage > 1 ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      onPressed: currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$currentPage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: currentPage < totalPages ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      onPressed: currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS WIDGET
  // ============================================================

  Widget _buildQueueTab({required String title, required int index}) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = index;
          _currentPage = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CONTROLS
  // ============================================================

  Widget _buildDateDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDateFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: const [
            DropdownMenuItem(
              value: 'Today',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 6),
                  Text('Today'),
                ],
              ),
            ),
            DropdownMenuItem(value: 'Tomorrow', child: Text('Tomorrow')),
            DropdownMenuItem(value: 'All Dates', child: Text('All Dates')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedDateFilter = v);
          },
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPriorityFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: const [
            DropdownMenuItem(value: 'All Priorities', child: Text('All Priorities')),
            DropdownMenuItem(value: 'Normal', child: Text('Normal')),
            DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
            DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedPriorityFilter = v);
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatusFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: const [
            DropdownMenuItem(value: 'All Statuses', child: Text('All Statuses')),
            DropdownMenuItem(value: 'Waiting', child: Text('Waiting')),
            DropdownMenuItem(value: 'Calling', child: Text('Calling')),
            DropdownMenuItem(value: 'In Consultation', child: Text('In Consultation')),
            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
            DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            DropdownMenuItem(value: 'No Show', child: Text('No Show')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedStatusFilter = v);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search patient by name or token...',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return OutlinedButton.icon(
      onPressed: _refreshData,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: const Text('Refresh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  // ============================================================
  // QUEUE TABLE (WHEN PATIENTS EXIST)
  // ============================================================

  Widget _buildQueueTable(List<QueuePatient> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 920),
        child: DataTable(
          horizontalMargin: 20,
          columnSpacing: 18,
          headingRowHeight: 42,
          dataRowMinHeight: 54,
          dataRowMaxHeight: 60,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          headingTextStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
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
          rows: List.generate(list.length, (index) {
            final p = list[index];
            final tokenFormatted = 'P-${p.token.toString().padLeft(3, '0')}';
            final ageGender = '${p.age > 0 ? p.age : "--"} / ${p.gender.isNotEmpty ? (p.gender.startsWith("M") || p.gender.startsWith("m") ? "Male" : (p.gender.startsWith("F") || p.gender.startsWith("f") ? "Female" : "Other")) : "--"}';

            return DataRow(
              cells: [
                DataCell(
                  Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
                DataCell(
                  Text(
                    tokenFormatted,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ),
                DataCell(
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ),
                DataCell(
                  Text(
                    ageGender,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ),
                DataCell(
                  Text(
                    p.time,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ),
                DataCell(_buildPriorityBadge(p.priority)),
                DataCell(_buildStatusBadge(p.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFEFF6FF),
                          side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minimumSize: const Size(0, 30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showPatientDetailsModal(p),
                        child: const Text('View', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                      if (p.status.toLowerCase() == 'calling' || p.status.toLowerCase() == 'waiting' || p.status.toLowerCase() == 'checked-in') ...[
                        const SizedBox(width: 6),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            minimumSize: const Size(0, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _handleStartConsultation(p),
                          child: const Text('Consult', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE (EXACTLY MATCHING REFERENCE IMAGE)
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Soft blue circular container with document icon
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 32,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients in today\'s queue',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When patients are registered or checked in, they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _refreshData,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'Refresh',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGES (PRIORITY & STATUS)
  // ============================================================

  Widget _buildPriorityBadge(String priority) {
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
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
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

  Widget _buildStatusBadge(String status) {
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
      case 'no_show':
      case 'no show':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
        icon = Icons.person_off_rounded;
        label = 'No Show';
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
  // 4. QUEUE MANAGEMENT TIPS CARD
  // ============================================================

  Widget _buildQueueTipsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Queue Management Tips',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Click "Call Next Patient" to notify the next patient in queue. You can filter, search, and view patient details from the action menu.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Color(0xFF2563EB)),
                      SizedBox(width: 10),
                      Text('Queue Management Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Call Next Patient prioritizes Emergency triage cases first, followed by Urgent/High priority, then Normal by token order.', style: TextStyle(fontSize: 13)),
                      SizedBox(height: 8),
                      Text('• Status flow: Waiting → Calling → In Consultation → Completed.', style: TextStyle(fontSize: 13)),
                      SizedBox(height: 8),
                      Text('• The Called Patients tab keeps a live record of all patients summoned to your consultation room today.', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learn more',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

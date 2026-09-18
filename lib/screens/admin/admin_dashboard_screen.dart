import 'package:flutter/material.dart';

import '../../models/staff_application.dart';
import '../../services/queue_service.dart';
import '../../services/verification_service.dart';
import 'admin_approval_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final queueService = QueueService.instance;
  final verificationService = VerificationService.instance;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    queueService.addListener(_refresh);
    verificationService.addListener(_refresh);
  }

  @override
  void dispose() {
    queueService.removeListener(_refresh);
    verificationService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FD),
        foregroundColor: const Color(0xFF16324F),
        elevation: 0,
        title: const Text(
          'Admin Command Center',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showNotifications(context),
            icon: Badge(
              isLabelVisible: queueService.priorityCount > 0,
              label: Text('${queueService.priorityCount}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (desktop)
            _AdminSideRail(
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => selectedIndex = index),
            ),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _OverviewTab(
                  queueService: queueService,
                  verificationService: verificationService,
                  onOpenApprovals: () => setState(() => selectedIndex = 1),
                  onOpenReports: () => setState(() => selectedIndex = 4),
                ),
                _StaffTab(
                  verificationService: verificationService,
                  onOpenApprovals: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminApprovalScreen(),
                    ),
                  ),
                ),
                _PatientsTab(queueService: queueService),
                _AppointmentsTab(queueService: queueService),
                _ReportsTab(queueService: queueService),
              ],
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
              indicatorColor: const Color(0xFFDFF3ED),
              destinations: _navigationDestinations,
            ),
    );
  }

  static const List<NavigationDestination> _navigationDestinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge_rounded),
      label: 'Staff',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline_rounded),
      selectedIcon: Icon(Icons.people_rounded),
      label: 'Patients',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month_rounded),
      label: 'Appointments',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart_rounded),
      label: 'Reports',
    ),
  ];

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _notification(
              Icons.emergency_rounded,
              'Emergency queue',
              queueService.priorityCount == 0
                  ? 'No emergency patients right now.'
                  : '${queueService.priorityCount} high-priority patient(s) need attention.',
              const Color(0xFFD95757),
            ),
            _notification(
              Icons.verified_outlined,
              'Staff verification',
              '${verificationService.applications.where((item) => item.status == StaffApplicationStatus.pending).length} applications awaiting review.',
              const Color(0xFF16806A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notification(IconData icon, String title, String text, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(text),
    );
  }
}

class _AdminSideRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AdminSideRail({required this.selectedIndex, required this.onSelected});

  static const _items = [
    (Icons.dashboard_rounded, 'Overview'),
    (Icons.badge_rounded, 'Staff'),
    (Icons.people_rounded, 'Patients'),
    (Icons.calendar_month_rounded, 'Appointments'),
    (Icons.bar_chart_rounded, 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF16324F),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16806A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'HOSPITAL\nADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: Color(0xFF8BA1B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(13),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF16806A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.$1,
                        size: 20,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFB8C7D6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.$2,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFFB8C7D6),
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Color(0xFF36516A)),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFFDFF3ED),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF16806A),
                    size: 19,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

class _OverviewTab extends StatelessWidget {
  final QueueService queueService;
  final VerificationService verificationService;
  final VoidCallback onOpenApprovals;
  final VoidCallback onOpenReports;

  const _OverviewTab({
    required this.queueService,
    required this.verificationService,
    required this.onOpenApprovals,
    required this.onOpenReports,
  });

  @override
  Widget build(BuildContext context) {
    final pending = verificationService.applications
        .where((item) => item.status == StaffApplicationStatus.pending)
        .length;
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          const Text(
            'Good morning, Admin',
            style: TextStyle(
              color: Color(0xFF16324F),
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Here is what is happening across the hospital today.',
            style: TextStyle(color: Color(0xFF718096)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _MetricCard(
                'Waiting',
                '${queueService.waitingCount}',
                Icons.schedule_rounded,
                const Color(0xFF1976D2),
              ),
              _MetricCard(
                'In consultation',
                '${queueService.consultationCount}',
                Icons.medical_services_outlined,
                const Color(0xFF6C63B5),
              ),
              _MetricCard(
                'Emergency',
                '${queueService.priorityCount}',
                Icons.emergency_rounded,
                const Color(0xFFD95757),
              ),
              _MetricCard(
                'Staff review',
                '$pending',
                Icons.verified_outlined,
                const Color(0xFF16806A),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: 'Live queue control',
            action: 'Refresh',
            onAction: () {},
          ),
          const SizedBox(height: 10),
          _QueuePanel(queueService: queueService),
          const SizedBox(height: 22),
          _SectionHeader(
            title: 'Quick actions',
            action: 'Reports',
            onAction: onOpenReports,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.fact_check_outlined,
                  label: 'Review staff',
                  color: const Color(0xFF16806A),
                  onTap: onOpenApprovals,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.analytics_outlined,
                  label: 'Daily report',
                  color: const Color(0xFF1976D2),
                  onTap: onOpenReports,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffTab extends StatelessWidget {
  final VerificationService verificationService;
  final VoidCallback onOpenApprovals;

  const _StaffTab({
    required this.verificationService,
    required this.onOpenApprovals,
  });

  @override
  Widget build(BuildContext context) {
    final applications = verificationService.applications;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _TabIntro(
          title: 'Doctor & nurse management',
          subtitle: 'Review professional documents and account status.',
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onOpenApprovals,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Open verification review'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16806A),
          ),
        ),
        const SizedBox(height: 18),
        if (applications.isEmpty)
          const _EmptyState(
            icon: Icons.badge_outlined,
            text: 'No professional accounts registered yet.',
          )
        else
          ...applications.map(
            (application) => _StaffRow(application: application),
          ),
      ],
    );
  }
}

class _PatientsTab extends StatelessWidget {
  final QueueService queueService;

  const _PatientsTab({required this.queueService});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _TabIntro(
          title: 'Patient management',
          subtitle: 'Monitor today\'s appointments and queue activity.',
        ),
        const SizedBox(height: 18),
        _QueuePanel(queueService: queueService),
        const SizedBox(height: 20),
        if (queueService.patients.isEmpty)
          const _EmptyState(
            icon: Icons.people_outline_rounded,
            text: 'No patients have joined today\'s queue.',
          )
        else
          ...queueService.patients.map(
            (patient) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEAF3FF),
                child: Text(
                  '${patient.token}',
                  style: const TextStyle(color: Color(0xFF1976D2)),
                ),
              ),
              title: Text(
                patient.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${patient.reason} • ${patient.time}'),
              trailing: _StatusPill(status: patient.status),
            ),
          ),
      ],
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final QueueService queueService;

  const _ReportsTab({required this.queueService});

  @override
  Widget build(BuildContext context) {
    final completed = queueService.completedCount;
    final total = queueService.totalPatients;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _TabIntro(
          title: 'Reports & insights',
          subtitle: 'Daily and monthly operational summaries.',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ReportCard(
                'Today',
                '$total patients',
                Icons.today_rounded,
                const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportCard(
                'Completed',
                '$completed visits',
                Icons.check_circle_outline,
                const Color(0xFF16806A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EAF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Queue performance',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16324F),
                ),
              ),
              const SizedBox(height: 18),
              _ProgressLine(
                'Waiting',
                queueService.waitingCount,
                total,
                const Color(0xFF1976D2),
              ),
              _ProgressLine(
                'In consultation',
                queueService.consultationCount,
                total,
                const Color(0xFF6C63B5),
              ),
              _ProgressLine(
                'Completed',
                completed,
                total,
                const Color(0xFF16806A),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Report export is ready for backend integration.',
                    ),
                  ),
                ),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export monthly report'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final QueueService queueService;

  const _AppointmentsTab({required this.queueService});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _TabIntro(
          title: 'Appointment management',
          subtitle: 'Review today\'s bookings and their queue progress.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF16324F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: Color(0xFF8ED7C2),
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${queueService.totalPatients} appointments scheduled today',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (queueService.patients.isEmpty)
          const _EmptyState(
            icon: Icons.calendar_today_outlined,
            text: 'No appointments scheduled for today.',
          )
        else
          ...queueService.patients.map(
            (patient) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EAF3)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF1976D2),
                    size: 19,
                  ),
                ),
                title: Text(
                  patient.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${patient.time} • ${patient.reason}'),
                trailing: _StatusPill(status: patient.status),
              ),
            ),
          ),
      ],
    );
  }
}

class _QueuePanel extends StatelessWidget {
  final QueueService queueService;

  const _QueuePanel({required this.queueService});

  @override
  Widget build(BuildContext context) {
    final next = queueService.patients
        .where((patient) => patient.status == 'Waiting')
        .toList();
    final current = queueService.patients
        .where((patient) => patient.status == 'In Consultation')
        .toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF3FF),
                child: Icon(Icons.queue_rounded, color: Color(0xFF1976D2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  current.isEmpty
                      ? 'No active consultation'
                      : 'Serving ${current.first.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16324F),
                  ),
                ),
              ),
              Text(
                '${next.length} waiting',
                style: const TextStyle(color: Color(0xFF718096)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: next.isEmpty
                      ? null
                      : () {
                          final patient = queueService.callNextPatient();
                          if (patient != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Now serving ${patient.name}.'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('Call next'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: current.isEmpty
                      ? null
                      : () {
                          queueService.completePatient(current.first.id);
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16324F),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const Spacer(),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2EAF3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16324F),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TabIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TabIntro({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Color(0xFF718096))),
      ],
    );
  }
}

class _StaffRow extends StatelessWidget {
  final StaffApplication application;

  const _StaffRow({required this.application});

  @override
  Widget build(BuildContext context) {
    final approved = application.status == StaffApplicationStatus.approved;
    final rejected = application.status == StaffApplicationStatus.rejected;
    final color = approved
        ? const Color(0xFF16806A)
        : rejected
        ? const Color(0xFFD95757)
        : const Color(0xFFFF9F43);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.person_outline, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${application.name}\n${application.role}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF16324F),
              ),
            ),
          ),
          _StatusPill(status: application.status.name),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color =
        normalized.contains('approved') || normalized.contains('completed')
        ? const Color(0xFF16806A)
        : normalized.contains('pending') || normalized.contains('waiting')
        ? const Color(0xFFFF9F43)
        : normalized.contains('consultation')
        ? const Color(0xFF6C63B5)
        : const Color(0xFFD95757);
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

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF16324F),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _ProgressLine(this.label, this.value, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

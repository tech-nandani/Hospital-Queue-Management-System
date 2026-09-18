import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/doctor_service.dart';
import '../../services/queue_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String doctorName;
  final String department;

  const DoctorDashboardScreen({
    super.key,
    this.doctorName = 'Doctor',
    this.department = 'Department',
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final queue = QueueService.instance;
  final doctor = DoctorService.instance;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    queue.addListener(_refresh);
    doctor.addListener(_refresh);
  }

  @override
  void dispose() {
    queue.removeListener(_refresh);
    doctor.removeListener(_refresh);
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
          'Doctor Command Center',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showNotifications(context),
            icon: Badge(
              isLabelVisible: queue.priorityCount > 0,
              label: Text('${queue.priorityCount}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (desktop)
            _DoctorSideRail(
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => selectedIndex = index),
            ),
          Expanded(child: _page(desktop)),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Queue',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Visits',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services),
                  label: 'Consult',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'More',
                ),
              ],
            ),
    );
  }

  Widget _page(bool desktop) {
    switch (selectedIndex) {
      case 1:
        return _QueuePage(queue: queue);
      case 2:
        return _AppointmentsPage(queue: queue);
      case 3:
        return _ConsultationPage(doctor: doctor, queue: queue);
      case 4:
        return _ManagementPage(
          doctor: doctor,
          queue: queue,
          onOpenReports: () => setState(() => selectedIndex = 0),
        );
      default:
        return _OverviewPage(
          queue: queue,
          doctor: doctor,
          doctorName: widget.doctorName,
          department: widget.department,
          onQueue: () => setState(() => selectedIndex = 1),
        );
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _notice(
              Icons.emergency_rounded,
              'Priority patients',
              '${queue.priorityCount} emergency patient(s) need attention.',
              const Color(0xFFD95757),
            ),
            _notice(
              Icons.person_add_alt_1,
              'Patient arrivals',
              '${queue.waitingCount} patient(s) are waiting.',
              const Color(0xFF1976D2),
            ),
            _notice(
              Icons.calendar_today,
              'Appointments',
              'Review today\'s appointment list and cancellations.',
              const Color(0xFF16806A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice(IconData icon, String title, String text, Color color) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(text),
      );
}

class _DoctorSideRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _DoctorSideRail({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const items = [
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.people_rounded, 'Queue Overview'),
    (Icons.calendar_month_rounded, 'Appointments'),
    (Icons.medical_services_rounded, 'Consultation'),
    (Icons.schedule_rounded, 'Availability'),
    (Icons.bar_chart_rounded, 'Reports & Analytics'),
    (Icons.chat_bubble_rounded, 'Messages'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 230,
    color: const Color(0xFF16324F),
    padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 2, 12, 28),
          child: Text(
            'DOCTOR\nSPACE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
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
        ...List.generate(items.length, (index) {
          final item = items[index];
          final active = selectedIndex == (index > 3 ? 4 : index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => onSelected(index > 3 ? 4 : index),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF1976D2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$1,
                      color: active ? Colors.white : const Color(0xFFB8C7D6),
                      size: 19,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFB8C7D6),
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
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
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          leading: CircleAvatar(
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.person, color: Color(0xFF1976D2)),
          ),
          title: Text(
            'Doctor account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Available',
            style: TextStyle(color: Color(0xFF8ED7C2), fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _OverviewPage extends StatelessWidget {
  final QueueService queue;
  final DoctorService doctor;
  final String doctorName;
  final String department;
  final VoidCallback onQueue;

  const _OverviewPage({
    required this.queue,
    required this.doctor,
    required this.doctorName,
    required this.department,
    required this.onQueue,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
    children: [
      _PageTitle(
        title: 'Good morning, $doctorName',
        subtitle:
            '$department • Here is your consultation workspace for today.',
      ),
      const SizedBox(height: 20),
      _StatGrid(queue: queue),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 1000
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _QueueControl(queue: queue, onOpenQueue: onQueue),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: _DonutOverview(queue: queue)),
                ],
              )
            : Column(
                children: [
                  _QueueControl(queue: queue, onOpenQueue: onQueue),
                  const SizedBox(height: 18),
                  _DonutOverview(queue: queue),
                ],
              ),
      ),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 1000
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _UpcomingAppointments(queue: queue)),
                  const SizedBox(width: 18),
                  Expanded(child: _PriorityList(queue: queue)),
                ],
              )
            : Column(
                children: [
                  _UpcomingAppointments(queue: queue),
                  const SizedBox(height: 18),
                  _PriorityList(queue: queue),
                ],
              ),
      ),
      const SizedBox(height: 22),
      _AvailabilityCard(doctor: doctor),
    ],
  );
}

class _StatGrid extends StatelessWidget {
  final QueueService queue;
  const _StatGrid({required this.queue});
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.8,
    children: [
      _Metric(
        'Today\'s appointments',
        '${queue.totalPatients}',
        Icons.calendar_month_rounded,
        const Color(0xFF1976D2),
      ),
      _Metric(
        'Waiting patients',
        '${queue.waitingCount}',
        Icons.hourglass_top_rounded,
        const Color(0xFFFF9F43),
      ),
      _Metric(
        'In consultation',
        '${queue.consultationCount}',
        Icons.medical_services_rounded,
        const Color(0xFF6C63B5),
      ),
      _Metric(
        'Completed',
        '${queue.completedCount}',
        Icons.check_circle_rounded,
        const Color(0xFF16806A),
      ),
      _Metric(
        'Emergency',
        '${queue.priorityCount}',
        Icons.emergency_rounded,
        const Color(0xFFD95757),
      ),
      _Metric(
        'Avg. wait',
        '${queue.averageWaitingMinutes} min',
        Icons.timer_outlined,
        const Color(0xFF1976D2),
      ),
      _Metric(
        'Avg. consultation',
        '18 min',
        Icons.speed_rounded,
        const Color(0xFF16806A),
      ),
      _Metric(
        'No shows',
        '${queue.noShowCount}',
        Icons.person_off_outlined,
        const Color(0xFF718096),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16324F),
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: color),
      ],
    ),
  );
}

class _QueueControl extends StatelessWidget {
  final QueueService queue;
  final VoidCallback onOpenQueue;
  const _QueueControl({required this.queue, required this.onOpenQueue});

  @override
  Widget build(BuildContext context) {
    final active = queue.patients
        .where((p) => p.status == 'In Consultation')
        .toList();
    final waiting = queue.patients.where((p) => p.status == 'Waiting').toList();
    final current = active.isEmpty ? null : active.first;
    return _Panel(
      title: 'Real-time queue management',
      action: 'Open full queue',
      onAction: onOpenQueue,
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
                  current == null
                      ? 'No patient in consultation'
                      : 'Currently seeing ${current.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16324F),
                  ),
                ),
              ),
              Text(
                '${waiting.length} waiting',
                style: const TextStyle(color: Color(0xFF718096)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (waiting.isEmpty)
            const _EmptyLine(text: 'The waiting queue is clear.')
          else
            ...waiting.take(3).map((p) => _QueueRow(patient: p, queue: queue)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: waiting.isEmpty ? null : () => _callNext(context),
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('Call next'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: current == null
                      ? null
                      : () => queue.completePatient(current.id),
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

  void _callNext(BuildContext context) {
    final patient = queue.callNextPatient();
    if (patient != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Now serving ${patient.name}.')));
    }
  }
}

class _QueueRow extends StatelessWidget {
  final QueuePatient patient;
  final QueueService queue;
  const _QueueRow({required this.patient, required this.queue});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: patient.priority == 'High'
              ? const Color(0xFFFFE7E7)
              : const Color(0xFFEAF3FF),
          child: Text(
            '${patient.token}',
            style: TextStyle(
              color: patient.priority == 'High'
                  ? const Color(0xFFD95757)
                  : const Color(0xFF1976D2),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            patient.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          patient.time,
          style: const TextStyle(color: Color(0xFF718096), fontSize: 11),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => queue.updateStatus(patient.id, value),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'In Consultation',
              child: Text('Mark in consultation'),
            ),
            PopupMenuItem(value: 'Completed', child: Text('Mark completed')),
            PopupMenuItem(value: 'No Show', child: Text('Skip patient')),
          ],
          child: const Icon(Icons.more_horiz, color: Color(0xFF718096)),
        ),
      ],
    ),
  );
}

class _DonutOverview extends StatelessWidget {
  final QueueService queue;
  const _DonutOverview({required this.queue});
  @override
  Widget build(BuildContext context) {
    final total = queue.totalPatients == 0 ? 1 : queue.totalPatients;
    return _Panel(
      title: 'Queue overview',
      child: Row(
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 48,
                    sectionsSpace: 3,
                    sections: [
                      _section(
                        queue.waitingCount,
                        total,
                        const Color(0xFFFF9F43),
                      ),
                      _section(
                        queue.consultationCount,
                        total,
                        const Color(0xFF6C63B5),
                      ),
                      _section(
                        queue.completedCount,
                        total,
                        const Color(0xFF16806A),
                      ),
                      _section(
                        queue.noShowCount,
                        total,
                        const Color(0xFFD95757),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${queue.totalPatients}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16324F),
                      ),
                    ),
                    const Text(
                      'Patients',
                      style: TextStyle(color: Color(0xFF718096), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _Legend('Waiting', queue.waitingCount, const Color(0xFFFF9F43)),
                _Legend(
                  'In Consultation',
                  queue.consultationCount,
                  const Color(0xFF6C63B5),
                ),
                _Legend(
                  'Completed',
                  queue.completedCount,
                  const Color(0xFF16806A),
                ),
                _Legend('No Show', queue.noShowCount, const Color(0xFFD95757)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(int value, int total, Color color) =>
      PieChartSectionData(
        value: value == 0 ? 0.01 : value.toDouble(),
        color: color,
        radius: 22,
        showTitle: false,
      );
}

class _Legend extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Legend(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF536B89)),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
      ],
    ),
  );
}

class _UpcomingAppointments extends StatelessWidget {
  final QueueService queue;
  const _UpcomingAppointments({required this.queue});
  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Upcoming appointments',
      action: 'View all',
      onAction: () {},
      child: queue.patients.isEmpty
          ? const _EmptyLine(text: 'No upcoming appointments.')
          : Column(
              children: queue.patients.take(4).map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEAF3FF),
                    child: Text('${p.token}'),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${p.reason} • ${p.time}'),
                  trailing: _StatusBadge(p.status),
                );
              }).toList(),
            ),
    );
  }
}

class _PriorityList extends StatelessWidget {
  final QueueService queue;
  const _PriorityList({required this.queue});
  @override
  Widget build(BuildContext context) {
    final patients = queue.patients
        .where((p) => p.priority == 'High' && p.status != 'Completed')
        .toList();
    return _Panel(
      title: 'Emergency / priority patients',
      child: patients.isEmpty
          ? const _EmptyLine(text: 'No priority patients right now.')
          : Column(
              children: patients
                  .map(
                    (p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.emergency_rounded,
                        color: Color(0xFFD95757),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Token ${p.token} • ${p.reason}'),
                      trailing: const _StatusBadge('Priority'),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final DoctorService doctor;
  const _AvailabilityCard({required this.doctor});
  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Doctor availability',
    action: doctor.availability,
    onAction: () => doctor.setAvailability(
      doctor.availability == 'Available' ? 'Busy' : 'Available',
    ),
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        const _InfoChip('Working days', 'Mon - Fri', Icons.date_range_outlined),
        _InfoChip(
          'Consultation',
          doctor.consultationHours,
          Icons.schedule_outlined,
        ),
        _InfoChip('Break', doctor.breakHours, Icons.free_breakfast_outlined),
        _InfoChip('Status', doctor.availability, Icons.circle),
      ],
    ),
  );
}

class _QueuePage extends StatelessWidget {
  final QueueService queue;
  const _QueuePage({required this.queue});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const _PageTitle(
        title: 'Queue Overview',
        subtitle: 'Manage every patient in real time.',
      ),
      const SizedBox(height: 18),
      _QueueControl(queue: queue, onOpenQueue: () {}),
      const SizedBox(height: 18),
      ...queue.patients.map(
        (p) => _DetailedPatientCard(patient: p, queue: queue),
      ),
    ],
  );
}

class _DetailedPatientCard extends StatelessWidget {
  final QueuePatient patient;
  final QueueService queue;
  const _DetailedPatientCard({required this.patient, required this.queue});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(child: Text('${patient.token}')),
      title: Text(
        patient.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${patient.reason} • Appointment ${patient.time}'),
      trailing: Wrap(
        spacing: 4,
        children: [
          _StatusBadge(patient.status),
          IconButton(
            tooltip: 'Skip',
            onPressed: () => queue.skipPatient(patient.id),
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(
            tooltip: 'Recall',
            onPressed: () => queue.recallPatient(patient.id),
            icon: const Icon(Icons.replay),
          ),
        ],
      ),
    ),
  );
}

class _AppointmentsPage extends StatelessWidget {
  final QueueService queue;
  const _AppointmentsPage({required this.queue});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const _PageTitle(
        title: 'Appointments',
        subtitle: 'Today\'s and upcoming patient appointments.',
      ),
      const SizedBox(height: 18),
      if (queue.patients.isEmpty)
        const _EmptyLine(text: 'No appointments yet.')
      else
        ...queue.patients.map(
          (p) => Card(
            color: Colors.white,
            child: ListTile(
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${p.time} • ${p.reason}'),
              trailing: Wrap(
                children: [
                  TextButton(onPressed: () {}, child: const Text('Accept')),
                  TextButton(onPressed: () {}, child: const Text('Reschedule')),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class _ConsultationPage extends StatefulWidget {
  final DoctorService doctor;
  final QueueService queue;
  const _ConsultationPage({required this.doctor, required this.queue});
  @override
  State<_ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<_ConsultationPage> {
  final symptoms = TextEditingController();
  final diagnosis = TextEditingController();
  final notes = TextEditingController();
  final advice = TextEditingController();
  final medicine = TextEditingController();
  final dosage = TextEditingController();
  final frequency = TextEditingController();
  final duration = TextEditingController();
  @override
  void dispose() {
    for (final c in [
      symptoms,
      diagnosis,
      notes,
      advice,
      medicine,
      dosage,
      frequency,
      duration,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const _PageTitle(
        title: 'Consultation workspace',
        subtitle: 'Record clinical notes and generate a prescription.',
      ),
      const SizedBox(height: 18),
      _FormPanel(
        title: 'Consultation notes',
        fields: [
          (_input('Symptoms', symptoms), 3),
          (_input('Diagnosis', diagnosis), 2),
          (_input('Clinical notes', notes), 3),
          (_input('Treatment and advice', advice), 3),
        ],
        action: ElevatedButton.icon(
          onPressed: () {
            widget.doctor.saveConsultation(
              symptoms: symptoms.text,
              diagnosis: diagnosis.text,
              notes: notes.text,
              advice: advice.text,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Consultation saved.')),
            );
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save consultation'),
        ),
      ),
      const SizedBox(height: 18),
      _FormPanel(
        title: 'Prescription',
        fields: [
          (_input('Medicine name', medicine), 1),
          (_input('Dosage', dosage), 1),
          (_input('Frequency', frequency), 1),
          (_input('Duration', duration), 1),
        ],
        action: ElevatedButton.icon(
          onPressed: () {
            widget.doctor.savePrescription(
              medicineName: medicine.text,
              dosage: dosage.text,
              frequency: frequency.text,
              duration: duration.text,
              instructions: advice.text,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescription saved.')),
            );
          },
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('Generate prescription'),
        ),
      ),
    ],
  );
  TextField _input(String hint, TextEditingController controller) => TextField(
    controller: controller,
    maxLines: 3,
    decoration: InputDecoration(
      labelText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _ManagementPage extends StatelessWidget {
  final DoctorService doctor;
  final QueueService queue;
  final VoidCallback onOpenReports;

  const _ManagementPage({
    required this.doctor,
    required this.queue,
    required this.onOpenReports,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const _PageTitle(
        title: 'Availability & reports',
        subtitle: 'Manage your schedule and review performance.',
      ),
      const SizedBox(height: 18),
      _AvailabilityCard(doctor: doctor),
      const SizedBox(height: 18),
      _Panel(
        title: 'Reports & analytics',
        child: Column(
          children: [
            _ReportLine('Daily patients', queue.totalPatients),
            _ReportLine('Completed consultations', queue.completedCount),
            _ReportLine('Cancelled / no-show', queue.noShowCount),
            _ReportLine(
              'Average waiting time',
              queue.averageWaitingMinutes,
              suffix: ' min',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onOpenReports,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Open dashboard analytics'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _Panel(
        title: 'Patient communication',
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _message(context),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Message patient'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _message(context),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send instructions'),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  void _message(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messaging is ready for backend integration.'),
        ),
      );
}

class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PageTitle({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: Color(0xFF718096))),
    ],
  );
}

class _Panel extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  const _Panel({
    required this.title,
    this.action,
    this.onAction,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2EAF3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16324F),
                ),
              ),
            ),
            if (action != null)
              TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _EmptyLine extends StatelessWidget {
  final String text;
  const _EmptyLine({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(text, style: const TextStyle(color: Color(0xFF718096))),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final color = status == 'Completed'
        ? const Color(0xFF16806A)
        : status == 'In Consultation'
        ? const Color(0xFF6C63B5)
        : status == 'No Show'
        ? const Color(0xFFD95757)
        : const Color(0xFFFF9F43);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoChip(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F8FD),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1976D2)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16324F),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReportLine extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  const _ReportLine(this.label, this.value, {this.suffix = ''});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(
      '$value$suffix',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF16324F),
      ),
    ),
  );
}

class _FormPanel extends StatelessWidget {
  final String title;
  final List<(TextField, int)> fields;
  final Widget action;
  const _FormPanel({
    required this.title,
    required this.fields,
    required this.action,
  });
  @override
  Widget build(BuildContext context) => _Panel(
    title: title,
    child: Column(
      children: [
        ...fields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: field.$1,
          ),
        ),
        Align(alignment: Alignment.centerRight, child: action),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/queue_service.dart';

class NurseDashboardScreen extends StatefulWidget {
  final String nurseName;
  final String department;

  const NurseDashboardScreen({
    super.key,
    this.nurseName = 'Nurse',
    this.department = 'Department',
  });

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  final queue = QueueService.instance;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    queue.addListener(_refresh);
  }

  @override
  void dispose() {
    queue.removeListener(_refresh);
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
          'Nurse Care Center',
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
            _NurseRail(
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => selectedIndex = index),
              department: widget.department,
            ),
          Expanded(child: _page()),
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
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Patients',
                ),
                NavigationDestination(
                  icon: Icon(Icons.monitor_heart_outlined),
                  selectedIcon: Icon(Icons.monitor_heart),
                  label: 'Triage',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'Shift',
                ),
              ],
            ),
    );
  }

  Widget _page() {
    switch (selectedIndex) {
      case 1:
        return _PatientListPage(queue: queue);
      case 2:
        return _TriagePage(queue: queue);
      case 3:
        return _ShiftPage();
      default:
        return _NurseOverview(
          queue: queue,
          nurseName: widget.nurseName,
          department: widget.department,
          onPatients: () => setState(() => selectedIndex = 1),
          onTriage: () => setState(() => selectedIndex = 2),
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
              'Nursing alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFE7E7),
                child: Icon(Icons.emergency, color: Color(0xFFD95757)),
              ),
              title: const Text(
                'Priority patients',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${queue.priorityCount} emergency patient(s) need triage.',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3FF),
                child: Icon(Icons.person_add_alt_1, color: Color(0xFF1976D2)),
              ),
              title: const Text(
                'Waiting queue',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${queue.waitingCount} patient(s) waiting for care.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NurseRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String department;

  const _NurseRail({
    required this.selectedIndex,
    required this.onSelected,
    required this.department,
  });

  static const items = [
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.people_rounded, 'Patients'),
    (Icons.monitor_heart_rounded, 'Triage & Vitals'),
    (Icons.schedule_rounded, 'Shift & Availability'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 230,
    color: const Color(0xFF155B63),
    padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 2, 12, 28),
          child: Text(
            'NURSE\nSPACE',
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
            'PATIENT CARE',
            style: TextStyle(
              color: Color(0xFFA8DAD4),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(items.length, (index) {
          final active = selectedIndex == index;
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF16806A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$1,
                      color: active ? Colors.white : const Color(0xFFC0D8D7),
                      size: 19,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFC0D8D7),
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
        const Divider(color: Color(0xFF3B7779)),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFDFF3ED),
            child: Icon(Icons.medical_services, color: Color(0xFF16806A)),
          ),
          title: const Text(
            'Nurse account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            department,
            style: const TextStyle(color: Color(0xFFA8DAD4), fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _NurseOverview extends StatelessWidget {
  final QueueService queue;
  final String nurseName;
  final String department;
  final VoidCallback onPatients;
  final VoidCallback onTriage;

  const _NurseOverview({
    required this.queue,
    required this.nurseName,
    required this.department,
    required this.onPatients,
    required this.onTriage,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
    children: [
      Text(
        'Good morning, $nurseName',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        '$department • Patient care workspace',
        style: const TextStyle(color: Color(0xFF718096)),
      ),
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
        children: [
          _NurseMetric(
            'Waiting patients',
            '${queue.waitingCount}',
            Icons.hourglass_top,
            const Color(0xFFFF9F43),
          ),
          _NurseMetric(
            'Priority patients',
            '${queue.priorityCount}',
            Icons.emergency,
            const Color(0xFFD95757),
          ),
          _NurseMetric(
            'In consultation',
            '${queue.consultationCount}',
            Icons.medical_services,
            const Color(0xFF6C63B5),
          ),
          _NurseMetric(
            'Completed today',
            '${queue.completedCount}',
            Icons.check_circle,
            const Color(0xFF16806A),
          ),
        ],
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: _NurseAction(
              title: 'Patient queue',
              subtitle: 'Prepare and call patients',
              icon: Icons.people,
              color: const Color(0xFF1976D2),
              onTap: onPatients,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NurseAction(
              title: 'Triage & vitals',
              subtitle: 'Record patient readiness',
              icon: Icons.monitor_heart,
              color: const Color(0xFF16806A),
              onTap: onTriage,
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      _NursePanel(
        title: 'Next patient to prepare',
        child: queue.patients.isEmpty
            ? const Text(
                'No patients in the queue.',
                style: TextStyle(color: Color(0xFF718096)),
              )
            : _PatientSummary(patient: queue.patients.first),
      ),
      const SizedBox(height: 18),
      _NursePanel(
        title: 'Nurse responsibilities',
        child: Column(
          children: const [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.fact_check_outlined,
                color: Color(0xFF16806A),
              ),
              title: Text('Verify patient arrival'),
              subtitle: Text('Confirm identity and appointment details.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.favorite_border, color: Color(0xFF16806A)),
              title: Text('Record vital signs'),
              subtitle: Text('Prepare the doctor with current observations.'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _NurseMetric extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _NurseMetric(this.title, this.value, this.icon, this.color);

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
                title,
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

class _PatientListPage extends StatelessWidget {
  final QueueService queue;
  const _PatientListPage({required this.queue});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'Patient queue',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Check in patients and prepare them for consultation.',
        style: TextStyle(color: Color(0xFF718096)),
      ),
      const SizedBox(height: 18),
      ...queue.patients.map(
        (p) => Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(child: Text('${p.token}')),
            title: Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${p.reason} • ${p.time}'),
            trailing: TextButton(
              onPressed: () => queue.updateStatus(p.id, 'In Consultation'),
              child: const Text('Prepare'),
            ),
          ),
        ),
      ),
    ],
  );
}

class _TriagePage extends StatelessWidget {
  final QueueService queue;
  const _TriagePage({required this.queue});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'Triage & vitals',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Record patient readiness before the consultation.',
        style: TextStyle(color: Color(0xFF718096)),
      ),
      const SizedBox(height: 18),
      ...queue.patients
          .where((p) => p.status != 'Completed')
          .map((p) => _TriageCard(patient: p, queue: queue)),
    ],
  );
}

class _TriageCard extends StatelessWidget {
  final QueuePatient patient;
  final QueueService queue;

  const _TriageCard({required this.patient, required this.queue});

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16324F),
                  ),
                ),
              ),
              _StatusBadge(patient.status),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Temperature',
                    suffixText: '°C',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Blood pressure'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Pulse',
                    suffixText: 'bpm',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => queue.updateStatus(patient.id, 'Waiting'),
              child: const Text('Save vitals'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShiftPage extends StatelessWidget {
  const _ShiftPage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'Shift & availability',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF16324F),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Your schedule and availability are managed here.',
        style: TextStyle(color: Color(0xFF718096)),
      ),
      const SizedBox(height: 18),
      _NursePanel(
        title: 'Today\'s shift',
        child: Column(
          children: const [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule, color: Color(0xFF16806A)),
              title: Text('09:00 AM - 05:00 PM'),
              subtitle: Text('Break: 01:00 PM - 02:00 PM'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event_available, color: Color(0xFF16806A)),
              title: Text('Status: Available'),
              subtitle: Text('Accepting patient preparation tasks.'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _PatientSummary extends StatelessWidget {
  final QueuePatient patient;
  const _PatientSummary({required this.patient});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: const Color(0xFFEAF3FF),
      child: Text('${patient.token}'),
    ),
    title: Text(
      patient.name,
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    subtitle: Text('${patient.reason} • Appointment ${patient.time}'),
    trailing: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF16806A)),
  );
}

class _NurseAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NurseAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
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
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16324F),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    ),
  );
}

class _NursePanel extends StatelessWidget {
  final String title;
  final Widget child;
  const _NursePanel({required this.title, required this.child});
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF3FF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      status,
      style: const TextStyle(
        color: Color(0xFF1976D2),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

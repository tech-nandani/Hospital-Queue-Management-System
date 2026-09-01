import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/queue_patient.dart';
import '../../services/queue_service.dart';
import '../queue/today_queue_screen.dart';
import '../queue/add_patient_screen.dart';
import '../../widgets/hospital_sidebar.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  final QueueService queueService = QueueService.instance;

  @override
  void initState() {
    super.initState();
    queueService.addListener(_refresh);
  }

  @override
  void dispose() {
    queueService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openQueue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TodayQueueScreen(),
      ),
    );
  }

  void _openAddPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPatientScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      drawer: Drawer(
        backgroundColor: const Color(0xFFF4F8FD),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: HospitalSidebar(
              selectedPage: HospitalSidebarPage.dashboard,

              onDashboardTap: () {
                Navigator.of(context).pop();
              },

              onTodayQueueTap: () {
                Navigator.of(context).pop();
                _openQueue();
              },

              onAddPatientTap: () {
                Navigator.of(context).pop();
                _openAddPatient();
              },
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            return Row(
              children: [

                if (isDesktop)
                  HospitalSidebar(
                    selectedPage: HospitalSidebarPage.dashboard,
                    onTodayQueueTap: _openQueue,
                    onAddPatientTap: _openAddPatient,
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28 : 18,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (!isDesktop)
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  return InkWell(
                                    onTap: () {
                                      Scaffold.of(context)
                                          .openDrawer();
                                    },
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    child: Container(
                                      height: 46,
                                      width: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFDCE6F2,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.menu_rounded,
                                        color:
                                        Color(0xFF16324F),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Hospital Queue',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    Color(0xFF16324F),
                                  ),
                                ),
                              ),
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                    const Color(0xFFDCE6F2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .notifications_none_rounded,
                                  color:
                                  Color(0xFF536B89),
                                ),
                              ),
                            ],
                          ),

                        if (!isDesktop)
                          const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good Morning, Doctor! 👋',
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight:
                                      FontWeight.bold,
                                      color:
                                      Color(0xFF16324F),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Here’s what’s happening in your department today.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                      Color(0xFF748196),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isDesktop)
                              const _ProfileHeader(),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ================================
                        // STATISTICS
                        // ================================

                        LayoutBuilder(
                          builder: (context, c) {
                            int columns;

                            if (c.maxWidth >= 1200) {
                              columns = 4;
                            } else if (c.maxWidth >= 700) {
                              columns = 2;
                            } else {
                              columns = 1;
                            }

                            final cardWidth =
                                (c.maxWidth -
                                    ((columns - 1) * 14)) /
                                    columns;

                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _StatCard(
                                    title:
                                    'Total Patients Today',
                                    value:
                                    '${queueService.totalPatients}',
                                    subtitle:
                                    queueService.totalPatients ==
                                        0
                                        ? 'No patients yet'
                                        : 'Patients registered today',
                                    icon: Icons
                                        .people_alt_rounded,
                                    color:
                                    const Color(0xFF6C63B5),
                                    background:
                                    const Color(0xFFF0EEFF),
                                  ),
                                ),

                                SizedBox(
                                  width: cardWidth,
                                  child: _StatCard(
                                    title:
                                    'Patients in Queue',
                                    value:
                                    '${queueService.queueCount}',
                                    subtitle:
                                    queueService.queueCount ==
                                        0
                                        ? 'Queue is empty'
                                        : 'Patients currently active',
                                    icon:
                                    Icons.groups_rounded,
                                    color:
                                    const Color(0xFF1976D2),
                                    background:
                                    const Color(0xFFEAF3FF),
                                  ),
                                ),

                                SizedBox(
                                  width: cardWidth,
                                  child: const _StatCard(
                                    title:
                                    'Avg. Waiting Time',
                                    value: '—',
                                    subtitle:
                                    'Waiting data will appear here',
                                    icon:
                                    Icons.access_time_rounded,
                                    color:
                                    Color(0xFF3A8D68),
                                    background:
                                    Color(0xFFEAF8F2),
                                  ),
                                ),

                                SizedBox(
                                  width: cardWidth,
                                  child: _StatCard(
                                    title:
                                    'Completed Today',
                                    value:
                                    '${queueService.completedCount}',
                                    subtitle:
                                    queueService.completedCount ==
                                        0
                                        ? 'No completed patients'
                                        : 'Patients completed today',
                                    icon:
                                    Icons.task_alt_rounded,
                                    color:
                                    const Color(0xFFE76A91),
                                    background:
                                    const Color(0xFFFFEEF3),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // ================================
                        // CURRENT QUEUE + OVERVIEW
                        // ================================

                        LayoutBuilder(
                          builder: (context, c) {
                            if (c.maxWidth >= 1000) {
                              return Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                    _CurrentQueueCard(
                                      onTap: _openQueue,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Expanded(
                                    child:
                                    _QueueOverviewCard(),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                _CurrentQueueCard(
                                  onTap: _openQueue,
                                ),
                                const SizedBox(height: 18),
                                const _QueueOverviewCard(),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        LayoutBuilder(
                          builder: (context, c) {
                            if (c.maxWidth >= 1000) {
                              return const Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _ScheduleCard(),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child:
                                    _PriorityPatientsCard(),
                                  ),
                                ],
                              );
                            }

                            return const Column(
                              children: [
                                _ScheduleCard(),
                                SizedBox(height: 18),
                                _PriorityPatientsCard(),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        const _AlertsCard(),

                        const SizedBox(height: 24),

                        _QuickActions(
                          onAddPatient: _openAddPatient,
                          onGenerateToken: _openAddPatient,
                          onQueueTap: _openQueue,
                        ),

                        const SizedBox(height: 24),

                        const _AiAssistantCard(),

                        const SizedBox(height: 22),

                        const Center(
                          child: Text(
                            'SMART CARE • BETTER EXPERIENCE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9AA5B4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE HEADER
// ============================================================

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor / Nurse',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16324F),
                ),
              ),
              Text(
                'Department',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF748196),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIDEBAR
// ============================================================



// ============================================================
// SIDEBAR ITEM
// ============================================================


// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF536B89),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16324F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: background,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD CARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16324F),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// CURRENT QUEUE
// ============================================================

class _CurrentQueueCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CurrentQueueCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final queue = QueueService.instance;

    final activePatients = queue.patients
        .where(
          (p) =>
      p.status == 'Waiting' ||
          p.status == 'In Consultation',
    )
        .toList();

    return _DashboardCard(
      title: 'Current Queue',
      child: activePatients.isEmpty
          ? const _EmptyState(
        icon:
        Icons.people_outline_rounded,
        title: 'No patients in queue',
        subtitle:
        'Add a patient to start managing today’s queue.',
      )
          : Column(
        children: [
          ...activePatients
              .take(4)
              .map(
                (patient) =>
                _DashboardPatientRow(
                  patient: patient,
                ),
          ),
          if (activePatients.length > 4)
            TextButton(
              onPressed: onTap,
              child: Text(
                'View all ${activePatients.length} patients',
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PATIENT ROW
// ============================================================

class _DashboardPatientRow
    extends StatelessWidget {
  final QueuePatient patient;

  const _DashboardPatientRow({
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final bool highPriority =
        patient.priority == 'High';

    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'T${patient.token}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16324F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  patient.status,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF748196),
                  ),
                ),
              ],
            ),
          ),

          if (highPriority)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                const Color(0xFFFFEEF3),
                borderRadius:
                BorderRadius.circular(7),
              ),
              child: const Text(
                'HIGH',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE76A91),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// QUEUE OVERVIEW + DONUT CHART
// ============================================================

class _QueueOverviewCard
    extends StatelessWidget {
  const _QueueOverviewCard();

  @override
  Widget build(BuildContext context) {
    final queue = QueueService.instance;

    final int total =
        queue.waitingCount +
            queue.consultationCount +
            queue.completedCount +
            queue.noShowCount;

    return _DashboardCard(
      title: 'Queue Overview',
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: total == 0
                ? const _EmptyChart()
                : Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 58,
                    sectionsSpace: 3,
                    borderData:
                    FlBorderData(
                      show: false,
                    ),
                    sections: [
                      PieChartSectionData(
                        value: queue
                            .waitingCount
                            .toDouble(),
                        color:
                        const Color(
                          0xFF8B6FE8,
                        ),
                        radius: 52,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: queue
                            .consultationCount
                            .toDouble(),
                        color:
                        const Color(
                          0xFF1976D2,
                        ),
                        radius: 52,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: queue
                            .completedCount
                            .toDouble(),
                        color:
                        const Color(
                          0xFF3A8D68,
                        ),
                        radius: 52,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: queue
                            .noShowCount
                            .toDouble(),
                        color:
                        const Color(
                          0xFFE76A91,
                        ),
                        radius: 52,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Text(
                      '$total',
                      style:
                      const TextStyle(
                        fontSize: 25,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xFF16324F),
                      ),
                    ),
                    const Text(
                      'Total',
                      style:
                      TextStyle(
                        fontSize: 10,
                        color:
                        Color(0xFF748196),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _ChartLegend(
            title: 'Waiting',
            value: queue.waitingCount,
            color:
            const Color(0xFF8B6FE8),
          ),

          _ChartLegend(
            title: 'In Consultation',
            value: queue.consultationCount,
            color:
            const Color(0xFF1976D2),
          ),

          _ChartLegend(
            title: 'Completed',
            value: queue.completedCount,
            color:
            const Color(0xFF3A8D68),
          ),

          _ChartLegend(
            title: 'No Show',
            value: queue.noShowCount,
            color:
            const Color(0xFFE76A91),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY CHART
// ============================================================

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 145,
          width: 145,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 25,
            backgroundColor:
            const Color(0xFFEAF0F7),
            valueColor:
            const AlwaysStoppedAnimation(
              Color(0xFFEAF0F7),
            ),
          ),
        ),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '0',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            Text(
              'Patients',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF748196),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// CHART LEGEND
// ============================================================

class _ChartLegend
    extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _ChartLegend({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Container(
            height: 9,
            width: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF536B89),
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16324F),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCHEDULE
// ============================================================

class _ScheduleCard
    extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      title: "Today's Schedule",
      child: _EmptyState(
        icon:
        Icons.calendar_month_outlined,
        title: 'No schedule available',
        subtitle:
        'Appointments and working hours will appear here.',
      ),
    );
  }
}

// ============================================================
// PRIORITY PATIENTS
// ============================================================

class _PriorityPatientsCard
    extends StatelessWidget {
  const _PriorityPatientsCard();

  @override
  Widget build(BuildContext context) {
    final queue = QueueService.instance;

    final priorityPatients = queue.patients
        .where(
          (p) =>
      p.priority == 'High' &&
          p.status != 'Completed' &&
          p.status != 'No Show',
    )
        .toList();

    return _DashboardCard(
      title: 'Priority Patients',
      child: priorityPatients.isEmpty
          ? const _EmptyState(
        icon:
        Icons.priority_high_rounded,
        title: 'No priority patients',
        subtitle:
        'High priority patients will appear here.',
      )
          : Column(
        children: priorityPatients
            .take(4)
            .map(
              (patient) =>
              _DashboardPatientRow(
                patient: patient,
              ),
        )
            .toList(),
      ),
    );
  }
}

// ============================================================
// ALERTS
// ============================================================

class _AlertsCard
    extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      title: 'Alerts & Notifications',
      child: _EmptyState(
        icon:
        Icons.notifications_none_rounded,
        title: 'No new alerts',
        subtitle:
        'Queue and appointment notifications will appear here.',
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS
// ============================================================

class _QuickActions
    extends StatelessWidget {
  final VoidCallback onAddPatient;
  final VoidCallback onGenerateToken;
  final VoidCallback onQueueTap;

  const _QuickActions({
    required this.onAddPatient,
    required this.onGenerateToken,
    required this.onQueueTap,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Quick Actions',
      child: LayoutBuilder(
        builder: (context, c) {
          final bool wide = c.maxWidth >= 600;

          final double actionWidth = wide
              ? (c.maxWidth - 36) / 4
              : (c.maxWidth - 12) / 2;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
            _Action(
            width: actionWidth,
            icon:
            Icons.person_add_alt_1_rounded,
            title: 'Add Patient',
            color:
            const Color(0xFF6C63B5),
            background:
            const Color(0xFFF0EEFF),
            onTap: onAddPatient,
          ),

          _Action(
          width: actionWidth,
          icon:
          Icons.confirmation_number_rounded,
          title: 'Generate Token',
          color:
          const Color(0xFF1976D2),
          background:
          const Color(0xFFEAF3FF),
          onTap: onGenerateToken,
          ),

          _Action(
          width: actionWidth,
          icon: Icons.groups_rounded,
            title: "Today's Queue",
          color:
          const Color(0xFF3A8D68),
          background:
          const Color(0xFFEAF8F2),
          onTap: onQueueTap,
          ),

          _Action(
          width: actionWidth,
          icon:
          Icons.print_rounded,
          title: 'Print Reports',
          color:
          const Color(0xFFE76A91),
          background:
          const Color(0xFFFFEEF3),
          onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
          const SnackBar(
          content: Text(
          'Reports will be connected later.',
          ),
          ),
          );
          },
          ),
          ],
          );
        },
      ),
    );
  }
}

// ============================================================
// ACTION
// ============================================================

class _Action extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  const _Action({
    required this.width,
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        width: width,
        padding:
        const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color:
                const Color(0xFFEAF3FF),
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color:
                const Color(0xFF1976D2),
                size: 27,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF748196),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AI ASSISTANT
// ============================================================

class _AiAssistantCard
    extends StatelessWidget {
  const _AiAssistantCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'AI Assistant will be connected here.',
            ),
          ),
        );
      },
      borderRadius:
      BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFDCE6F2),
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
              Color(0xFFEAF3FF),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16324F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your hospital AI assistant will help manage queues and patient information.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF748196),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: Color(0xFF9AA8BA),
            ),
          ],
        ),
      ),
    );
  }
}
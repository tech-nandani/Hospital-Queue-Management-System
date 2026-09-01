import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/queue_service.dart';
import '../../widgets/hospital_sidebar.dart';
import '../doctor/doctor_dashboard_screen.dart';

const Color pink = Color(0xFFE76A91);
const Color orange = Color(0xFFFF9F43);
const Color bg = Color(0xFFF4F8FD);
const Color navy = Color(0xFF16324F);
const Color blue = Color(0xFF1976D2);
const Color lavender = Color(0xFF6C63B5);
const Color green = Color(0xFF3A8D68);


class TodayQueueScreen extends StatelessWidget {
  const TodayQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = QueueService.instance;

    return Scaffold(
      backgroundColor: bg,

      // ==========================================================
      // MOBILE DRAWER
      // ==========================================================
      drawer: Drawer(
        backgroundColor: bg,
        child: SafeArea(
          child: HospitalSidebar(
            selectedPage: HospitalSidebarPage.todayQueue,
            onDashboardTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const DoctorDashboardScreen(),
                  ),
                );
            },
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool desktop = constraints.maxWidth >= 1000;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (desktop)
                      HospitalSidebar(
                        selectedPage: HospitalSidebarPage.todayQueue,
                        onDashboardTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const DoctorDashboardScreen(),
                            ),
                          );
                        },
                      ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: desktop ? 28 : 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TopBar(desktop: desktop),

                            const SizedBox(height: 22),

                            _PageHeader(desktop: desktop),

                            const SizedBox(height: 20),

                            _Statistics(service: service),

                            const SizedBox(height: 22),

                            // ==================================================
                            // CURRENT QUEUE + SUMMARY
                            // ==================================================
                            LayoutBuilder(
                              builder: (context, box) {
                                if (box.maxWidth >= 1050) {
                                  return Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _CurrentQueue(
                                          service: service,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: _QueueSummary(
                                          service: service,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _CurrentQueue(
                                      service: service,
                                    ),
                                    const SizedBox(height: 18),
                                    _QueueSummary(
                                      service: service,
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            // ==================================================
                            // PRIORITY + ANALYTICS
                            // ==================================================
                            LayoutBuilder(
                              builder: (context, box) {
                                if (box.maxWidth >= 850) {
                                  return Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _PriorityPatients(
                                          service: service,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: _QuickAnalytics(
                                          service: service,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _PriorityPatients(
                                      service: service,
                                    ),
                                    const SizedBox(height: 18),
                                    _QuickAnalytics(
                                      service: service,
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            const _AiTip(),

                            const SizedBox(height: 20),

                            const Center(
                              child: Text(
                                'SMART CARE • BETTER EXPERIENCE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF9AA5B4),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),

      // ==========================================================
      // AI ASSISTANT
      // ==========================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: lavender,
        elevation: 6,
        tooltip: 'AI Assistant',
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('AI Assistant coming soon 🤖'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class _TopBar extends StatelessWidget {
  final bool desktop;

  const _TopBar({
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!desktop)
          Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFDCE6F2),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: navy,
                  ),
                ),
              );
            },
          ),

        if (!desktop) const SizedBox(width: 12),

        if (desktop)
          const Icon(
            Icons.menu_rounded,
            size: 28,
            color: navy,
          ),

        if (desktop) const SizedBox(width: 16),

        if (desktop)
          Expanded(
            child: Container(
              height: 48,
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFDCE6F2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6E8199),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search patients, token, or anything...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8CA3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Expanded(
            child: Text(
              "Today's Queue",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ),

        const SizedBox(width: 12),

        const _TopIcon(),

        if (desktop) ...[
          const SizedBox(width: 12),
          const _TopDate(),
          const SizedBox(width: 12),
          const _DoctorProfile(),
        ],
      ],
    );
  }
}

// ============================================================================
// TOP ICON
// ============================================================================

class _TopIcon extends StatelessWidget {
  const _TopIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: const Icon(
        Icons.notifications_none_rounded,
        color: navy,
        size: 22,
      ),
    );
  }
}

// ============================================================================
// DATE
// ============================================================================

class _TopDate extends StatelessWidget {
  const _TopDate();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${now.day} ${_month(now.month)} ${now.year}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  String _month(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }
}

// ============================================================================
// DOCTOR PROFILE
// ============================================================================

class _DoctorProfile extends StatelessWidget {
  const _DoctorProfile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(
              Icons.person_rounded,
              color: blue,
            ),
          ),
          SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor / Nurse',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              Text(
                'General Department',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF748196),
                ),
              ),
            ],
          ),
          SizedBox(width: 9),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 19,
            color: Color(0xFF748196),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAGE HEADER
// ============================================================================

class _PageHeader extends StatelessWidget {
  final bool desktop;

  const _PageHeader({
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (!desktop) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Queue",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Manage and monitor today’s patient queue in real-time.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF748196),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Queue",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Manage and monitor today’s patient queue in real-time.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF748196),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 18),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFDCE6F2),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: blue,
                size: 21,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF748196),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'General Medicine',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 13),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 19,
                color: Color(0xFF748196),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STATISTICS
// ============================================================================

class _Statistics extends StatelessWidget {
  final QueueService service;

  const _Statistics({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData(
        title: 'Total Patients',
        value: '${service.totalPatients}',
        subtitle: service.totalPatients == 0
            ? 'No patients yet'
            : 'Patients today',
        icon: Icons.groups_rounded,
        color: lavender,
        background: const Color(0xFFF0EEFF),
      ),
      _StatData(
        title: 'Patients Waiting',
        value: '${service.waitingCount}',
        subtitle: service.waitingCount == 0
            ? 'Queue is empty'
            : 'Currently waiting',
        icon: Icons.hourglass_top_rounded,
        color: blue,
        background: const Color(0xFFEAF3FF),
      ),
      _StatData(
        title: 'Avg. Waiting Time',
        value: _averageWaiting(),
        subtitle: service.waitingCount == 0
            ? 'No waiting data'
            : 'Based on active queue',
        icon: Icons.access_time_rounded,
        color: green,
        background: const Color(0xFFEAF8F2),
      ),
      _StatData(
        title: 'Completed Today',
        value: '${service.completedCount}',
        subtitle: service.completedCount == 0
            ? 'No completed patients'
            : 'Patients completed',
        icon: Icons.task_alt_rounded,
        color: pink,
        background: const Color(0xFFFFEEF3),
      ),
      const _StatData(
        title: 'Upcoming Appointments',
        value: '0',
        subtitle: 'No appointments yet',
        icon: Icons.calendar_month_rounded,
        color: orange,
        background: Color(0xFFFFF4E6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 1250) {
          columns = 5;
        } else if (constraints.maxWidth >= 850) {
          columns = 3;
        } else if (constraints.maxWidth >= 560) {
          columns = 2;
        } else {
          columns = 1;
        }

        final width =
            (constraints.maxWidth - ((columns - 1) * 14)) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards.map((data) {
            return SizedBox(
              width: width,
              child: _StatCard(data: data),
            );
          }).toList(),
        );
      },
    );
  }

  String _averageWaiting() {
    final waiting = service.patients
        .where((p) => p.status == 'Waiting')
        .toList();

    if (waiting.isEmpty) return '—';

    int total = 0;
    int count = 0;

    for (final patient in waiting) {
      final minutes = _minutesSince(patient.time);

      if (minutes >= 0) {
        total += minutes;
        count++;
      }
    }

    if (count == 0) return '—';

    return '${(total / count).round()} min';
  }

  int _minutesSince(String time) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(time.trim());

    if (match == null) return -1;

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    final now = DateTime.now();

    var created = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (created.isAfter(now)) {
      created = created.subtract(
        const Duration(days: 1),
      );
    }

    return now.difference(created).inMinutes;
  }
}

// ============================================================================
// STAT DATA
// ============================================================================

class _StatData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
  });
}

// ============================================================================
// STAT CARD
// ============================================================================

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 125,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
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
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF536B89),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: data.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CURRENT QUEUE
// ============================================================================

class _CurrentQueue extends StatelessWidget {
  final QueueService service;

  const _CurrentQueue({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final patients = service.patients
        .where(
          (p) =>
      p.status == 'Waiting' ||
          p.status == 'In Consultation',
    )
        .toList();

    return _Card(
      title: 'Current Queue',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${patients.length} active',
              style: const TextStyle(
                fontSize: 9,
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // COMPACT BUTTON
          ElevatedButton.icon(
            onPressed: () {
              final next = service.callNextPatient();

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      next == null
                          ? 'No waiting patient available.'
                          : 'Calling ${next.name} — Token A-${next.token.toString().padLeft(2, '0')}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            icon: const Icon(
              Icons.campaign_rounded,
              size: 15,
            ),
            label: const Text(
              'Call Next Patient',
              maxLines: 1,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      child: patients.isEmpty
          ? const _EmptyQueue()
          : LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: patients
                  .map(
                    (patient) => _MobileQueueRow(
                  patient: patient,
                ),
              )
                  .toList(),
            );
          }

          return Column(
            children: [
              const _QueueHeader(),
              const SizedBox(height: 7),
              ...patients.map(
                    (patient) => _QueueRow(
                  patient: patient,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// QUEUE HEADER
// ============================================================================

class _QueueHeader extends StatelessWidget {
  const _QueueHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              'Token No.',
              style: _headerStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Patient Name',
              style: _headerStyle,
            ),
          ),
          Expanded(
            child: Text(
              'Age',
              style: _headerStyle,
            ),
          ),
          Expanded(
            child: Text(
              'Time',
              style: _headerStyle,
            ),
          ),
          Expanded(
            child: Text(
              'Wait Time',
              style: _headerStyle,
            ),
          ),
          Expanded(
            child: Text(
              'Priority',
              style: _headerStyle,
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: _headerStyle,
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w600,
  color: Color(0xFF6E8199),
);

// ============================================================================
// QUEUE ROW
// ============================================================================

class _QueueRow extends StatelessWidget {
  final QueuePatient patient;

  const _QueueRow({
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final high = patient.priority == 'High';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: high
            ? const Color(0xFFFFFAF1)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              'A-${patient.token.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              patient.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
          ),

          Expanded(
            child: Text(
              '${patient.age}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF536B89),
              ),
            ),
          ),

          Expanded(
            child: Text(
              patient.time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF536B89),
              ),
            ),
          ),

          Expanded(
            child: Text(
              _waitTime(patient.time),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF536B89),
              ),
            ),
          ),

          Expanded(
            child: _StatusBadge(
              text: patient.priority,
              type: patient.priority,
            ),
          ),

          Expanded(
            child: _StatusBadge(
              text: patient.status,
              type: patient.status,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MOBILE QUEUE ROW
// ============================================================================

class _MobileQueueRow extends StatelessWidget {
  final QueuePatient patient;

  const _MobileQueueRow({
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: patient.priority == 'High'
            ? const Color(0xFFFFFAF1)
            : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE5EBF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'A-${patient.token.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.age} years • ${patient.gender}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF748196),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.time} • ${_waitTime(patient.time)} wait',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF748196),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Flexible(
            child: _StatusBadge(
              text: patient.status,
              type: patient.status,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WAIT TIME
// ============================================================================

String _waitTime(String time) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(time.trim());

  if (match == null) return '—';

  int hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)!.toUpperCase();

  if (period == 'AM' && hour == 12) {
    hour = 0;
  }

  if (period == 'PM' && hour != 12) {
    hour += 12;
  }

  final now = DateTime.now();

  var created = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (created.isAfter(now)) {
    created = created.subtract(
      const Duration(days: 1),
    );
  }

  final minutes = now.difference(created).inMinutes;

  if (minutes < 1) return '<1 min';

  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final remaining = minutes % 60;

  if (remaining == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remaining}m';
}

// ============================================================================
// EMPTY QUEUE
// ============================================================================

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 45,
      ),
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFEAF3FF),
              child: Icon(
                Icons.people_outline_rounded,
                color: blue,
                size: 30,
              ),
            ),
            SizedBox(height: 14),
            Text(
              'No patients in queue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Patients added to the queue will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF748196),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// QUEUE SUMMARY
// ============================================================================

class _QueueSummary extends StatelessWidget {
  final QueueService service;

  const _QueueSummary({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        service.waitingCount +
            service.consultationCount +
            service.completedCount +
            service.noShowCount;

    return _Card(
      title: 'Queue Summary',
      trailing: const Icon(
        Icons.insights_rounded,
        size: 19,
        color: blue,
      ),
      child: SizedBox(
        height: 245,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 350) {
              return Column(
                children: [
                  Expanded(
                    child: _DonutChart(
                      waiting: service.waitingCount,
                      consultation: service.consultationCount,
                      completed: service.completedCount,
                      noShow: service.noShowCount,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _LegendList(
                      service: service,
                      total: total,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _DonutChart(
                    waiting: service.waitingCount,
                    consultation: service.consultationCount,
                    completed: service.completedCount,
                    noShow: service.noShowCount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LegendList(
                    service: service,
                    total: total,
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

// ============================================================================
// DONUT
// ============================================================================

class _DonutChart extends StatelessWidget {
  final int waiting;
  final int consultation;
  final int completed;
  final int noShow;

  const _DonutChart({
    required this.waiting,
    required this.consultation,
    required this.completed,
    required this.noShow,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        waiting +
            consultation +
            completed +
            noShow;

    if (total == 0) {
      return Center(
        child: Container(
          height: 145,
          width: 145,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5EAF2),
              width: 22,
            ),
          ),
          child: const Center(
            child: Text(
              '0\nTotal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        centerSpaceRadius: 47,
        sectionsSpace: 2,
        sections: [
          PieChartSectionData(
            value: waiting.toDouble(),
            color: const Color(0xFF8B6DEB),
            radius: 30,
            showTitle: false,
          ),
          PieChartSectionData(
            value: consultation.toDouble(),
            color: const Color(0xFF4C8BF5),
            radius: 30,
            showTitle: false,
          ),
          PieChartSectionData(
            value: completed.toDouble(),
            color: const Color(0xFF55C991),
            radius: 30,
            showTitle: false,
          ),
          PieChartSectionData(
            value: noShow.toDouble(),
            color: pink,
            radius: 30,
            showTitle: false,
          ),
        ],
        centerSpaceColor: Colors.white,
      ),
      swapAnimationDuration: const Duration(
        milliseconds: 450,
      ),
    );
  }
}

// ============================================================================
// LEGEND
// ============================================================================

class _LegendList extends StatelessWidget {
  final QueueService service;
  final int total;

  const _LegendList({
    required this.service,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendRow(
          color: const Color(0xFF8B6DEB),
          title: 'Waiting',
          value: service.waitingCount,
          total: total,
        ),
        const SizedBox(height: 13),
        _LegendRow(
          color: const Color(0xFF4C8BF5),
          title: 'In Consultation',
          value: service.consultationCount,
          total: total,
        ),
        const SizedBox(height: 13),
        _LegendRow(
          color: const Color(0xFF55C991),
          title: 'Completed',
          value: service.completedCount,
          total: total,
        ),
        const SizedBox(height: 13),
        _LegendRow(
          color: pink,
          title: 'No Show',
          value: service.noShowCount,
          total: total,
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String title;
  final int value;
  final int total;

  const _LegendRow({
    required this.color,
    required this.title,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    total == 0 ? 0 : ((value / total) * 100).round();

    return Row(
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF536B89),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value ($percentage%)',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PRIORITY PATIENTS
// ============================================================================

class _PriorityPatients extends StatelessWidget {
  final QueueService service;

  const _PriorityPatients({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final patients = service.patients
        .where(
          (p) =>
      p.priority == 'High' &&
          p.status != 'Completed' &&
          p.status != 'No Show',
    )
        .toList();

    return _Card(
      title: 'Priority Patients',
      trailing: Text(
        '${patients.length} patients',
        style: const TextStyle(
          fontSize: 9,
          color: pink,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: patients.isEmpty
          ? const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: Center(
          child: Text(
            'No high-priority patients right now.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF748196),
            ),
          ),
        ),
      )
          : Column(
        children: patients.map(
              (patient) {
            return Container(
              margin: const EdgeInsets.only(
                bottom: 8,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFDDE6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: pink,
                      size: 20,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Token A-${patient.token.toString().padLeft(2, '0')} • ${patient.reason}',
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF748196),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  const _StatusBadge(
                    text: 'High',
                    type: 'High',
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

// ============================================================================
// QUICK ANALYTICS
// ============================================================================

class _QuickAnalytics extends StatelessWidget {
  final QueueService service;

  const _QuickAnalytics({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Quick Analytics',
      trailing: const Icon(
        Icons.analytics_outlined,
        size: 19,
        color: blue,
      ),
      child: Row(
        children: [
          Expanded(
            child: _AnalyticsBox(
              icon: Icons.groups_rounded,
              title: 'Active Queue',
              value: '${service.queueCount}',
              color: lavender,
              background: const Color(0xFFF0EEFF),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _AnalyticsBox(
              icon: Icons.priority_high_rounded,
              title: 'Priority',
              value: '${service.priorityCount}',
              color: pink,
              background: const Color(0xFFFFEEF3),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _AnalyticsBox(
              icon: Icons.person_off_outlined,
              title: 'No Show',
              value: '${service.noShowCount}',
              color: orange,
              background: const Color(0xFFFFF4E6),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ANALYTICS BOX
// ============================================================================

class _AnalyticsBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color background;

  const _AnalyticsBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 105,
      ),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AI TIP
// ============================================================================

class _AiTip extends StatelessWidget {
  const _AiTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3DCFF),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.smart_toy_rounded,
              color: lavender,
              size: 28,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip for today',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your queue information will update automatically as patients are added and managed.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF748196),
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
// COMMON CARD
// ============================================================================

class _Card extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _Card({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCE6F2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: trailing!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String text;
  final String type;

  const _StatusBadge({
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case 'High':
        bg = const Color(0xFFFFE8EE);
        fg = pink;
        break;

      case 'Low':
        bg = const Color(0xFFEAF3FF);
        fg = blue;
        break;

      case 'Completed':
        bg = const Color(0xFFEAF8F2);
        fg = green;
        break;

      case 'In Consultation':
        bg = const Color(0xFFEAF3FF);
        fg = blue;
        break;

      case 'No Show':
        bg = const Color(0xFFFFEEF3);
        fg = pink;
        break;

      default:
        bg = const Color(0xFFF0EEFF);
        fg = lavender;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}




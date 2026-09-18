import 'package:flutter/material.dart';

enum HospitalSidebarPage {
  dashboard,
  todayQueue,
  addPatient,
}

class HospitalSidebar extends StatelessWidget {
  final HospitalSidebarPage selectedPage;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onTodayQueueTap;
  final VoidCallback? onAddPatientTap;

  const HospitalSidebar({
    super.key,
    required this.selectedPage,
    this.onDashboardTap,
    this.onTodayQueueTap,
    this.onAddPatientTap,
  });

  static const Color blue = Color(0xFF1976D2);
  static const Color navy = Color(0xFF16324F);
  static const Color pink = Color(0xFFE76A91);
  static const Color textColor = Color(0xFF536B89);

  void _showComingSoon(
      BuildContext context,
      String page,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$page screen coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E8F0),
        ),
      ),
      child: Column(
        children: [
          // ==========================================================
          // LOGO
          // ==========================================================

          const Icon(
            Icons.local_hospital_rounded,
            color: blue,
            size: 42,
          ),

          const SizedBox(height: 10),

          const Text(
            'CareFlow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navy,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // MENU
          // ==========================================================

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --------------------------------------------------
                  // DASHBOARD
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    selected:
                    selectedPage ==
                        HospitalSidebarPage.dashboard,
                    onTap: onDashboardTap,
                  ),

                  // --------------------------------------------------
                  // TODAY'S QUEUE
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.people_alt_outlined,
                    title: "Today's Queue",
                    selected:
                    selectedPage ==
                        HospitalSidebarPage.todayQueue,
                    onTap: onTodayQueueTap,
                  ),

                  // --------------------------------------------------
                  // ADD PATIENT
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Add Patient',

                    // ADD PATIENT PAGE SELECTED
                    selected: selectedPage == HospitalSidebarPage.addPatient,

                    onTap: onAddPatientTap ??
                            () {
                          _showComingSoon(
                            context,
                            'Add Patient',
                          );
                        },
                  ),

                  // --------------------------------------------------
                  // APPOINTMENTS
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Appointments',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Appointments',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // PATIENTS
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Patients',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Patients',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // PRIORITY PATIENTS
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.priority_high_rounded,
                    title: 'Priority Patients',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Priority Patients',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // REPORTS
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports & Analytics',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Reports & Analytics',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // SCHEDULE
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.schedule_rounded,
                    title: 'Schedule',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Schedule',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // MESSAGES
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Messages',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Messages',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // PROFILE
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Profile',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Profile',
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // SETTINGS
                  // --------------------------------------------------

                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Settings',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ==========================================================
          // LOGOUT
          // ==========================================================

          _SidebarItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            iconColor: pink,
            onTap: () {
              _showComingSoon(
                context,
                'Logout',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SIDEBAR ITEM
// ============================================================================

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.selected = false,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            bottom: 5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1976D2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: iconColor ??
                    (selected
                        ? Colors.white
                        : const Color(0xFF536B89)),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF536B89),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
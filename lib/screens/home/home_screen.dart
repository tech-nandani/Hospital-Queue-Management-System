import 'package:flutter/material.dart';
import '../appointment/appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xffE8F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Color(0xff1976D2),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              "HealthQueue",
              style: TextStyle(
                color: Color(0xff17345C),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            height: 42,
            width: 42,
            margin: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: const Color(0xffE8F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xff1976D2),
              ),
            ),
          ),
        ],
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 70 : 22,
                vertical: 28,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // GREETING
                  // =================================================

                  const Text(
                    "Hello! 👋",
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff172B4D),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "We wish you good health!",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =================================================
                  // SEARCH BAR
                  // =================================================

                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xffDCE6F0),
                      ),
                    ),

                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search doctors, services...",

                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),

                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xff1976D2),
                          size: 28,
                        ),

                        border: InputBorder.none,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =================================================
                  // BLUE HEALTH BANNER
                  // =================================================

                  Container(
                    width: double.infinity,
                    height: 150,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff1976D2),
                          Color(0xff42A5F5),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),

                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Row(
                      children: [

                        // -------------------------------------------------
                        // BANNER TEXT
                        // -------------------------------------------------

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              const Text(
                                "Your health,\nour priority.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Manage your hospital visits\n"
                                    "easily from one place.",

                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // -------------------------------------------------
                        // BANNER ICON
                        // -------------------------------------------------

                        Container(
                          height: 88,
                          width: 88,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(22),
                          ),

                          child: const Icon(
                            Icons.health_and_safety_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // QUICK SERVICES
                  // =================================================

                  const Text(
                    "Quick Services",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff172B4D),
                    ),
                  ),

                  const SizedBox(height: 18),

                  GridView.count(
                    crossAxisCount: isDesktop ? 4 : 2,

                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,

                    childAspectRatio:
                    isDesktop ? 1.25 : 1.05,

                    shrinkWrap: true,

                    physics:
                    const NeverScrollableScrollPhysics(),

                    children: [

                      // =================================================
                      // BOOK APPOINTMENT
                      // =================================================

                      ServiceCard(
                        title: "Book\nAppointment",

                        icon:
                        Icons.calendar_month_outlined,

                        iconColor:
                        const Color(0xff1976D2),

                        iconBackground:
                        const Color(0xffE8F3FF),

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                              const AppointmentScreen(),
                            ),
                          );
                        },
                      ),

                      // =================================================
                      // FIND DOCTORS
                      // =================================================

                      ServiceCard(
                        title: "Find\nDoctors",

                        icon:
                        Icons.medical_services_outlined,

                        iconColor:
                        const Color(0xff00A86B),

                        iconBackground:
                        const Color(0xffE5F8F1),

                        onTap: () {
                          _showComingSoon(
                            "Find Doctors",
                          );
                        },
                      ),

                      // =================================================
                      // MY APPOINTMENTS
                      // =================================================

                      ServiceCard(
                        title: "My\nAppointments",

                        icon:
                        Icons.assignment_outlined,

                        iconColor:
                        const Color(0xffffa000),

                        iconBackground:
                        const Color(0xfffff4dd),

                        onTap: () {
                          _showComingSoon(
                            "My Appointments",
                          );
                        },
                      ),

                      // =================================================
                      // MY QUEUE
                      // =================================================

                      ServiceCard(
                        title: "My\nQueue",

                        icon:
                        Icons.confirmation_number_outlined,

                        iconColor:
                        const Color(0xff8B5CF6),

                        iconBackground:
                        const Color(0xffF0E9FF),

                        onTap: () {
                          _showComingSoon(
                            "My Queue",
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // UPCOMING APPOINTMENT
                  // =================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      const Text(
                        "Upcoming Appointment",

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff172B4D),
                        ),
                      ),

                      TextButton(
                        onPressed: () {},

                        child: const Text(
                          "View All",

                          style: TextStyle(
                            color: Color(0xff1976D2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // =================================================
                  // UPCOMING APPOINTMENT CARD
                  // =================================================

                  _emptyInfoCard(
                    icon:
                    Icons.calendar_month_outlined,

                    title:
                    "No upcoming appointments",

                    subtitle:
                    "Your appointments will appear here.",
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // QUEUE STATUS
                  // =================================================

                  const Text(
                    "Queue Status",

                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff172B4D),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _emptyInfoCard(
                    icon:
                    Icons.confirmation_number_outlined,

                    title:
                    "No active queue",

                    subtitle:
                    "Your queue status will appear here.",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================

      bottomNavigationBar:
      _buildBottomNavigationBar(),
    );
  }

  // =============================================================
  // EMPTY INFO CARD
  // =============================================================

  Widget _emptyInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xffDCE6F0),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: const Color(0xffE8F3FF),

              borderRadius:
              BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: const Color(0xff1976D2),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff344563),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,

                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTTOM NAVIGATION BAR
  // =============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: Color(0xffE5E7EB),
          ),
        ),
      ),

      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex:
          selectedNavIndex,

          backgroundColor:
          Colors.white,

          elevation: 0,

          type:
          BottomNavigationBarType.fixed,

          selectedItemColor:
          const Color(0xff1976D2),

          unselectedItemColor:
          Colors.grey,

          selectedFontSize: 13,

          unselectedFontSize: 13,

          onTap: (index) {
            setState(() {
              selectedNavIndex = index;
            });

            if (index != 0) {
              _showComingSoon(
                index == 1
                    ? "Appointments"
                    : index == 2
                    ? "Queue"
                    : "Profile",
              );
            }
          },

          items: const [

            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),

              activeIcon: Icon(
                Icons.home,
              ),

              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_month_outlined,
              ),

              activeIcon: Icon(
                Icons.calendar_month,
              ),

              label: "Appointments",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.confirmation_number_outlined,
              ),

              activeIcon: Icon(
                Icons.confirmation_number,
              ),

              label: "Queue",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),

              activeIcon: Icon(
                Icons.person,
              ),

              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // COMING SOON
  // =============================================================

  void _showComingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$name page will be connected next.",
        ),

        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }
}

// =================================================================
// SERVICE CARD
// =================================================================

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  final VoidCallback? onTap;

  const ServiceCard({
    super.key,

    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius:
      BorderRadius.circular(20),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(20),

        onTap: onTap,

        child: Container(
          padding:
          const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(
              color: const Color(0xffEDF1F5),
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(0.04),

                blurRadius: 12,

                offset:
                const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Container(
                height: 50,
                width: 50,

                decoration: BoxDecoration(
                  color: iconBackground,

                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: Icon(
                  icon,

                  color: iconColor,

                  size: 27,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                title,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff263858),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
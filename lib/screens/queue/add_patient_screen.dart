import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/queue_service.dart';
import '../../widgets/hospital_sidebar.dart';
import '../doctor/doctor_dashboard_screen.dart';
import 'today_queue_screen.dart';

const Color bg = Color(0xFFF5F8FC);
const Color blue = Color(0xFF1976D2);
const Color navy = Color(0xFF16324F);
const Color pink = Color(0xFFE76A91);

class AddPatientScreen extends StatelessWidget {
  const AddPatientScreen({super.key});

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
    );
  }

  void _openTodayQueue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TodayQueueScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      // ==========================================================
      // MOBILE DRAWER
      // ==========================================================
      drawer: Drawer(
        backgroundColor: bg,
        child: SafeArea(
          child: HospitalSidebar(
            selectedPage: HospitalSidebarPage.addPatient,
            onDashboardTap: () {
              Navigator.of(context).pop();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const DoctorDashboardScreen(),
                ),
              );
            },
            onTodayQueueTap: () {
              Navigator.of(context).pop();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TodayQueueScreen()),
              );
            },
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          // IMPORTANT:
          // Browser/Web is always treated as desktop.
          // Android emulator uses width to decide.
          final bool desktop = kIsWeb || constraints.maxWidth >= 900;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // DESKTOP SIDEBAR
              // ==================================================
              if (desktop)
                HospitalSidebar(
                  selectedPage: HospitalSidebarPage.addPatient,
                  onDashboardTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const DoctorDashboardScreen(),
                      ),
                    );
                  },
                  onTodayQueueTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const TodayQueueScreen(),
                      ),
                    );
                  },
                ),

              // ==================================================
              // MAIN CONTENT
              // ==================================================
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 28 : 16,
                    vertical: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MOBILE TOP BAR
                        if (!desktop)
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.menu_rounded,
                                      color: navy,
                                    ),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Add Patient',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ],
                          ),

                        if (!desktop) const SizedBox(height: 20),

                        // ==================================================
                        // PAGE HEADER
                        // ==================================================
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: blue.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: blue,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Patient',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: navy,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Register a patient and add them to today’s queue',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF71839B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // PATIENT INFORMATION CARD
                        // ==================================================
                        _SectionCard(
                          title: 'Patient Information',
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            children: [
                              _InputField(
                                label: 'Full Name',
                                hint: 'Enter patient name',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),

                              if (desktop)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InputField(
                                        label: 'Age',
                                        hint: 'Enter age',
                                        icon: Icons.calendar_today_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _InputField(
                                        label: 'Phone Number',
                                        hint: 'Enter phone number',
                                        icon: Icons.phone_outlined,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _InputField(
                                  label: 'Age',
                                  hint: 'Enter age',
                                  icon: Icons.calendar_today_outlined,
                                ),
                                const SizedBox(height: 16),
                                _InputField(
                                  label: 'Phone Number',
                                  hint: 'Enter phone number',
                                  icon: Icons.phone_outlined,
                                ),
                              ],

                              const SizedBox(height: 16),

                              _InputField(
                                label: 'Address',
                                hint: 'Enter patient address',
                                icon: Icons.location_on_outlined,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // QUEUE INFORMATION
                        // ==================================================
                        _SectionCard(
                          title: 'Queue Information',
                          icon: Icons.people_alt_outlined,
                          child: Column(
                            children: [
                              _InputField(
                                label: 'Reason for Visit',
                                hint: 'Enter reason / symptoms',
                                icon: Icons.medical_information_outlined,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 18),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: navy,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _PriorityChip(
                                    title: 'Normal',
                                    icon: Icons.person_outline,
                                    selected: true,
                                  ),
                                  _PriorityChip(
                                    title: 'Urgent',
                                    icon: Icons.warning_amber_rounded,
                                  ),
                                  _PriorityChip(
                                    title: 'Emergency',
                                    icon: Icons.priority_high_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // ACTION BUTTON
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Add patient functionality
                              // can be connected here.
                            },
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Add Patient to Queue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: blue, size: 20),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ================================================================
// INPUT FIELD
// ================================================================

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF71839B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
    );
  }
}

// ================================================================
// PRIORITY CHIP
// ================================================================

class _PriorityChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;

  const _PriorityChip({
    required this.title,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? blue.withValues(alpha: 0.10)
            : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? blue : const Color(0xFFE1E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? blue : const Color(0xFF71839B),
          ),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? blue : const Color(0xFF536B89),
            ),
          ),
        ],
      ),
    );
  }
}

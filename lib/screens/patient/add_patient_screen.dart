import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/queue_service.dart';
import '../../widgets/hospital_sidebar.dart';
import '../queue/today_queue_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();

  String gender = 'Male';
  String priority = 'Normal';

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
    );
  }

  void _openTodayQueue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TodayQueueScreen()),
    );
  }

  // ============================================================
  // ADD PATIENT
  // ============================================================

  void _addPatient() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final patient = QueueService.instance.addPatient(
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      gender: gender,
      phone: phoneController.text.trim(),
      reason: reasonController.text.trim(),
      priority: priority,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.name} added with Token ${patient.token}'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _decoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE76A91)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE76A91), width: 1.5),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16324F),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF748196)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRIORITY INFO
  // ============================================================

  Widget _priorityInfo() {
    Color color;
    Color background;
    String title;
    String description;
    IconData icon;

    switch (priority) {
      case 'High':
        color = const Color(0xFFE76A91);
        background = const Color(0xFFFFEEF3);
        title = 'High Priority';
        description = 'Patient will receive higher queue priority.';
        icon = Icons.priority_high_rounded;
        break;

      case 'Low':
        color = const Color(0xFF1976D2);
        background = const Color(0xFFEAF3FF);
        title = 'Low Priority';
        description = 'Patient will be placed after normal-priority patients.';
        icon = Icons.keyboard_arrow_down_rounded;
        break;

      default:
        color = const Color(0xFF3A8D68);
        background = const Color(0xFFEAF8F2);
        title = 'Normal Priority';
        description =
            'Patient will be added according to the normal queue order.';
        icon = Icons.remove_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF536B89),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      // ==========================================================
      // MOBILE DRAWER
      // ==========================================================
      drawer: Drawer(
        backgroundColor: const Color(0xFFF4F8FD),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: HospitalSidebar(
              selectedPage: HospitalSidebarPage.addPatient,

              onDashboardTap: () {
                Navigator.of(context).pop();
                _openDashboard();
              },

              onTodayQueueTap: () {
                Navigator.of(context).pop();
                _openTodayQueue();
              },

              onAddPatientTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool desktop = constraints.maxWidth >= 900;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // DESKTOP SIDEBAR
                // ==================================================
                if (desktop)
                  HospitalSidebar(
                    selectedPage: HospitalSidebarPage.addPatient,

                    onDashboardTap: _openDashboard,

                    onTodayQueueTap: _openTodayQueue,

                    onAddPatientTap: () {},
                  ),

                // ==================================================
                // MAIN CONTENT
                // ==================================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 30 : 16,
                      vertical: desktop ? 20 : 14,
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // TOP BAR
                          // ==================================================
                          Row(
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFDCE6F2),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.menu_rounded,
                                          color: Color(0xFF16324F),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              if (!desktop) const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Patient',
                                      style: TextStyle(
                                        fontSize: desktop ? 25 : 21,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF16324F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Add a patient to today’s queue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF748196),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
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
                                  Icons.person_add_alt_1_rounded,
                                  color: Color(0xFF1976D2),
                                  size: 21,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ==================================================
                          // INTRO CARD
                          // ==================================================
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(desktop ? 22 : 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFDCE6F2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: desktop ? 62 : 54,
                                  width: desktop ? 62 : 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF3FF),
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  child: const Icon(
                                    Icons.medical_information_outlined,
                                    color: Color(0xFF1976D2),
                                    size: 29,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'New Patient Registration',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16324F),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        desktop
                                            ? 'Enter the patient details below to add them to today’s hospital queue.'
                                            : 'Enter patient details to add them to today’s queue.',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF536B89),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // PATIENT INFORMATION
                          // ==================================================
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(desktop ? 24 : 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFDCE6F2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionHeader(
                                  Icons.person_outline_rounded,
                                  'Patient Information',
                                  'Provide basic information about the patient.',
                                ),

                                const SizedBox(height: 22),

                                // NAME
                                TextFormField(
                                  controller: nameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: _decoration(
                                    'Patient Name',
                                    'Enter patient full name',
                                    Icons.person_outline_rounded,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter patient name';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // AGE + GENDER
                                if (desktop)
                                  Row(
                                    children: [
                                      Expanded(child: _ageField()),
                                      const SizedBox(width: 16),
                                      Expanded(child: _genderField()),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _ageField(),
                                      const SizedBox(height: 16),
                                      _genderField(),
                                    ],
                                  ),

                                const SizedBox(height: 16),

                                // PHONE
                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: _decoration(
                                    'Contact Number',
                                    'Enter 10-digit contact number',
                                    Icons.phone_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length != 10) {
                                      return 'Enter a valid 10-digit contact number';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // REASON
                                TextFormField(
                                  controller: reasonController,
                                  maxLines: 4,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: _decoration(
                                    'Reason / Symptoms',
                                    'Describe reason for visit or symptoms',
                                    Icons.medical_information_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter reason';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // QUEUE INFORMATION
                          // ==================================================
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(desktop ? 24 : 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFDCE6F2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionHeader(
                                  Icons.people_alt_outlined,
                                  'Queue Information',
                                  'Set the priority for today’s queue.',
                                ),

                                const SizedBox(height: 22),

                                _priorityField(),

                                const SizedBox(height: 14),

                                _priorityInfo(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // ADD BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _addPatient,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text(
                                'Add Patient to Queue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Center(
                            child: Text(
                              'PATIENT INFORMATION • QUEUE MANAGEMENT',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9AA5B4),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
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

  // ============================================================
  // AGE FIELD
  // ============================================================

  Widget _ageField() {
    return TextFormField(
      controller: ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: _decoration('Age', 'Enter age', Icons.cake_outlined),
      validator: (value) {
        final age = int.tryParse(value ?? '');

        if (age == null || age <= 0 || age > 120) {
          return 'Enter a valid age';
        }

        return null;
      },
    );
  }

  // ============================================================
  // GENDER FIELD
  // ============================================================

  Widget _genderField() {
    return DropdownButtonFormField<String>(
      initialValue: gender,
      decoration: _decoration(
        'Gender',
        'Select gender',
        Icons.people_outline_rounded,
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            gender = value;
          });
        }
      },
    );
  }

  // ============================================================
  // PRIORITY FIELD
  // ============================================================

  Widget _priorityField() {
    return DropdownButtonFormField<String>(
      initialValue: priority,
      decoration: _decoration(
        'Priority',
        'Select priority',
        Icons.priority_high_rounded,
      ),
      items: const [
        DropdownMenuItem(value: 'Normal', child: Text('Normal')),
        DropdownMenuItem(value: 'High', child: Text('High Priority')),
        DropdownMenuItem(value: 'Low', child: Text('Low Priority')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            priority = value;
          });
        }
      },
    );
  }
}

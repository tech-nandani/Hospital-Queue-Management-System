import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int currentStep = 0;

  String? selectedDepartment;
  String? selectedDoctor;
  DateTime? selectedDate;
  String? selectedTime;

  // ===========================================================
  // 15 HOSPITAL DEPARTMENTS
  // ===========================================================

  final List<String> departments = [
    "Cardiology",
    "Neurology",
    "Orthopedics",
    "General Medicine",
    "Pediatrics",
    "Dermatology",
    "Gynecology",
    "Ophthalmology",
    "ENT",
    "Dentistry",
    "Pulmonology",
    "Gastroenterology",
    "Psychiatry",
    "Oncology",
    "Emergency Medicine",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: const Color(0xff1976D2),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Book Appointment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 800;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ),

                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: 24,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // =================================================
                      // STEP INDICATOR
                      // =================================================

                      _buildStepIndicator(),

                      const SizedBox(height: 30),

                      // =================================================
                      // STEP CONTENT
                      // =================================================

                      if (currentStep == 0)
                        _buildDepartmentStep(),

                      if (currentStep == 1)
                        _buildDoctorStep(),

                      if (currentStep == 2)
                        _buildDateTimeStep(),

                      if (currentStep == 3)
                        _buildConfirmationStep(),

                      const SizedBox(height: 30),

                      // =================================================
                      // NAVIGATION BUTTONS
                      // =================================================

                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================
  // STEP INDICATOR
  // ===========================================================

  Widget _buildStepIndicator() {
    final steps = [
      "Department",
      "Doctor",
      "Date & Time",
      "Confirm",
    ];

    return Row(
      children: List.generate(
        steps.length,
            (index) {
          final bool active = index <= currentStep;

          return Expanded(
            child: Row(
              children: [

                // CIRCLE

                Container(
                  height: 38,
                  width: 38,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: active
                        ? const Color(0xff1976D2)
                        : const Color(0xffE1E7EF),
                  ),

                  child: Center(
                    child: Text(
                      "${index + 1}",

                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : const Color(0xff7B8794),

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // STEP TITLE

                Expanded(
                  child: Text(
                    steps[index],

                    style: TextStyle(
                      fontSize: 12,

                      color: active
                          ? const Color(0xff17345C)
                          : Colors.grey,

                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),

                // LINE

                if (index != steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,

                      color: index < currentStep
                          ? const Color(0xff1976D2)
                          : const Color(0xffDDE4EC),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===========================================================
  // STEP 1 — DEPARTMENT
  // ===========================================================

  Widget _buildDepartmentStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        const Text(
          "Select Department",

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff172B4D),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Choose the department you want to visit.",

          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================
        // ALL 15 DEPARTMENTS
        // =====================================================

        ...departments.map(
              (department) {
            final bool selected =
                selectedDepartment == department;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDepartment = department;
                });
              },

              child: Container(
                margin:
                const EdgeInsets.only(bottom: 12),

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(16),

                  border: Border.all(
                    color: selected
                        ? const Color(0xff1976D2)
                        : const Color(0xffDDE6F0),

                    width: selected ? 2 : 1,
                  ),
                ),

                child: Row(
                  children: [

                    // ICON

                    Container(
                      height: 45,
                      width: 45,

                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xffE5F1FF)
                            : const Color(0xffF1F5F9),

                        borderRadius:
                        BorderRadius.circular(13),
                      ),

                      child: Icon(
                        Icons.medical_services_outlined,

                        color: selected
                            ? const Color(0xff1976D2)
                            : const Color(0xff64748B),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // DEPARTMENT NAME

                    Expanded(
                      child: Text(
                        department,

                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Color(0xff263858),
                        ),
                      ),
                    ),

                    // SELECT ICON

                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.chevron_right,

                      color: selected
                          ? const Color(0xff1976D2)
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================
  // STEP 2 — DOCTOR
  // ===========================================================

  Widget _buildDoctorStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        const Text(
          "Select Doctor",

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff172B4D),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Department: ${selectedDepartment ?? "Not selected"}",

          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        _doctorOption(
          "Available Doctor",
          Icons.person_outline,
        ),

        _doctorOption(
          "Choose Doctor",
          Icons.medical_information_outlined,
        ),
      ],
    );
  }

  // ===========================================================
  // DOCTOR OPTION
  // ===========================================================

  Widget _doctorOption(
      String title,
      IconData icon,
      ) {
    final bool selected =
        selectedDoctor == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDoctor = title;
        });
      },

      child: Container(
        margin:
        const EdgeInsets.only(bottom: 14),

        padding:
        const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? const Color(0xff1976D2)
                : const Color(0xffDDE6F0),

            width: selected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [

            Container(
              height: 58,
              width: 58,

              decoration: BoxDecoration(
                color:
                const Color(0xffE8F2FF),

                borderRadius:
                BorderRadius.circular(16),
              ),

              child: Icon(
                icon,

                color:
                const Color(0xff1976D2),

                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xff263858),
                ),
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,

              color: selected
                  ? const Color(0xff1976D2)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // STEP 3 — DATE & TIME
  // ===========================================================

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        const Text(
          "Select Date & Time",

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff172B4D),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Choose a convenient date and time.",

          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 22),

        // =====================================================
        // DATE
        // =====================================================

        GestureDetector(
          onTap: _selectDate,

          child: Container(
            width: double.infinity,

            padding:
            const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
              BorderRadius.circular(16),

              border: Border.all(
                color:
                const Color(0xffDDE6F0),
              ),
            ),

            child: Row(
              children: [

                Container(
                  height: 50,
                  width: 50,

                  decoration: BoxDecoration(
                    color:
                    const Color(0xffE8F2FF),

                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.calendar_month_outlined,

                    color:
                    Color(0xff1976D2),
                  ),
                ),

                const SizedBox(width: 14),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Appointment Date",

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xff263858),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "Available Time",

          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff172B4D),
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,

          children: [
            "09:00 AM",
            "10:00 AM",
            "11:00 AM",
            "12:00 PM",
            "02:00 PM",
            "03:00 PM",
            "04:00 PM",
          ].map(
                (time) {
              final bool selected =
                  selectedTime == time;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTime = time;
                  });
                },

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xff1976D2)
                        : Colors.white,

                    borderRadius:
                    BorderRadius.circular(12),

                    border: Border.all(
                      color: selected
                          ? const Color(0xff1976D2)
                          : const Color(0xffDDE6F0),
                    ),
                  ),

                  child: Text(
                    time,

                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xff344563),

                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  // ===========================================================
  // DATE PICKER
  // ===========================================================

  Future<void> _selectDate() async {
    final DateTime? picked =
    await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate:
      DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ===========================================================
  // STEP 4 — CONFIRMATION
  // ===========================================================

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        const Text(
          "Confirm Appointment",

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff172B4D),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Review your appointment details before confirming.",

          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,

          padding:
          const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(
              color:
              const Color(0xffDDE6F0),
            ),
          ),

          child: Column(
            children: [

              _summaryRow(
                "Department",
                selectedDepartment ??
                    "Not selected",
                Icons.local_hospital_outlined,
              ),

              const Divider(height: 25),

              _summaryRow(
                "Doctor",
                selectedDoctor ??
                    "Not selected",
                Icons.person_outline,
              ),

              const Divider(height: 25),

              _summaryRow(
                "Date",
                selectedDate == null
                    ? "Not selected"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                Icons.calendar_month_outlined,
              ),

              const Divider(height: 25),

              _summaryRow(
                "Time",
                selectedTime ??
                    "Not selected",
                Icons.access_time_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // SUMMARY ROW
  // ===========================================================

  Widget _summaryRow(
      String title,
      String value,
      IconData icon,
      ) {
    return Row(
      children: [

        Container(
          height: 42,
          width: 42,

          decoration: BoxDecoration(
            color:
            const Color(0xffE8F2FF),

            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Icon(
            icon,

            color:
            const Color(0xff1976D2),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xff263858),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // NEXT / BACK BUTTONS
  // ===========================================================

  Widget _buildNavigationButtons() {
    return Row(
      children: [

        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },

              style:
              OutlinedButton.styleFrom(
                minimumSize:
                const Size(
                  double.infinity,
                  52,
                ),

                side: const BorderSide(
                  color:
                  Color(0xff1976D2),
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),

              child: const Text(
                "Back",

                style: TextStyle(
                  color:
                  Color(0xff1976D2),
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

        if (currentStep > 0)
          const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: _nextStep,

            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xff1976D2),

              foregroundColor:
              Colors.white,

              minimumSize:
              const Size(
                double.infinity,
                52,
              ),

              elevation: 0,

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),

            child: Text(
              currentStep == 3
                  ? "Confirm Appointment"
                  : "Continue",

              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // NEXT STEP LOGIC
  // ===========================================================

  void _nextStep() {
    if (currentStep == 0 &&
        selectedDepartment == null) {
      _showMessage(
        "Please select a department.",
      );
      return;
    }

    if (currentStep == 1 &&
        selectedDoctor == null) {
      _showMessage(
        "Please select a doctor.",
      );
      return;
    }

    if (currentStep == 2 &&
        (selectedDate == null ||
            selectedTime == null)) {
      _showMessage(
        "Please select date and time.",
      );
      return;
    }

    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    } else {
      _showMessage(
        "Appointment functionality will be connected with Django later.",
      );
    }
  }

  // ===========================================================
  // MESSAGE
  // ===========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }
}
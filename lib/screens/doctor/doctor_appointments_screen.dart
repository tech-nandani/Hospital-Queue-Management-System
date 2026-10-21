import 'package:flutter/material.dart';

import 'doctor_dashboard_screen.dart';

/// Doctor's scheduled Appointments Screen.
/// Renders the complete CareFlow Doctor Workspace with "Appointments" active,
/// connected directly to the real-time Django backend and SQLite database.
class DoctorAppointmentsScreen extends StatelessWidget {
  final int? doctorId;
  final String? doctorName;
  final String? department;

  const DoctorAppointmentsScreen({
    super.key,
    this.doctorId,
    this.doctorName,
    this.department,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorDashboardScreen(
      initialIndex: 2,
      doctorId: doctorId,
      doctorName: doctorName,
      department: department,
    );
  }
}

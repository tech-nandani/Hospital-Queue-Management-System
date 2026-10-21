import 'package:flutter/material.dart';

import '../doctor/doctor_dashboard_screen.dart';

/// Doctor's real-time Today's Queue Screen.
/// Renders the complete CareFlow Doctor Workspace with "Today's Queue" active,
/// connected directly to the real-time Django backend and SQLite database.
class TodayQueueScreen extends StatelessWidget {
  final int? doctorId;
  final String? doctorName;
  final String? department;

  const TodayQueueScreen({
    super.key,
    this.doctorId,
    this.doctorName,
    this.department,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorDashboardScreen(
      initialIndex: 1,
      doctorId: doctorId,
      doctorName: doctorName,
      department: department,
    );
  }
}

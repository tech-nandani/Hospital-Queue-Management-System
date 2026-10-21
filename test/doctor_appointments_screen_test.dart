import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/models/staff_application.dart';
import 'package:hospital_queue_management/screens/doctor/doctor_appointments_content.dart';
import 'package:hospital_queue_management/screens/doctor/doctor_appointments_screen.dart';
import 'package:hospital_queue_management/services/patient_api_service.dart';
import 'package:hospital_queue_management/services/verification_service.dart';

void main() {
  setUp(() {
    PatientApiService.instance.mockStaffAppointmentsForTesting = [];
    VerificationService.instance.setCurrentStaff(StaffApplication(
      id: '1',
      name: 'Dr. Priya Sharma',
      email: 'priya.sharma@hospital.org',
      mobile: '9876543210',
      password: 'DoctorPass123!',
      role: 'Doctor',
      department: 'Cardiology',
      medicalLicenseNumber: 'MCI-102938',
      degreeCertificate: 'degree.pdf',
      identityProof: 'id.pdf',
      registrationCertificate: 'reg.pdf',
      status: StaffApplicationStatus.approved,
    ));
  });

  tearDown(() {
    PatientApiService.instance.mockStaffAppointmentsForTesting = null;
  });

  testWidgets("DoctorAppointmentsScreen renders full workspace layout matching reference image",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: DoctorAppointmentsScreen(
          doctorId: 1,
          doctorName: 'Dr. Priya Sharma',
          department: 'Cardiology',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Sidebar & Header
    expect(find.text('Appointments'), findsWidgets);
    expect(find.text('DOCTOR WORKSPACE'), findsOneWidget);
    expect(find.text('View and manage your scheduled appointments'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);

    // 2. 4 Summary Cards
    expect(find.text('Total Appointments'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Cancelled / No Show'), findsOneWidget);
    expect(find.text('For selected period'), findsOneWidget);
    expect(find.text('Scheduled appointments'), findsOneWidget);
    expect(find.text('Consultations completed'), findsOneWidget);
    expect(find.text('Cancelled or missed'), findsOneWidget);

    // 3. Date Range Tabs
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('Custom Date'), findsOneWidget);

    // 4. Search and Filters Bar
    expect(find.text('Search patient name, appointment ID or token...'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('All Priorities'), findsOneWidget);
    expect(find.text('All Departments'), findsOneWidget);
    expect(find.text('Refresh'), findsWidgets);

    // 5. Mini Calendar Card
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsWidgets);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);

    // 6. Quick Actions Card
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Start Consultation'), findsOneWidget);
    expect(find.text('Begin patient consultation'), findsOneWidget);
    expect(find.text('View Patient History'), findsOneWidget);
    expect(find.text('Access medical records'), findsOneWidget);
    expect(find.text('Write Prescription'), findsOneWidget);
    expect(find.text('Create & manage prescriptions'), findsOneWidget);
    expect(find.text('Manage Schedule'), findsOneWidget);
    expect(find.text('View and manage your schedule'), findsOneWidget);

    // 7. Empty State (when 0 appointments exist for Dr. Priya Sharma)
    expect(find.text('No appointments scheduled'), findsOneWidget);
    expect(find.text('Appointments for the selected date will appear here.'), findsOneWidget);

    // 8. Bottom Tips Banner
    expect(find.text('Appointment Management Tips'), findsOneWidget);
    expect(find.textContaining('View your scheduled appointments'), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);

    // 9. Floating AI Assistant
    expect(find.text('AI Assistant'), findsWidgets);
  });

  testWidgets("DoctorAppointmentsContent date tab switching and search interaction",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    int navigatedTab = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DoctorAppointmentsContent(
            doctorId: 1,
            doctorName: 'Dr. Priya Sharma',
            department: 'Cardiology',
            onNavigateToTab: (idx) => navigatedTab = idx,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab is Today
    expect(find.text('Today'), findsWidgets);

    // Click Tomorrow tab
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    // Click This Week tab
    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();

    // Click This Month tab
    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();

    // Enter search text
    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'Saarah');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Click Quick Action "Write Prescription" -> should navigate to tab 6
    await tester.tap(find.text('Write Prescription'));
    await tester.pumpAndSettle();
    expect(navigatedTab, 6);

    // Click Quick Action "Manage Schedule" -> should navigate to tab 7
    await tester.tap(find.text('Manage Schedule'));
    await tester.pumpAndSettle();
    expect(navigatedTab, 7);

    // Click Quick Action "View Patient History" -> should navigate to tab 3
    await tester.tap(find.text('View Patient History'));
    await tester.pumpAndSettle();
    expect(navigatedTab, 3);
  });

  testWidgets("DoctorAppointmentsContent renders populated table, badges, and opens details modal",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    PatientApiService.instance.mockStaffAppointmentsForTesting = [
      {
        'id': 101,
        'queue_token': 1,
        'patient_name': 'Saarah Shaikh',
        'patient_age': 28,
        'patient_gender': 'Female',
        'patient_mobile': '9876543210',
        'patient_email': 'saarah@example.com',
        'appointment_date': '2026-09-25',
        'appointment_time': '10:30:00',
        'department': 'Cardiology',
        'doctor_name': 'Dr. Priya Sharma',
        'priority': 'Normal',
        'status': 'upcoming',
        'reason': 'Routine heart checkup',
      },
      {
        'id': 102,
        'queue_token': 2,
        'patient_name': 'Aarav Patel',
        'patient_age': 45,
        'patient_gender': 'Male',
        'patient_mobile': '9812345678',
        'patient_email': 'aarav@example.com',
        'appointment_date': '2026-09-25',
        'appointment_time': '11:15:00',
        'department': 'Cardiology',
        'doctor_name': 'Dr. Priya Sharma',
        'priority': 'Urgent',
        'status': 'waiting',
        'reason': 'Chest pain symptoms',
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DoctorAppointmentsContent(
            doctorId: 1,
            doctorName: 'Dr. Priya Sharma',
            department: 'Cardiology',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Summary Cards counts
    expect(find.text('2'), findsWidgets); // Total Appointments: 2, Upcoming: 2

    // Verify Rows rendered in table
    expect(find.text('Saarah Shaikh'), findsOneWidget);
    expect(find.text('Aarav Patel'), findsOneWidget);
    expect(find.text('28 / F'), findsOneWidget);
    expect(find.text('45 / M'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('11:15 AM'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Upcoming'), findsWidgets);
    expect(find.text('Waiting'), findsOneWidget);

    // Verify Action buttons (View and Consult for eligible waiting patient)
    expect(find.text('View'), findsWidgets);
    expect(find.text('Consult'), findsWidgets);

    // Tap View on the first appointment
    await tester.ensureVisible(find.text('View').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View').first);
    await tester.pumpAndSettle();

    // Verify Modal opened with appointment details
    expect(find.text('Appointment ID: 101 • Cardiology'), findsOneWidget);
    expect(find.text('Routine heart checkup'), findsOneWidget);
    expect(find.text('Start Consultation'), findsWidgets);
    expect(find.text('Patient History'), findsOneWidget);

    // Tap Patient History inside modal
    await tester.tap(find.text('Patient History'));
    await tester.pumpAndSettle();

    // Verify Patient History modal opened
    expect(find.text('Medical History: Saarah Shaikh'), findsOneWidget);
    expect(find.text('Patient Visits & Consultation Records'), findsOneWidget);
    expect(find.text('Open Clinical Directory'), findsOneWidget);
  });
}

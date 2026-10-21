import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/models/queue_patient.dart';
import 'package:hospital_queue_management/models/staff_application.dart';
import 'package:hospital_queue_management/screens/queue/today_queue_screen.dart';
import 'package:hospital_queue_management/services/queue_service.dart';
import 'package:hospital_queue_management/services/verification_service.dart';

void main() {
  setUp(() {
    QueueService.instance.clearForTesting();
  });

  testWidgets("TodayQueueScreen renders empty state matching reference image when no patients",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

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

    await tester.pumpWidget(
      const MaterialApp(
        home: TodayQueueScreen(
          doctorId: 1,
          doctorName: 'Dr. Priya Sharma',
          department: 'Cardiology',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Page Header & Breadcrumb
    expect(find.text("Today's Queue"), findsWidgets);
    expect(find.text("Manage and monitor today's patient queue in real-time"), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);

    // 2. 4 Summary Cards
    expect(find.text('Total Patients Today'), findsOneWidget);
    expect(find.text('Currently Waiting'), findsOneWidget);
    expect(find.text('Average Waiting Time'), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);

    // Dynamic 0 values when no patients
    expect(find.text('0 min'), findsOneWidget);

    // 3. Tabs
    expect(find.text('Queue List'), findsOneWidget);
    expect(find.text('Called Patients'), findsOneWidget);

    // 4. Prominent Button
    expect(find.text('Call Next Patient'), findsOneWidget);

    // 5. Filters
    expect(find.text('Today'), findsWidgets);
    expect(find.text('All Priorities'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('Refresh'), findsWidgets);

    // 6. Empty State
    expect(find.text("No patients in today's queue"), findsOneWidget);
    expect(find.text("When patients are registered or checked in, they will appear here."), findsOneWidget);
    expect(find.text('Showing 0 of 0 patients'), findsOneWidget);

    // 7. Queue Management Tips Card
    expect(find.text('Queue Management Tips'), findsOneWidget);
    expect(find.textContaining('Click "Call Next Patient"'), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);

    // 8. AI Assistant
    expect(find.text('AI Assistant'), findsWidgets);
  });

  testWidgets("TodayQueueScreen shows real patients, priorities, and handles Call Next Patient",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final p1 = QueuePatient(
      id: '1',
      token: 1,
      name: 'Saarah Shaikh',
      age: 20,
      gender: 'Female',
      phone: '7400163975',
      reason: 'Routine checkup',
      priority: 'Normal',
      time: '04:00 PM',
      department: 'Cardiology',
      doctorId: 1,
      status: 'Waiting',
    );

    final p2 = QueuePatient(
      id: '2',
      token: 2,
      name: 'Devisri Chirraboina',
      age: 19,
      gender: 'Female',
      phone: '8369725879',
      reason: 'Acute symptoms',
      priority: 'Emergency',
      time: '04:30 PM',
      department: 'Cardiology',
      doctorId: 1,
      status: 'Waiting',
    );

    QueueService.instance.setPatientsForTesting([p1, p2]);

    await tester.pumpWidget(
      const MaterialApp(
        home: TodayQueueScreen(
          doctorId: 1,
          doctorName: 'Dr. Priya Sharma',
          department: 'Cardiology',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify patients in table
    expect(find.text('Saarah Shaikh'), findsOneWidget);
    expect(find.text('Devisri Chirraboina'), findsOneWidget);
    expect(find.text('P-001'), findsOneWidget);
    expect(find.text('P-002'), findsOneWidget);
    expect(find.text('Emergency'), findsWidgets);
    expect(find.text('Normal'), findsWidgets);

    // Verify summary statistics
    expect(find.text('2'), findsWidgets); // Total Patients Today and Currently Waiting
    expect(find.text('24 min'), findsOneWidget); // 2 * 12 min

    // Click "Call Next Patient" - should call Emergency patient (Devisri, Token #2) first!
    await tester.tap(find.text('Call Next Patient'));
    await tester.pumpAndSettle();

    // Verify Devisri is now "Calling"
    expect(p2.status, 'Calling');

    // Switch to Called Patients tab
    await tester.tap(find.text('Called Patients'));
    await tester.pumpAndSettle();

    // Devisri should be in Called Patients!
    expect(find.text('Devisri Chirraboina'), findsOneWidget);
  });
}

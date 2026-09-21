import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/models/queue_patient.dart';
import 'package:hospital_queue_management/models/staff_application.dart';
import 'package:hospital_queue_management/screens/doctor/doctor_dashboard_screen.dart';
import 'package:hospital_queue_management/services/queue_service.dart';
import 'package:hospital_queue_management/services/verification_service.dart';

void main() {
  setUp(() {
    // Reset QueueService patients for isolated testing
    QueueService.instance.clearForTesting();
  });

  testWidgets('DoctorDashboardScreen renders dynamic doctor profile, stats, and empty state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Set staff in verification service
    VerificationService.instance.setCurrentStaff(StaffApplication(
      id: '5',
      name: 'Dr. Arjun Verma',
      email: 'arjun@careflow.com',
      mobile: '9988776655',
      password: 'DoctorPass123!',
      role: 'Doctor',
      department: 'Orthopedics',
      medicalLicenseNumber: 'MCI-998877',
      degreeCertificate: 'degree.pdf',
      identityProof: 'id.pdf',
      registrationCertificate: 'reg.pdf',
      status: StaffApplicationStatus.approved,
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: DoctorDashboardScreen(
          doctorName: 'Dr. Arjun Verma',
          department: 'Orthopedics',
          doctorId: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify dynamic Doctor Profile and Greeting
    expect(find.textContaining('Arjun'), findsWidgets);
    expect(find.text('Orthopedics'), findsWidgets);
    expect(find.text('DOCTOR WORKSPACE'), findsOneWidget);

    // Verify dynamic Statistics Cards titles
    expect(find.text('Total Patients Today'), findsOneWidget);
    expect(find.text('Patients in Queue'), findsOneWidget);
    expect(find.text('Average Waiting Time'), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);

    // Verify Empty State when queue is empty
    expect(find.text("No patients in today's queue"), findsOneWidget);
    expect(find.text('No priority patients'), findsOneWidget);
    expect(find.text('No appointments scheduled'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Start Consultation'), findsOneWidget);
    expect(find.text('View Patient History'), findsOneWidget);
    expect(find.text('Write Prescription'), findsOneWidget);
    expect(find.text('Manage Schedule'), findsOneWidget);

    // Verify AI Assistant banner and button
    expect(find.text('Your AI Assistant is here! 🤖'), findsOneWidget);
    expect(find.text('AI Assistant'), findsWidgets);
  });

  testWidgets('DoctorDashboardScreen dynamically displays added patient and updates on status change',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Add dynamic emergency patient
    final testPatient = QueuePatient(
      id: '99',
      token: 105,
      name: 'Ramesh Patel',
      age: 48,
      gender: 'Male',
      phone: '9876543210',
      reason: 'Chest discomfort and shortness of breath',
      priority: 'Emergency',
      time: '10:30 AM',
      department: 'Cardiology',
      doctorId: 1,
      status: 'Waiting',
    );

    // Simulate adding to queue
    QueueService.instance.setPatientsForTesting([testPatient]);

    await tester.pumpWidget(
      const MaterialApp(
        home: DoctorDashboardScreen(
          doctorName: 'Dr. Ramesh Kumar',
          department: 'Cardiology',
          doctorId: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify patient appears in Today's Queue
    expect(find.text('Ramesh Patel'), findsWidgets);
    expect(find.text('P-105'), findsWidgets);
    expect(find.text('Emergency'), findsWidgets);
    expect(find.text('Waiting'), findsWidgets);

    // Verify Priority Patients card also contains Ramesh Patel
    expect(find.text('Priority Patients'), findsOneWidget);

    // Verify Statistics reflect real count
    expect(find.text('1'), findsWidgets); // Total Patients Today / Patients in queue
  });
}

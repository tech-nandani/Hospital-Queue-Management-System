import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/screens/doctor/doctor_register_screen.dart';
import 'package:hospital_queue_management/screens/login/login_screen.dart';
import 'package:hospital_queue_management/screens/login/patient_login_screen.dart';
import 'package:hospital_queue_management/screens/patient/patient_register_screen.dart';
import 'package:hospital_queue_management/services/patient_service.dart';
import 'package:hospital_queue_management/services/verification_service.dart';
import 'package:hospital_queue_management/widgets/hospital_workflow_visual.dart';
import 'package:hospital_queue_management/widgets/split_registration_layout.dart';

void main() {
  group('PatientRegisterScreen Tests', () {
    testWidgets('PatientRegisterScreen desktop split-screen renders properly with required asterisks',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRegisterScreen(),
        ),
      );

      // Verify Split Layout and Visual
      expect(find.byType(SplitRegistrationLayout), findsOneWidget);
      expect(find.byType(HospitalWorkflowVisual), findsOneWidget);
      expect(find.byType(AutofillGroup), findsWidgets);
      expect(find.text('PATIENT ONBOARDING & REGISTRATION'), findsOneWidget);
      expect(find.text('PATIENT → APPOINTMENT → TOKEN QUEUE → CARE'), findsOneWidget);

      // Verify Form Header & Branding
      expect(find.text('CareFlow'), findsWidgets);
      expect(find.text('PATIENT PORTAL'), findsOneWidget);
      expect(find.text('Create Patient Account'), findsNWidgets(2)); // heading & button
      expect(
        find.text(
            'Create your patient account to manage appointments and visits.'),
        findsOneWidget,
      );

      // Verify Mandatory Fields have RED *
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);
      expect(find.text('Mobile Number *'), findsOneWidget);
      expect(find.text('Password *'), findsOneWidget);
      expect(find.text('Confirm Password *'), findsOneWidget);

      // Verify Optional Fields DO NOT have *
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Gender *'), findsNothing);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Date of Birth *'), findsNothing);

      // Verify Trust indicator & Login link
      expect(
        find.text('Protected patient registration • 256-Bit Encrypted'),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('PatientRegisterScreen mobile layout renders without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRegisterScreen(),
        ),
      );

      expect(find.text('Create Patient Account'), findsWidgets);
      expect(find.byType(HospitalWorkflowVisual), findsOneWidget);
      expect(find.text('Patient Registration & Appointments'), findsOneWidget);
    });

    testWidgets('PatientRegisterScreen password visibility toggle works',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRegisterScreen(),
        ),
      );

      // Password visibility toggles
      final visibilityIcons = find.byIcon(Icons.visibility_outlined);
      expect(visibilityIcons, findsNWidgets(2)); // password and confirm password

      await tester.tap(visibilityIcons.first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('DoctorRegisterScreen Tests', () {
    testWidgets('DoctorRegisterScreen desktop split-screen renders properly with required asterisks',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorRegisterScreen(),
        ),
      );

      // Verify Split Layout and Visual
      expect(find.byType(SplitRegistrationLayout), findsOneWidget);
      expect(find.byType(HospitalWorkflowVisual), findsOneWidget);
      expect(find.byType(AutofillGroup), findsWidgets);
      expect(find.text('PROFESSIONAL STAFF REGISTRATION'), findsOneWidget);
      expect(find.text('DOCTOR / RECEPTIONIST → QUEUE OPS → ADMIN APPROVAL'),
          findsOneWidget);

      // Verify Form Header & Branding
      expect(find.text('CareFlow'), findsWidgets);
      expect(find.text('STAFF PORTAL'), findsOneWidget);
      expect(find.text('Create Staff Account'), findsNWidgets(2)); // heading & button
      expect(
        find.text(
            'Create your professional account to manage hospital operations.'),
        findsOneWidget,
      );

      // Verify Role Selector cards
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Receptionist'), findsOneWidget);

      // Verify Mandatory Form Fields have RED * for Doctor
      expect(find.text('Department *'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Professional Email *'), findsOneWidget);
      expect(find.text('Mobile Number *'), findsOneWidget);
      expect(find.text('Medical License Number *'), findsOneWidget);
      expect(find.text('Degree Certificate Reference *'), findsOneWidget);
      expect(find.text('Government Identity Proof Reference *'), findsOneWidget);
      expect(find.text('Professional Registration Certificate *'), findsOneWidget);
      expect(find.text('Password *'), findsOneWidget);
      expect(find.text('Confirm Password *'), findsOneWidget);

      // Verify Trust indicator & Login link
      expect(
        find.text('Subject to Administrator Verification & Approval'),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('DoctorRegisterScreen role selector toggles to Receptionist with required asterisks',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorRegisterScreen(),
        ),
      );

      // Initial: Doctor role fields
      expect(find.text('Medical License Number *'), findsOneWidget);

      // Switch to Receptionist
      await tester.tap(find.text('Receptionist'));
      await tester.pump();

      // Should now show Receptionist specific mandatory labels with RED *
      expect(find.text('Staff / Employee ID Number *'), findsOneWidget);
      expect(find.text('Qualification Certificate Reference *'), findsOneWidget);
      expect(find.text('Employment / Registration Certificate *'), findsOneWidget);
    });

    testWidgets('DoctorRegisterScreen mobile layout renders without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorRegisterScreen(),
        ),
      );

      expect(find.text('Create Staff Account'), findsWidgets);
      expect(find.byType(HospitalWorkflowVisual), findsOneWidget);
      expect(find.text('Staff Onboarding & Hospital Operations'), findsOneWidget);
    });
  });

  group('Autofill and Remember Login Tests', () {
    testWidgets('PatientLoginScreen pre-fills remembered email',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      PatientService.instance.rememberedEmail = 'patient.test@careflow.com';

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientLoginScreen(),
        ),
      );

      expect(find.text('patient.test@careflow.com'), findsOneWidget);
      expect(find.byType(AutofillGroup), findsWidgets);
    });

    testWidgets('LoginScreen pre-fills remembered staff email',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      VerificationService.instance.rememberedEmail = 'doctor.smith@careflow.com';

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('doctor.smith@careflow.com'), findsOneWidget);
      expect(find.byType(AutofillGroup), findsWidgets);
    });
  });
}

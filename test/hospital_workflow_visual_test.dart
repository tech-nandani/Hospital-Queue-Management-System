import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/screens/role/role_selection_screen.dart';
import 'package:hospital_queue_management/widgets/hospital_workflow_visual.dart';
import 'package:hospital_queue_management/widgets/split_auth_layout.dart';

void main() {
  testWidgets('HospitalWorkflowVisual renders successfully with all components',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: HospitalWorkflowVisual(
              activeToken: 'A-104',
              doctorName: 'Dr. Sarah Jenkins',
              department: 'Cardiology & OPD',
              estimatedWaitMinutes: 4,
            ),
          ),
        ),
      ),
    );

    // Verify key UI text elements from the visual
    expect(find.text('CareFlow'), findsOneWidget);
    expect(find.text('SMART RECEPTION & PATIENT FLOW'), findsOneWidget);
    expect(find.text('QUEUE BOARD'), findsOneWidget);
    expect(find.text('NOW SERVING'), findsOneWidget);
    expect(find.text('A-104'), findsOneWidget);
    expect(find.text('TOKEN ISSUED'), findsOneWidget);
    expect(find.text('APPOINTMENT'), findsOneWidget);
    expect(find.text('72 BPM'), findsOneWidget);
    expect(find.text('SMART CLINICAL TELEMETRY'), findsOneWidget);

    // Advance animation frame
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('SplitAuthLayout renders wide layout with left visual and right form',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SplitAuthLayout(
          activeToken: 'A-104',
          child: Text('Login Form Content'),
        ),
      ),
    );

    expect(find.text('Login Form Content'), findsOneWidget);
    expect(find.text('CareFlow'), findsOneWidget);
    expect(find.text('QUEUE BOARD'), findsOneWidget);
  });

  testWidgets('RoleSelectionScreen displays Doctor / Receptionist and workflow ribbon',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: RoleSelectionScreen(),
      ),
    );

    // Verify Doctor / Receptionist card and description
    expect(find.text('Doctor / Receptionist'), findsOneWidget);
    expect(find.text('Manage patients, appointments and hospital queues'), findsOneWidget);
    expect(find.text('Doctor / Nurse'), findsNothing);

    // Verify Patient and Admin role cards
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    // Verify Left visual workflow ribbon
    expect(find.text('PATIENT → RECEPTIONIST → QUEUE → DOCTOR'), findsOneWidget);
    expect(find.text('Receptionist Verified • Queue Assigned'), findsOneWidget);
  });
}

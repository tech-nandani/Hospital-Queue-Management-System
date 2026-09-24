import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/screens/admin/admin_dashboard_screen.dart';

void main() {
  testWidgets('AdminDashboardScreen flashcards redirect to respective tabs and filters',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial Overview tab
    expect(find.text('Good morning, Admin'), findsOneWidget);
    expect(find.text('Waiting'), findsWidgets);
    expect(find.text('In consultation'), findsWidgets);
    expect(find.text('Emergency'), findsWidgets);
    expect(find.text('Staff review'), findsWidgets);

    // 1. Tap on "Waiting" flashcard
    await tester.tap(find.text('Waiting').first);
    await tester.pumpAndSettle();

    // Verify redirection to Patients tab with Waiting filter
    expect(find.text('Patient management'), findsOneWidget);
    expect(find.text('Waiting (0)'), findsOneWidget);

    // Return to Overview by tapping Overview in the sidebar
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Admin'), findsOneWidget);

    // 2. Tap on "In consultation" flashcard
    await tester.tap(find.text('In consultation').first);
    await tester.pumpAndSettle();
    expect(find.text('Patient management'), findsOneWidget);
    expect(find.text('In consultation (0)'), findsOneWidget);

    // Return to Overview
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();

    // 3. Tap on "Emergency" flashcard
    await tester.tap(find.text('Emergency').first);
    await tester.pumpAndSettle();
    expect(find.text('Patient management'), findsOneWidget);
    expect(find.text('Emergency (0)'), findsOneWidget);

    // Return to Overview
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();

    // 4. Tap on "Staff review" flashcard
    await tester.tap(find.text('Staff review').first);
    await tester.pumpAndSettle();

    // Verify redirection to Staff tab
    expect(find.text('Doctor & nurse management'), findsOneWidget);
    expect(find.text('Open verification review'), findsOneWidget);
  });
}

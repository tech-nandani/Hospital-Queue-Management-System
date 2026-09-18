import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/screens/admin/admin_dashboard_screen.dart';
import 'package:hospital_queue_management/screens/admin/admin_login_screen.dart';
import 'package:hospital_queue_management/widgets/admin_command_visual.dart';

class _TestObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    pushedRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  testWidgets('AdminLoginScreen desktop split-screen renders properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );

    // Form items
    expect(find.text('CareFlow'), findsOneWidget);
    expect(find.text('ADMIN PORTAL'), findsOneWidget);
    expect(find.text('Welcome back, Admin'), findsOneWidget);
    expect(find.text('Sign in to securely manage hospital operations.'), findsOneWidget);
    expect(find.text('Admin email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Secure Sign In'), findsOneWidget);
    expect(find.text('Protected administrator access • 256-Bit Secure'), findsOneWidget);

    // Right-side visual items
    expect(find.byType(AdminCommandVisual), findsOneWidget);
    expect(find.text('HOSPITAL CONTROL CENTER'), findsOneWidget);
    expect(find.text('STAFF VERIFICATION'), findsOneWidget);
    expect(find.text('QUEUE DISPATCH'), findsOneWidget);
    expect(find.text('ROLE-BASED GUARD'), findsOneWidget);

    // Advance animation frame
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('AdminLoginScreen mobile layout renders without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );

    expect(find.text('Welcome back, Admin'), findsOneWidget);
    expect(find.text('Secure Sign In'), findsOneWidget);
    expect(find.byType(AdminCommandVisual), findsOneWidget);
  });

  testWidgets('Password visibility toggle toggles obscureText',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );

    // Find password field
    final passwordFinder = find.widgetWithText(TextField, '');
    expect(passwordFinder, findsNWidgets(2)); // email and password fields

    // Toggle password visibility
    final toggleFinder = find.byIcon(Icons.visibility_outlined);
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('Invalid admin login shows error SnackBar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );

    // Enter wrong email and password
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'wrong@hospital.com');
    await tester.enterText(textFields.last, 'wrongpass');

    // Tap Secure Sign In
    await tester.tap(find.text('Secure Sign In'));
    await tester.pump();

    expect(find.text('Invalid admin credentials.'), findsOneWidget);
  });


  testWidgets('Valid admin login navigates to AdminDashboardScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final observer = _TestObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const AdminLoginScreen(),
      ),
    );

    // Enter valid admin credentials
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'admin@hospital.com');
    await tester.enterText(textFields.last, 'admin123');

    // Tap Secure Sign In
    await tester.tap(find.text('Secure Sign In'));
    await tester.pump();

    // Verify replacement route was triggered to AdminDashboardScreen
    expect(observer.pushedRoute, isNotNull);
    final route = observer.pushedRoute as MaterialPageRoute;
    final widget = route.builder(tester.element(find.byType(AdminLoginScreen)));
    expect(widget, isA<AdminDashboardScreen>());
  });
}


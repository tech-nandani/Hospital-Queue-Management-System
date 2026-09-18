import 'package:flutter/material.dart';
import 'hospital_workflow_visual.dart';

/// A responsive split-screen layout designed for authentication, registration,
/// and landing screens.
///
/// On wide displays (width >= 900px, desktop/tablet/web):
/// - LEFT SIDE: Hospital Visual / Workflow Animation
/// - RIGHT SIDE: Interactive form/content
///
/// On mobile/compact displays (width < 900px):
/// - Displays the child content smoothly with an optional top visual banner.
class SplitAuthLayout extends StatelessWidget {
  final Widget child;
  final String activeToken;
  final String doctorName;
  final String department;
  final int estimatedWaitMinutes;
  final bool showMobileHero;

  const SplitAuthLayout({
    super.key,
    required this.child,
    this.activeToken = 'A-104',
    this.doctorName = 'Dr. Sarah Jenkins',
    this.department = 'Cardiology & OPD',
    this.estimatedWaitMinutes = 4,
    this.showMobileHero = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 900;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F8FD),
            body: Row(
              children: [
                // ==========================================
                // LEFT SIDE — HOSPITAL VISUAL / ANIMATION
                // ==========================================
                Expanded(
                  flex: 6,
                  child: HospitalWorkflowVisual(
                    showHeader: true,
                    activeToken: activeToken,
                    doctorName: doctorName,
                    department: department,
                    estimatedWaitMinutes: estimatedWaitMinutes,
                  ),
                ),

                // ==========================================
                // RIGHT SIDE — FORM / INTERACTION
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    color: const Color(0xFFF8FAFD),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / Compact Layout
        if (showMobileHero) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F8FD),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 260,
                      child: HospitalWorkflowVisual(
                        showHeader: false,
                        isCompact: true,
                        activeToken: activeToken,
                        doctorName: doctorName,
                        department: department,
                        estimatedWaitMinutes: estimatedWaitMinutes,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}

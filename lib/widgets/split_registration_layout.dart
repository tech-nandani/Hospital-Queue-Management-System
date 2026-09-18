import 'package:flutter/material.dart';

/// A modern, responsive split-screen registration layout designed for healthcare SaaS portals.
///
/// On large screens (desktop/tablet wide, width >= 900px):
/// - LEFT: Approx 45% width role-specific healthcare animation/visual.
/// - RIGHT: Approx 55% width comfortably centered registration form.
///
/// On mobile/compact screens (width < 900px):
/// - Vertically stacked with a compact top hero banner and smooth keyboard-safe scrolling.
class SplitRegistrationLayout extends StatelessWidget {
  final Widget child;
  final Widget leftVisual;
  final Widget? mobileVisual;
  final double maxFormWidth;

  const SplitRegistrationLayout({
    super.key,
    required this.child,
    required this.leftVisual,
    this.mobileVisual,
    this.maxFormWidth = 540,
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
                // LEFT SIDE — HEALTHCARE ANIMATION (45%)
                // ==========================================
                Expanded(
                  flex: 9,
                  child: leftVisual,
                ),

                // ==========================================
                // RIGHT SIDE — REGISTRATION FORM (55%)
                // ==========================================
                Expanded(
                  flex: 11,
                  child: Container(
                    height: double.infinity,
                    color: const Color(0xFFF8FAFD),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 36,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxFormWidth),
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
        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?mobileVisual,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxFormWidth),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

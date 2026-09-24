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
    this.maxFormWidth = 500,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 900;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: const Color(0xFF071A2D),
            body: Row(
              children: [
                // ==========================================
                // LEFT SIDE — REGISTRATION FORM
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF071A2D),
                      border: Border(
                        right: BorderSide(
                          color: Color(0xFF162D4A),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 28,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxFormWidth),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // RIGHT SIDE — ANIMATION VISUAL
                // ==========================================
                Expanded(
                  flex: 6,
                  child: leftVisual,
                ),
              ],
            ),
          );
        }

        // Mobile / Compact Layout
        return Scaffold(
          backgroundColor: const Color(0xFF071A2D),
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxFormWidth),
                        child: child,
                      ),
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

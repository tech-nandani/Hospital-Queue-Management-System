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
            body: Stack(
              children: [
                Positioned.fill(child: leftVisual),
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF071A2D).withValues(alpha: 0.42),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxFormWidth),
                        child: child,
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
                  if (mobileVisual != null) mobileVisual!,
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

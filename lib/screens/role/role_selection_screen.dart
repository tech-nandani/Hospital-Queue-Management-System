import 'package:flutter/material.dart';
import '../admin/admin_login_screen.dart';
import '../login/patient_login_screen.dart';
import '../login/login_screen.dart';
import '../visual_preview/hospital_visual_preview_screen.dart';
import '../../widgets/hospital_workflow_visual.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 900;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F9FC),
            body: Row(
              children: [
                // ==========================================
                // LEFT SIDE — HOSPITAL VISUAL / ANIMATION
                // ==========================================
                const Expanded(
                  flex: 6,
                  child: HospitalWorkflowVisual(
                    showHeader: true,
                    activeToken: 'A-104',
                  ),
                ),

                // ==========================================
                // RIGHT SIDE — ROLE SELECTION
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    color: const Color(0xFFF6F9FC),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: _buildRoleContent(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6F9FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: _buildRoleContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F0FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF1976D2),
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CareFlow',
                    style: TextStyle(
                      color: Color(0xFF16324F),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Preview Hospital Visual',
              icon: const Icon(Icons.animation_rounded, color: Color(0xFF1976D2)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HospitalVisualPreviewScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 38),
              const Text(
                'Good to see you.',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose how you want\nto continue',
                style: TextStyle(
                  color: Color(0xFF16324F),
                  fontSize: 32,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your personalized hospital experience starts here.',
                style: TextStyle(color: Color(0xFF718096), fontSize: 14),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF16324F),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFF8ED7C2),
                      size: 25,
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        'Secure access for every member of your care team.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SELECT YOUR ROLE',
                style: TextStyle(
                  color: Color(0xFF7B899A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Patient',
                subtitle: 'Book appointments, track live queue & medical records',
                iconColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEFF6FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientLoginScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.medical_services_rounded,
                title: 'Doctor',
                subtitle: 'Treat patients, consultations, clinical notes & prescriptions',
                iconColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEFF6FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(
                      initialEmail: 'priya.sharma@hospital.org',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.support_agent_rounded,
                title: 'Receptionist',
                subtitle: 'Patient registration, token generation, triage & doctor availability',
                iconColor: const Color(0xFF7C5CFC),
                backgroundColor: const Color(0xFFF3F0FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(
                      initialEmail: 'receptionist@hospital.org',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Admin',
                subtitle: 'Review and approve professional accounts',
                iconColor: const Color(0xFF16806A),
                backgroundColor: const Color(0xFFE8F8F3),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                ),
              ),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  'SMART CARE  •  BETTER EXPERIENCE',
                  style: TextStyle(
                    color: Color(0xFF9AA8B7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          );
  }
}

// ============================================================
// ROLE CARD WIDGET
// ============================================================

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: const Color(0xFFE1E8F0), width: 1.2),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            children: [
              // Icon box
              Container(
                height: 56,
                width: 56,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(icon, size: 34, color: iconColor),
              ),

              const SizedBox(width: 18),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16324F),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF748196),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

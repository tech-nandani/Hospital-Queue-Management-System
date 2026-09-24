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
    return Scaffold(
      backgroundColor: const Color(0xFF071A2D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          if (isWide) {
            return Row(
              children: [
                // ==========================================
                // LEFT SIDE — HOSPITAL WORKFLOW ANIMATION
                // ==========================================
                const Expanded(
                  flex: 6,
                  child: HospitalWorkflowVisual(
                    showHeader: true,
                    activeToken: 'A-104',
                  ),
                ),

                // ==========================================
                // RIGHT SIDE — ROLE SELECTION CONTENT
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF071A2D),
                      border: Border(
                        left: BorderSide(
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
                            vertical: 24,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: _buildRoleContent(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Compact / Mobile Layout: Top Hero Animation + Scrollable Role Content
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 240,
                    child: HospitalWorkflowVisual(
                      showHeader: false,
                      isCompact: true,
                      activeToken: 'A-104',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildRoleContent(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFB8D2FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Color(0xFF0F2740),
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CareFlow',
                  style: TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Preview Hospital Visual',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HospitalVisualPreviewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.animation_rounded, color: Color(0xFF0F2740)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Good to see you.',
            style: TextStyle(
              color: Color(0xFF3D7BFF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose how you want\nto continue',
            style: TextStyle(
              color: Color(0xFF071A2D),
              fontSize: 32,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your personalized hospital experience starts here.',
            style: TextStyle(color: Color(0xFF5C738F), fontSize: 14),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2740),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF9ED9C5),
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
          const SizedBox(height: 20),
          const Text(
            'SELECT YOUR ROLE',
            style: TextStyle(
              color: Color(0xFF6D8195),
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
            iconColor: const Color(0xFF0F2740),
            backgroundColor: const Color(0xFFEAF3FF),
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
            iconColor: const Color(0xFF0F2740),
            backgroundColor: const Color(0xFFEAF3FF),
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
            iconColor: const Color(0xFF0F2740),
            backgroundColor: const Color(0xFFF3F4FF),
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
            iconColor: const Color(0xFF0F2740),
            backgroundColor: const Color(0xFFE8FBF5),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
          ),
          const SizedBox(height: 22),
          const Center(
            child: Text(
              'SMART CARE  •  BETTER EXPERIENCE',
              style: TextStyle(
                color: Color(0xFF7F8EA3),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2740),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF5C738F),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: Color(0xFF0F2740),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

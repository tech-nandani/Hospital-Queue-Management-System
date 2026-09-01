import 'package:flutter/material.dart';
import '../login/patient_login_screen.dart';
import '../login/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              // =========================
              // TOP SPACE
              // =========================

              const SizedBox(height: 45),

              // =========================
              // TITLE
              // =========================

              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Hospital Queue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16324F),
                ),
              ),

              const Text(
                'Management System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7A90),
                ),
              ),

              const SizedBox(height: 45),

              // =========================
              // QUESTION
              // =========================

              const Text(
                'How would you like to continue?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16324F),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Please select your role',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8798),
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // PATIENT CARD
              // =========================

              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Patient',
                subtitle: 'Book appointments and manage your queue',
                iconColor: const Color(0xFF1976D2),
                backgroundColor: const Color(0xFFEAF3FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientLoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // =========================
              // DOCTOR / NURSE CARD
              // =========================

              _RoleCard(
                icon: Icons.medical_services_rounded,
                title: 'Doctor / Nurse',
                subtitle: 'Manage patients and hospital queues',
                iconColor: const Color(0xFF6C63B5),
                backgroundColor: const Color(0xFFF0EEFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // =========================
              // BOTTOM TEXT
              // =========================

              const Text(
                'SMART CARE • BETTER EXPERIENCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(22),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: const Color(0xFFE1E8F0),
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            children: [

              // Icon box
              Container(
                height: 65,
                width: 65,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(
                  icon,
                  size: 34,
                  color: iconColor,
                ),
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

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF9AA8BA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
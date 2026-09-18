import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/admin_auth_service.dart';
import '../../widgets/admin_command_visual.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final valid = AdminAuthService.instance.authenticate(
      emailController.text,
      passwordController.text,
    );

    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin credentials.')),
      );
      return;
    }

    TextInput.finishAutofillContext();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
  }

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
                // LEFT SIDE — ADMIN LOGIN FORM (50%)
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    color: const Color(0xFFF8FAFD),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 40,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: _buildAdminForm(context),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // RIGHT SIDE — ADMIN COMMAND VISUAL (50%)
                // ==========================================
                const Expanded(
                  flex: 5,
                  child: AdminCommandVisual(),
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
                children: [
                  // Compact top visual
                  const AdminCommandVisual(isCompact: true, height: 210),

                  // Form content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _buildAdminForm(context),
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

  Widget _buildAdminForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==========================================
        // CAREFLOW BRANDING & ADMIN BADGE
        // ==========================================
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F5F0),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF16806A),
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CareFlow',
                  style: TextStyle(
                    color: Color(0xFF16324F),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ADMIN PORTAL',
                    style: TextStyle(
                      color: Color(0xFF16806A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // ==========================================
        // HEADING & SUPPORTING TEXT
        // ==========================================
        const Text(
          'Welcome back, Admin',
          style: TextStyle(
            color: Color(0xFF16324F),
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to securely manage hospital operations.',
          style: TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 28),

        // ==========================================
        // LOGIN CARD CONTAINER
        // ==========================================
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2EAF3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Email Label
                const Text(
                  'Admin email',
                  style: TextStyle(
                    color: Color(0xFF34495E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Admin Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: _input(
                    'Enter admin email',
                    Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // Password Label
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF34495E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                  decoration: _input(
                    'Enter password',
                    Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => obscurePassword = !obscurePassword,
                      ),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF718096),
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Secure Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _signIn,
                    icon: const Icon(Icons.lock_outline_rounded, size: 19),
                    label: const Text(
                      'Secure Sign In',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16806A),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ==========================================
        // SECURITY TRUST INDICATOR
        // ==========================================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.shield_outlined,
              color: Color(0xFF16806A),
              size: 16,
            ),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'Protected administrator access • 256-Bit Secure',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF16806A), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF16806A), width: 1.5),
      ),
    );
  }
}

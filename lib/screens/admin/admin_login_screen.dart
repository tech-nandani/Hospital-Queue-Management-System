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
    return Scaffold(
      backgroundColor: const Color(0xFF071A2D),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AdminCommandVisual(),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFF071A2D).withValues(alpha: 0.52),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildAdminForm(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F2740)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFB8D2FF), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFF0F2740),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'CareFlow',
                    style: TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'ADMIN PORTAL',
                    style: TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Center(
                  child: Text(
                    'Welcome back, Admin',
                    style: TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Sign in to securely manage hospital operations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5C738F),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Admin email',
                  style: TextStyle(
                    color: Color(0xFF1E3352),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _input(
                    'Enter admin email',
                    Icons.email_outlined,
                  ).copyWith(
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A8CA3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF1E3352),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _input(
                    'Enter password',
                    Icons.lock_outline_rounded,
                  ).copyWith(
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A8CA3),
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => obscurePassword = !obscurePassword,
                      ),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF5C738F),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                      backgroundColor: const Color(0xFF0F2740),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.shield_outlined,
              color: Color(0xFF0F2740),
              size: 16,
            ),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'Protected administrator access • 256-Bit Secure',
                style: TextStyle(
                  color: Color(0xFF5C738F),
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
      prefixIcon: Icon(icon, color: const Color(0xFF0F2740), size: 20),
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
        borderSide: const BorderSide(color: Color(0xFF3D7BFF), width: 1.5),
      ),
    );
  }
}

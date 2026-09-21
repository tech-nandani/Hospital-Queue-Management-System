import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../doctor/doctor_register_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';
import '../receptionist/receptionist_dashboard_screen.dart';
import '../../models/staff_application.dart';
import '../../services/verification_service.dart';
import '../../widgets/hospital_workflow_visual.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  const LoginScreen({super.key, this.initialEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final prefill =
        widget.initialEmail ?? VerificationService.instance.rememberedEmail;
    if (prefill != null && prefill.isNotEmpty) {
      emailController.text = prefill;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                // RIGHT SIDE — LOGIN FORM
                // ==========================================
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    color: const Color(0xFFF4F8FD),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 32,
                        ),
                        child: _buildLoginForm(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          body: SafeArea(
            child: Stack(
              children: [
                // Top right background decoration
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F2FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Top left background decoration
                Positioned(
                  top: 70,
                  left: -70,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF3FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: _buildLoginForm(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
                      // =========================
                      // LOGO
                      // =========================
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1976D2,
                              ).withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: Color(0xFF1976D2),
                              size: 30,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =========================
                      // APP NAME
                      // =========================
                      const Text(
                        'CareFlow',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF243B55),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 34),

                      // =========================
                      // LOGIN CARD
                      // =========================
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
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
                              const Center(
                                child: Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF243B55),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Center(
                                child: Text(
                                  'Sign in to continue managing your hospital visits.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // =========================
                              // EMAIL / MOBILE
                              // =========================
                              const Text(
                                'Email or Mobile Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3D4B5C),
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
                                decoration: InputDecoration(
                                  hintText: 'Enter your email or mobile number',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF1976D2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFD),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1976D2),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // =========================
                              // PASSWORD
                              // =========================
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3D4B5C),
                                ),
                              ),

                              const SizedBox(height: 8),

                              TextField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF1976D2),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF718096),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFD),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1976D2),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                            // =========================
                            // FORGOT PASSWORD
                            // =========================
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Forgot password later
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // =========================
                            // LOGIN BUTTON
                            // =========================
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // =========================
                            // OR
                            // =========================
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2EAF3)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2EAF3)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // =========================
                            // CREATE ACCOUNT
                            // =========================
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 14,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () async {
                                    final registeredEmail =
                                        await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const DoctorRegisterScreen(),
                                      ),
                                    );
                                    if (registeredEmail != null &&
                                        registeredEmail.isNotEmpty) {
                                      emailController.text = registeredEmail;
                                    }
                                  },
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Quick test login chips
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Demo Login:',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            emailController.text = 'priya.sharma@hospital.org';
                                            passwordController.text = 'DoctorPass123!';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFCBD5E1)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.medical_services_rounded, size: 14, color: Color(0xFF2563EB)),
                                                SizedBox(width: 6),
                                                Text('Doctor', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            emailController.text = 'receptionist@hospital.org';
                                            passwordController.text = 'ReceptionPass123!';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFCBD5E1)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFF7C5CFC)),
                                                SizedBox(width: 6),
                                                Text('Receptionist', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =========================
                    // FOOTER
                    // =========================
                    const Text(
                      'YOUR HEALTH • OUR PRIORITY',
                      style: TextStyle(
                        color: Color(0xFF9AA5B4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
  }

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    final application = await VerificationService.instance.authenticateAsync(
      email,
      password,
    );

    if (application == null) {
      _showMessage('Invalid credentials or account not found.');
      return;
    }

    if (application.status == StaffApplicationStatus.pending) {
      _showMessage('Your account is still waiting for admin approval.');
      return;
    }

    if (application.status == StaffApplicationStatus.rejected) {
      _showMessage('Your professional verification was rejected.');
      return;
    }

    TextInput.finishAutofillContext();

    Widget dashboard;
    if (application.role.toLowerCase() == 'receptionist' || application.role.toLowerCase() == 'nurse') {
      dashboard = ReceptionistDashboardScreen(
        receptionistName: application.name,
      );
    } else {
      dashboard = DoctorDashboardScreen(
        doctorName: application.name,
        department: application.department,
        doctorId: int.tryParse(application.id) ?? 1,
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

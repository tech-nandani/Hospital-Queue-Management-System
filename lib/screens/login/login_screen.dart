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
    return Scaffold(
      backgroundColor: const Color(0xFF071A2D),
      body: Stack(
        children: [
          const Positioned.fill(
            child: HospitalWorkflowVisual(
              showHeader: true,
              activeToken: 'A-104',
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFF071A2D).withValues(alpha: 0.52),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildLoginForm(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
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
          width: 540,
          padding: const EdgeInsets.all(26),
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
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: Color(0xFF0F2740),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'CareFlow',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2740),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F2740),
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
                      color: Color(0xFF5C738F),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Email or Mobile Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3352),
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
                  decoration: InputDecoration(
                    hintText: 'Enter your email or mobile number',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A8CA3),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF0F2740),
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
                      borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3D7BFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3352),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A8CA3),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF0F2740),
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
                        color: const Color(0xFF5C738F),
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
                      borderSide: const BorderSide(color: Color(0xFFE2EAF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3D7BFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF3D7BFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2740),
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
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2EAF3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2EAF3))),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF5C738F),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final registeredEmail = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorRegisterScreen(),
                          ),
                        );
                        if (registeredEmail != null && registeredEmail.isNotEmpty) {
                          emailController.text = registeredEmail;
                        }
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF3D7BFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A5F7A),
                        ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.medical_services_rounded,
                                      size: 14,
                                      color: Color(0xFF0F2740),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Doctor',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.support_agent_rounded,
                                      size: 14,
                                      color: Color(0xFF0F2740),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Receptionist',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
        const SizedBox(height: 20),
        const Text(
          'YOUR HEALTH • OUR PRIORITY',
          style: TextStyle(
            color: Color(0xFFB7C9DA),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    if (application.role.toLowerCase() == 'receptionist' ||
        application.role.toLowerCase() == 'nurse') {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

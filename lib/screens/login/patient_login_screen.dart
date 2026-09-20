import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../patient/patient_register_screen.dart';
import '../patient/patient_dashboard_screen.dart';
import '../../services/patient_service.dart';
import '../../widgets/hospital_workflow_visual.dart';
import '../../widgets/google_account_picker_dialog.dart';
import '../../widgets/google_logo_icon.dart';

class PatientLoginScreen extends StatefulWidget {
  final String? initialEmail;
  const PatientLoginScreen({super.key, this.initialEmail});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    final prefill =
        widget.initialEmail ?? PatientService.instance.rememberedEmail;
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
                // RIGHT SIDE — PATIENT LOGIN FORM
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
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: _buildPatientLoginForm(context),
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
          backgroundColor: const Color(0xFFF4F8FD),
          body: SafeArea(
            child: Stack(
              children: [
                // =========================
                // BACKGROUND DECORATION
                // =========================
                Positioned(
                  top: -70,
                  right: -60,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F2FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  top: 80,
                  left: -80,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF3FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // =========================
                // MAIN CONTENT
                // =========================
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _buildPatientLoginForm(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // =========================
        // LOGO
        // =========================
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF1976D2),
                size: 27,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // =========================
        // APP TITLE
        // =========================
        const Text(
          'CareFlow',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF16324F),
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 38),

        // =========================
        // LOGIN CARD
        // =========================
        Container(
          width: 540,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDCE6F2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AutofillGroup(
            child: Column(
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16324F),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to continue managing your hospital visits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7A8C),
                  ),
                ),

                const SizedBox(height: 26),

                // =========================
                // EMAIL / MOBILE
                // =========================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email or Mobile Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34495E),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

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
                    hintStyle: const TextStyle(
                      color: Color(0xFF8A96A3),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF1976D2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8E1EC),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8E1EC),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1976D2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================
                // PASSWORD
                // =========================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34495E),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8A96A3),
                    ),
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
                        color: const Color(0xFF6B7A8C),
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8E1EC),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8E1EC),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF2F6FAF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // =========================
                // LOGIN BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =========================
                // OR DIVIDER
                // =========================
                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFFDCE4EE)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A96A3),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFDCE4EE)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================
                // GOOGLE / GMAIL LOGIN BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D3748),
                      side: const BorderSide(
                        color: Color(0xFFD8E1EC),
                        width: 1.2,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1976D2),
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GoogleLogoIcon(size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // CREATE ACCOUNT
                // =========================
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF6B7A8C)),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final registeredEmail =
                            await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PatientRegisterScreen(),
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
                          color: Color(0xFF2F6FAF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'YOUR HEALTH • OUR PRIORITY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Color(0xFF8A96A3),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    try {
      await PatientService.instance.loginWithBackend(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      var raw = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ClientException: ', '');
      if (raw.toLowerCase().contains('failed to fetch') ||
          raw.toLowerCase().contains('clientfailed') ||
          raw.toLowerCase().contains('connection refused')) {
        raw =
            'Unable to connect to backend server. Please make sure the Django server is running on http://127.0.0.1:8000';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(raw)),
      );
      return;
    }

    if (!mounted) return;
    PatientService.instance.rememberedEmail = emailController.text.trim();
    TextInput.finishAutofillContext();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
    );
  }

  bool _isGoogleDialogShowing = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleDialogShowing || _isGoogleLoading) return;
    _isGoogleDialogShowing = true;

    try {
      final defaultEmail = emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : (PatientService.instance.rememberedEmail ?? 'ashoknandanik@gmail.com');

      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => GoogleAccountPickerDialog(
          suggestedEmail: defaultEmail,
        ),
      );

      if (result == null || !mounted) return;

      final email = result['email']?.trim() ?? '';
      final name = result['name']?.trim();
      if (email.isEmpty) return;

      setState(() => _isGoogleLoading = true);

      try {
        final account = await PatientService.instance.loginWithGoogle(
          email: email,
          name: name,
        );
        if (!mounted) return;

        emailController.text = account.email;
        TextInput.finishAutofillContext();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in successfully as ${account.name}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
        );
      } catch (error) {
        if (!mounted) return;
        var raw = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ClientException: ', '');
        if (raw.toLowerCase().contains('failed to fetch') ||
            raw.toLowerCase().contains('clientfailed') ||
            raw.toLowerCase().contains('connection refused')) {
          raw =
              'Unable to connect to backend server. Please make sure the Django server is running on http://127.0.0.1:8000';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(raw)),
        );
      } finally {
        if (mounted) {
          setState(() => _isGoogleLoading = false);
        }
      }
    } finally {
      _isGoogleDialogShowing = false;
    }
  }
}

import 'package:flutter/material.dart';
import '../doctor/doctor_register_screen.dart';
import '../role/role_selection_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      body: PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleSelectionScreen(),
              ),
            );
          }
        },

        child: SafeArea(
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ),
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
                                color: const Color(0xFF1976D2)
                                    .withOpacity(0.10),
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
                          'Hospital Queue',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF243B55),
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Management System',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1976D2),
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
                            border: Border.all(
                              color: const Color(0xFFE2EAF3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
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
                                keyboardType:
                                TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText:
                                  'Enter your email or mobile number',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF1976D2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFD),
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
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
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF1976D2),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible =
                                        !isPasswordVisible;
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
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
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
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DoctorDashboardScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
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
                                    child: Divider(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
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
                                    child: Divider(
                                      color: Color(0xFFE2EAF3),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // =========================
                              // CREATE ACCOUNT
                              // =========================

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 14,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const DoctorRegisterScreen(),
                                        ),
                                      );
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
                            ],
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
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
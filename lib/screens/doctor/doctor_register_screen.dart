import 'package:flutter/material.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  String selectedRole = 'Doctor';
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
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
                            color: Colors.black.withOpacity(0.06),
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
                      'Hospital Queue',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16324F),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Management System',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F6FAF),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =========================
                    // REGISTER CARD
                    // =========================

                    Container(
                      width: 540,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFDCE6F2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Create Professional Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16324F),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Register your account to manage patients and hospital queues.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7A8C),
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // =========================
                          // ROLE
                          // =========================

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Professional Role',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF34495E),
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: _inputDecoration(
                              hint: 'Select your role',
                              icon: Icons.medical_services_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Doctor',
                                child: Text('Doctor'),
                              ),
                              DropdownMenuItem(
                                value: 'Nurse',
                                child: Text('Nurse'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedRole = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // FULL NAME
                          // =========================

                          _fieldLabel('Full Name'),

                          const SizedBox(height: 9),

                          TextField(
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            decoration: _inputDecoration(
                              hint: 'Enter your full name',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // EMAIL
                          // =========================

                          _fieldLabel('Email Address'),

                          const SizedBox(height: 9),

                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'Enter your professional email',
                              icon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // MOBILE
                          // =========================

                          _fieldLabel('Mobile Number'),

                          const SizedBox(height: 9),

                          TextField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              hint: 'Enter your mobile number',
                              icon: Icons.phone_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // PASSWORD
                          // =========================

                          _fieldLabel('Password'),

                          const SizedBox(height: 9),

                          TextField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: _inputDecoration(
                              hint: 'Create a password',
                              icon: Icons.lock_outline_rounded,
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
                                  color: const Color(0xFF6B7A8C),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // CONFIRM PASSWORD
                          // =========================

                          _fieldLabel('Confirm Password'),

                          const SizedBox(height: 9),

                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !isConfirmPasswordVisible,
                            decoration: _inputDecoration(
                              hint: 'Confirm your password',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7A8C),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // =========================
                          // CREATE ACCOUNT
                          // =========================

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                // Registration functionality later
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // =========================
                          // LOGIN
                          // =========================

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF6B7A8C),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Login',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // FIELD LABEL
  // =========================

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF34495E),
        ),
      ),
    );
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8A96A3),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF1976D2),
      ),
      suffixIcon: suffixIcon,
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
    );
  }
}
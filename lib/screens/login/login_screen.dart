import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 30),

              // =========================
              // BRANDING
              // =========================
              Row(
                children: [

                  Container(
                    height: 48,
                    width: 48,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: Color(0xFF1976D2),
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Hospital Queue",
                        style: TextStyle(
                          color: Color(0xFF16324F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Management System",
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 55),

              // =========================
              // TITLE
              // =========================
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign in to continue managing your\nhospital visits.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // EMAIL
              // =========================
              const Text(
                "Email or Mobile Number",
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                keyboardType: TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText: "Enter your email or mobile number",

                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF1976D2),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 15,
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
                      color: Color(0xFFE2E8F0),
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
                "Password",
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                obscureText: obscurePassword,

                decoration: InputDecoration(
                  hintText: "Enter your password",

                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF1976D2),
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons
                          .visibility_off_outlined,

                      color: Colors.grey,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 15,
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
                      color: Color(0xFFE2E8F0),
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
                  onPressed: () {},

                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
                    // Temporary navigation.
                    // Real authentication will be added later.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HomeScreen(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1976D2),

                    foregroundColor: Colors.white,

                    elevation: 2,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // DIVIDER
              // =========================
              Row(
                children: [

                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD9E1EA),
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),

                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD9E1EA),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // REGISTER
              // =========================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RegisterScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =========================
              // FOOTER
              // =========================
              const Center(
                child: Text(
                  "Your health • Our priority",
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
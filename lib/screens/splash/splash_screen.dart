import 'dart:async';

import 'package:flutter/material.dart';
import '../role/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // TOP SECTION + LOGO
            // =========================
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Top right decoration
                  Positioned(
                    top: -80,
                    right: -70,
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0EFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Left decoration
                  Positioned(
                    top: 70,
                    left: -100,
                    child: Container(
                      height: 170,
                      width: 170,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF3FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // =========================
                  // LOGO
                  // =========================

                  // Pehle Center tha,
                  // ab thoda neeche kiya hai
                  Align(
                    alignment: const Alignment(0, 0.75),
                    child: Container(
                      height: 190,
                      width: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 125,
                            width: 125,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2FF),
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),

                          const Icon(
                            Icons.local_hospital_rounded,
                            size: 75,
                            color: Color(0xFF1976D2),
                          ),

                          Positioned(
                            bottom: 38,
                            right: 35,
                            child: Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // APP INFORMATION
            // =========================
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Text(
                    'Hospital Queue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF16324F),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 45,
                    ),
                    child: Text(
                      'Simplifying hospital visits with\n'
                          'smart and organized queue management.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // BOTTOM TEXT
            // =========================
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text(
                'YOUR HEALTH • OUR PRIORITY',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
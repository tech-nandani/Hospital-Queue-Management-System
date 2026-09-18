import 'package:flutter/material.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? selectedGender;
  DateTime? selectedDate;

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

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

              const SizedBox(height: 20),

              // =========================
              // BACK BUTTON
              // =========================
              Container(
                height: 44,
                width: 44,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // TITLE
              // =========================
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Create your account to manage your\n"
                    "hospital visits easily.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // FULL NAME
              // =========================
              const FieldLabel(
                text: "Full Name",
              ),

              const SizedBox(height: 8),

              const CustomRegisterField(
                hint: "Enter your full name",
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 18),

              // =========================
              // EMAIL
              // =========================
              const FieldLabel(
                text: "Email Address",
              ),

              const SizedBox(height: 8),

              const CustomRegisterField(
                hint: "Enter your email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // =========================
              // MOBILE
              // =========================
              const FieldLabel(
                text: "Mobile Number",
              ),

              const SizedBox(height: 8),

              const CustomRegisterField(
                hint: "Enter your mobile number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              // =========================
              // GENDER + DOB
              // =========================
              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const FieldLabel(
                          text: "Gender",
                        ),

                        const SizedBox(height: 8),

                        Container(
                          height: 56,

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(14),
                            border: Border.all(
                              color:
                              const Color(0xFFE2E8F0),
                            ),
                          ),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedGender,

                              isExpanded: true,

                              hint: const Text(
                                "Select",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              icon: const Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                color: Colors.grey,
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: "Male",
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: "Female",
                                  child: Text("Female"),
                                ),
                                DropdownMenuItem(
                                  value: "Other",
                                  child: Text("Other"),
                                ),
                              ],

                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const FieldLabel(
                          text: "Date of Birth",
                        ),

                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: selectDate,

                          child: Container(
                            height: 56,

                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                const Color(0xFFE2E8F0),
                              ),
                            ),

                            child: Row(
                              children: [

                                const Icon(
                                  Icons
                                      .calendar_today_outlined,
                                  color:
                                  Color(0xFF1976D2),
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    selectedDate == null
                                        ? "Select date"
                                        : "${selectedDate!.day}/"
                                        "${selectedDate!.month}/"
                                        "${selectedDate!.year}",

                                    style: TextStyle(
                                      color:
                                      selectedDate == null
                                          ? Colors.grey
                                          : Colors
                                          .black87,
                                      fontSize: 12,
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
                ],
              ),

              const SizedBox(height: 18),

              // =========================
              // PASSWORD
              // =========================
              const FieldLabel(
                text: "Password",
              ),

              const SizedBox(height: 8),

              CustomRegisterField(
                hint: "Create a password",
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,

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
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // CONFIRM PASSWORD
              // =========================
              const FieldLabel(
                text: "Confirm Password",
              ),

              const SizedBox(height: 8),

              CustomRegisterField(
                hint: "Confirm your password",
                icon: Icons.lock_outline_rounded,
                obscureText: obscureConfirmPassword,

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                      !obscureConfirmPassword;
                    });
                  },

                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // TERMS
              // =========================
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  SizedBox(
                    height: 24,
                    width: 24,

                    child: Checkbox(
                      value: false,
                      onChanged: (value) {},
                      activeColor:
                      const Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      "I agree to the Terms & Conditions "
                          "and Privacy Policy.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // REGISTER BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: () {},

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
                    "Create Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // LOGIN LINK
              // =========================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const LoginScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}


// =====================================================
// FIELD LABEL
// =====================================================

class FieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const FieldLabel({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}


// =====================================================
// CUSTOM REGISTER FIELD
// =====================================================

class CustomRegisterField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CustomRegisterField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1976D2),
        ),

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: Colors.white,

        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
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
    );
  }
}
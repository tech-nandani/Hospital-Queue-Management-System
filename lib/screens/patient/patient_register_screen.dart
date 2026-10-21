import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'patient_dashboard_screen.dart';
import '../../services/patient_service.dart';
import '../../widgets/google_account_picker_dialog.dart';
import '../../widgets/google_logo_icon.dart';
import '../../widgets/hospital_workflow_visual.dart';
import '../../widgets/split_registration_layout.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  String? selectedGender;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onFieldChanged);
    confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    passwordController.removeListener(_onFieldChanged);
    confirmPasswordController.removeListener(_onFieldChanged);
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dobController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dobController.text =
            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplitRegistrationLayout(
      leftVisual: const HospitalWorkflowVisual(
        mode: WorkflowVisualMode.patientRegistration,
        showHeader: true,
        activeToken: 'PT-104',
      ),
      mobileVisual: const HospitalWorkflowVisual(
        mode: WorkflowVisualMode.patientRegistration,
        isCompact: true,
        height: 200,
      ),
      child: _buildPatientForm(context),
    );
  }

  Widget _buildPatientForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==========================================
        // TOP BACK NAVIGATION & CAREFLOW BRANDING
        // ==========================================
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2EAF3)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF1976D2),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CareFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'PATIENT PORTAL',
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 26),

        // ==========================================
        // HEADINGS
        // ==========================================
        const Text(
          'Create Patient Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Create your patient account to manage appointments and visits.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        // ==========================================
        // REGISTRATION FORM CARD
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
          child: Builder(
            builder: (context) {
              final formContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _fieldLabel('Full Name', isRequired: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFF1976D2),
                    keyboardType: TextInputType.name,
                    autofillHints: kIsWeb ? null : const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Email Address
                  _fieldLabel('Email Address', isRequired: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFF1976D2),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: kIsWeb ? null : const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Mobile Number
                  _fieldLabel('Mobile Number', isRequired: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: mobileController,
                    style: const TextStyle(
                      color: Color(0xFF0F2740),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFF1976D2),
                    keyboardType: TextInputType.phone,
                    autofillHints:
                        kIsWeb ? null : const [AutofillHints.telephoneNumber],
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'Enter your mobile number',
                      icon: Icons.phone_outlined,
                    ),
                  ),

                const SizedBox(height: 18),

                // Gender
                _fieldLabel('Gender', isRequired: false),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  hint: const Text(
                    'Select gender',
                    style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select gender',
                    icon: Icons.wc_outlined,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF718096),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text(
                        'Male',
                        style: TextStyle(
                          color: Color(0xFF0F2740),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text(
                        'Female',
                        style: TextStyle(
                          color: Color(0xFF0F2740),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text(
                        'Other',
                        style: TextStyle(
                          color: Color(0xFF0F2740),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // Date of Birth
                _fieldLabel('Date of Birth', isRequired: false),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(14),
                  child: IgnorePointer(
                    child: TextField(
                      controller: dobController,
                      style: const TextStyle(
                        color: Color(0xFF0F2740),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select date of birth (YYYY-MM-DD)',
                        icon: Icons.calendar_month_outlined,
                        suffixIcon: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF1976D2),
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Password
                _fieldLabel('Password', isRequired: true),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF1976D2),
                  obscureText: !isPasswordVisible,
                  autofillHints:
                      kIsWeb ? null : const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: 'Create a password (min. 8 characters)',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (passwordController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear password',
                            splashRadius: 18,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () {
                              passwordController.clear();
                              passwordFocusNode.requestFocus();
                            },
                          ),
                        IconButton(
                          tooltip: isPasswordVisible
                              ? 'Hide password'
                              : 'Show password',
                          splashRadius: 18,
                          onPressed: () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF718096),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildPasswordRequirements(),

                const SizedBox(height: 18),

                // Confirm Password
                _fieldLabel('Confirm Password', isRequired: true),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF1976D2),
                  obscureText: !isConfirmPasswordVisible,
                  autofillHints:
                      kIsWeb ? null : const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => isLoading ? null : _register(),
                  decoration: _inputDecoration(
                    hint: 'Confirm your password',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (confirmPasswordController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear confirm password',
                            splashRadius: 18,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () {
                              confirmPasswordController.clear();
                              confirmPasswordFocusNode.requestFocus();
                            },
                          ),
                        IconButton(
                          tooltip: isConfirmPasswordVisible
                              ? 'Hide password'
                              : 'Show password',
                          splashRadius: 18,
                          onPressed: () => setState(
                            () =>
                                isConfirmPasswordVisible = !isConfirmPasswordVisible,
                          ),
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF718096),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildConfirmPasswordMatch(),

                const SizedBox(height: 26),

                // Create Patient Account Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _register,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_rounded, size: 19),
                    label: Text(
                      isLoading ? 'Creating Account...' : 'Create Patient Account',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // OR DIVIDER
                // =========================
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),

                const SizedBox(height: 16),

                // =========================
                // GOOGLE SIGN UP BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D3748),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleLogoIcon(size: 19),
                          SizedBox(width: 10),
                          Text(
                            'Sign up with Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF718096), fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(
                        context,
                        emailController.text.trim().isNotEmpty
                            ? emailController.text.trim()
                            : null,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
            return kIsWeb ? formContent : AutofillGroup(child: formContent);
          },
        ),
      ),

        const SizedBox(height: 20),

        // ==========================================
        // SECURITY TRUST INDICATOR
        // ==========================================
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: const [
            Icon(
              Icons.shield_outlined,
              color: Color(0xFF1976D2),
              size: 16,
            ),
            Text(
              'Protected patient registration • 256-Bit Encrypted',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final text = passwordController.text;
    final hasMinLength = text.length >= 8;

    if (text.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
            SizedBox(width: 6),
            Text(
              'Password must be at least 8 characters long',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(
            hasMinLength ? Icons.check_circle_rounded : Icons.info_rounded,
            size: 14,
            color: hasMinLength ? const Color(0xFF10B981) : const Color(0xFFE11D48),
          ),
          const SizedBox(width: 6),
          Text(
            hasMinLength
                ? 'Strong length requirement met (${text.length} characters)'
                : 'Too short (${text.length}/8 characters needed)',
            style: TextStyle(
              fontSize: 12,
              color: hasMinLength ? const Color(0xFF059669) : const Color(0xFFE11D48),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordMatch() {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;
    if (confirm.isEmpty) return const SizedBox.shrink();

    final matches = pass.isNotEmpty && pass == confirm;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: matches ? const Color(0xFF10B981) : const Color(0xFFE11D48),
          ),
          const SizedBox(width: 6),
          Text(
            matches ? 'Passwords match' : 'Passwords do not match',
            style: TextStyle(
              fontSize: 12,
              color: matches ? const Color(0xFF059669) : const Color(0xFFE11D48),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please complete all required fields.');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters long.');
      passwordFocusNode.requestFocus();
      passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: passwordController.text.length),
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match. Please verify your confirm password.');
      confirmPasswordFocusNode.requestFocus();
      confirmPasswordController.selection = TextSelection.fromPosition(
        TextPosition(offset: confirmPasswordController.text.length),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await PatientService.instance.registerWithBackend(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        dateOfBirth: dobController.text.trim().isNotEmpty
            ? dobController.text.trim()
            : null,
        gender: selectedGender,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
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
      _showMessage(raw);
      if (raw.toLowerCase().contains('password')) {
        passwordFocusNode.requestFocus();
        passwordController.selection = TextSelection.fromPosition(
          TextPosition(offset: passwordController.text.length),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = false);
    if (!kIsWeb) {
      TextInput.finishAutofillContext();
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Account created',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Your patient account is ready. Please login to continue.',
          style: TextStyle(color: Color(0xFF4A5568)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final regEmail = emailController.text.trim();
              Navigator.pop(context); // pop dialog
              Navigator.pop(context, regEmail); // pop to login screen with email
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Go to login'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool isRequired = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF34495E),
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
      ),
    );
  }

  bool _isGoogleDialogShowing = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleDialogShowing || isLoading) return;
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
      final name = result['name']?.trim() ?? nameController.text.trim();
      if (email.isEmpty) return;

      setState(() => isLoading = true);

      try {
        final account = await PatientService.instance.loginWithGoogle(
          email: email,
          name: name.isNotEmpty ? name : null,
        );
        if (!mounted) return;

        if (!kIsWeb) {
          TextInput.finishAutofillContext();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account ready! Welcome, ${account.name}'),
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
        _showMessage(raw);
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } finally {
      _isGoogleDialogShowing = false;
    }
  }
}

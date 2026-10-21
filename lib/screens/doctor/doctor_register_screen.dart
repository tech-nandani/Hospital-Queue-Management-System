import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/hospital_departments.dart';
import '../../services/verification_service.dart';
import '../../widgets/hospital_workflow_visual.dart';
import '../../widgets/split_registration_layout.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController identityController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  String selectedRole = 'Doctor';
  String? selectedDepartment;
  Uint8List? degreeBytes;
  Uint8List? identityBytes;
  Uint8List? registrationBytes;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

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
    hospitalController.dispose();
    cityController.dispose();
    licenseController.dispose();
    degreeController.dispose();
    identityController.dispose();
    registrationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplitRegistrationLayout(
      leftVisual: const HospitalWorkflowVisual(
        mode: WorkflowVisualMode.staffRegistration,
        showHeader: true,
        activeToken: 'ST-201',
      ),
      mobileVisual: const HospitalWorkflowVisual(
        mode: WorkflowVisualMode.staffRegistration,
        isCompact: true,
        height: 200,
      ),
      child: _buildStaffForm(context),
    );
  }

  Widget _buildStaffForm(BuildContext context) {
    final isDoctor = selectedRole == 'Doctor';

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
                Icons.badge_rounded,
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
                    'STAFF PORTAL',
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
          'Create Staff Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Create your professional account to manage hospital operations.',
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
                  // Role Selector
                _fieldLabel('Select Staff Role', isRequired: true),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: _buildRoleSelectorCard(
                        title: 'Doctor',
                        icon: Icons.medical_services_rounded,
                        isSelected: isDoctor,
                        onTap: () => setState(() => selectedRole = 'Doctor'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: _buildRoleSelectorCard(
                        title: 'Receptionist',
                        icon: Icons.badge_rounded,
                        isSelected: !isDoctor,
                        onTap: () =>
                            setState(() => selectedRole = 'Receptionist'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Department
                _fieldLabel('Department', isRequired: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedDepartment,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  hint: const Text(
                    'Select hospital department',
                    style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select department',
                    icon: Icons.domain_rounded,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF718096),
                  ),
                  items: hospitalDepartments
                      .map(
                        (dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(
                            dept,
                            style: const TextStyle(
                              color: Color(0xFF0F2740),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedDepartment = value),
                ),

                const SizedBox(height: 18),

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
                _fieldLabel('Professional Email', isRequired: true),
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
                    hint: 'Enter your professional email',
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

                // Hospital / Clinic Name
                _fieldLabel(
                  isDoctor ? 'Hospital / Clinic Name' : 'Hospital / Workplace Name',
                  isRequired: false,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hospitalController,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF1976D2),
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: isDoctor
                        ? 'e.g. CareFlow Clinic, City Care Hospital'
                        : 'e.g. CareFlow Hospital',
                    icon: Icons.local_hospital_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // City / Location
                _fieldLabel('City / Location', isRequired: false),
                const SizedBox(height: 8),
                TextField(
                  controller: cityController,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF1976D2),
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: 'e.g. Lucknow, Mumbai, Delhi',
                    icon: Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // License or Staff ID Number
                _fieldLabel(
                  isDoctor
                      ? 'Medical License Number'
                      : 'Staff / Employee ID Number',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: licenseController,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF1976D2),
                  decoration: _inputDecoration(
                    hint: isDoctor
                        ? 'Enter medical license number'
                        : 'Enter staff ID number',
                    icon: Icons.badge_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // Degree / Qualification Certificate Reference
                _fieldLabel(
                  isDoctor
                      ? 'Degree Certificate Reference'
                      : 'Qualification Certificate Reference',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: degreeController,
                  readOnly: true,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () => _pickDocument(
                    degreeController,
                    isDoctor
                        ? 'degree certificate'
                        : 'qualification certificate',
                    (bytes) => degreeBytes = bytes,
                  ),
                  decoration: _inputDecoration(
                    hint: isDoctor
                        ? 'Select degree certificate'
                        : 'Select qualification certificate',
                    icon: Icons.school_outlined,
                    suffixIcon: const Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Government Identity Proof Reference
                _fieldLabel('Government Identity Proof Reference', isRequired: true),
                const SizedBox(height: 8),
                TextField(
                  controller: identityController,
                  readOnly: true,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () => _pickDocument(
                    identityController,
                    'identity proof',
                    (bytes) => identityBytes = bytes,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select government identity proof',
                    icon: Icons.perm_identity_outlined,
                    suffixIcon: const Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Professional Registration Certificate Reference
                _fieldLabel(
                  isDoctor
                      ? 'Professional Registration Certificate'
                      : 'Employment / Registration Certificate',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: registrationController,
                  readOnly: true,
                  style: const TextStyle(
                    color: Color(0xFF0F2740),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () => _pickDocument(
                    registrationController,
                    'registration certificate',
                    (bytes) => registrationBytes = bytes,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select registration certificate',
                    icon: Icons.assignment_outlined,
                    suffixIcon: const Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF1976D2),
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
                  onSubmitted: (_) => _submitApplication(),
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

                // Create Staff Account Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_user_outlined, size: 19),
                    label: Text(
                      _isSubmitting
                          ? 'Registering...'
                          : 'Create Staff Account',
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
        // SECURITY / APPROVAL TRUST INDICATOR
        // ==========================================
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Icon(
              Icons.shield_outlined,
              color: Color(0xFF1976D2),
              size: 16,
            ),
            SizedBox(width: 7),
            Text(
              'Subject to Administrator Verification & Approval',
              textAlign: TextAlign.center,
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

  Widget _buildRoleSelectorCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F2FF)
              : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1976D2)
                : const Color(0xFFE2EAF3),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF718096),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF4A5568),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitApplication() async {
    final fields = [
      nameController.text.trim(),
      emailController.text.trim(),
      mobileController.text.trim(),
      selectedDepartment ?? '',
      passwordController.text,
      confirmPasswordController.text,
      licenseController.text.trim(),
      degreeController.text.trim(),
      identityController.text.trim(),
      registrationController.text.trim(),
    ];

    if (fields.any((field) => field.isEmpty)) {
      _showMessage('Please complete all profile and document fields.');
      return;
    }

    if (passwordController.text.length < 8) {
      _showMessage('Password must be at least 8 characters long.');
      passwordFocusNode.requestFocus();
      passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: passwordController.text.length),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Passwords do not match. Please verify your confirm password.');
      confirmPasswordFocusNode.requestFocus();
      confirmPasswordController.selection = TextSelection.fromPosition(
        TextPosition(offset: confirmPasswordController.text.length),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await VerificationService.instance.submitApplication(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        password: passwordController.text,
        role: selectedRole,
        department: selectedDepartment!,
        medicalLicenseNumber: licenseController.text.trim(),
        degreeCertificate: degreeController.text.trim(),
        identityProof: identityController.text.trim(),
        registrationCertificate: registrationController.text.trim(),
        hospitalName: hospitalController.text.trim().isNotEmpty
            ? hospitalController.text.trim()
            : null,
        city: cityController.text.trim().isNotEmpty
            ? cityController.text.trim()
            : null,
        degreeCertificateBytes: degreeBytes,
        identityProofBytes: identityBytes,
        registrationCertificateBytes: registrationBytes,
      );

      if (!kIsWeb) {
        TextInput.finishAutofillContext();
      }

      if (!mounted) return;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16806A),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Registration Successful',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: const Text(
            'Your staff account has been created and verified. You can now login with your credentials.',
            style: TextStyle(color: Color(0xFF4A5568)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final regEmail = emailController.text.trim();
                Navigator.pop(context); // pop dialog
                Navigator.pop(context, regEmail); // pop back to login screen with email
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Proceed to Login'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Error creating account: $e');
        if (e.toString().toLowerCase().contains('password')) {
          passwordFocusNode.requestFocus();
          passwordController.selection = TextSelection.fromPosition(
            TextPosition(offset: passwordController.text.length),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickDocument(
    TextEditingController controller,
    String documentLabel,
    ValueChanged<Uint8List?> onBytes,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result.isNotEmpty && result.first.name.isNotEmpty) {
      controller.text = result.first.name;
      onBytes(await result.first.readAsBytes());
    } else if (mounted) {
      _showMessage('Please select a valid $documentLabel file.');
    }
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
      hintStyle: const TextStyle(
        color: Color(0xFF8A9BA8),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
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
        borderSide: const BorderSide(color: Color(0xFFD6E2EE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6E2EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.8),
      ),
    );
  }
}

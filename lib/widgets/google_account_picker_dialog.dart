import 'package:flutter/material.dart';

import 'google_logo_icon.dart';

class GoogleAccountPickerDialog extends StatefulWidget {
  final String? suggestedEmail;

  const GoogleAccountPickerDialog({
    super.key,
    this.suggestedEmail,
  });

  @override
  State<GoogleAccountPickerDialog> createState() =>
      _GoogleAccountPickerDialogState();
}

class _GoogleAccountPickerDialogState extends State<GoogleAccountPickerDialog> {
  bool isEnteringCustom = false;
  final TextEditingController customEmailController = TextEditingController();
  final TextEditingController customNameController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedEmail == null || widget.suggestedEmail!.trim().isEmpty) {
      isEnteringCustom = true;
    }
  }

  @override
  void dispose() {
    customEmailController.dispose();
    customNameController.dispose();
    super.dispose();
  }

  String _formatNameFromEmail(String email) {
    if (email.contains('@')) {
      final handle = email.split('@').first;
      final parts = handle.split(RegExp(r'[._]'));
      return parts
          .where((p) => p.isNotEmpty)
          .map((p) => p[0].toUpperCase() + p.substring(1))
          .join(' ');
    }
    return email;
  }

  void _submitCustom() {
    final email = customEmailController.text.trim().toLowerCase();
    final name = customNameController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() {
        errorMessage = 'Please enter a valid Gmail / Google address.';
      });
      return;
    }

    Navigator.of(context).pop({
      'email': email,
      'name': name.isNotEmpty ? name : _formatNameFromEmail(email),
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggested = widget.suggestedEmail?.trim();
    final hasSuggested = suggested != null &&
        suggested.isNotEmpty &&
        suggested.contains('@');
    final suggestedName = hasSuggested ? _formatNameFromEmail(suggested) : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const GoogleLogoIcon(size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF718096),
                    splashRadius: 18,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasSuggested && !isEnteringCustom) ...[
                      const Text(
                        'Choose an account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'to continue to CareFlow Hospital',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Suggested Account Card
                      Material(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).pop({
                              'email': suggested,
                              'name': suggestedName,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFF1976D2),
                                  child: Text(
                                    suggestedName.isNotEmpty
                                        ? suggestedName[0].toUpperCase()
                                        : 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestedName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF1A202C),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        suggested,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF718096),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF1976D2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Use Another Account Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            isEnteringCustom = true;
                            errorMessage = null;
                          });
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Use another Google account',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1976D2),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Custom Email Input Form
                      if (hasSuggested) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isEnteringCustom = false;
                                errorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back to saved account'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1976D2),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      const Text(
                        'Enter your Google Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in using your Gmail address',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: customEmailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Gmail / Google Email',
                          hintText: 'yourname@gmail.com',
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 1.6,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: customNameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submitCustom(),
                        decoration: InputDecoration(
                          labelText: 'Full Name (Optional)',
                          hintText: 'e.g. Ashok Nandani',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 1.6,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),

                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFEB2B2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFE53E3E),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFC53030),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submitCustom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue with this Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEDF2F7), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Protected by Google Sign-In',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA0AEC0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4A5568),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/staff_application.dart';
import '../../services/verification_service.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final VerificationService verificationService = VerificationService.instance;

  @override
  void initState() {
    super.initState();
    verificationService.addListener(_refresh);
  }

  @override
  void dispose() {
    verificationService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pendingApplications = verificationService.applications
        .where(
          (application) => application.status == StaffApplicationStatus.pending,
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      appBar: AppBar(
        title: const Text('Professional Approvals'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
      ),
      body: pendingApplications.isEmpty
          ? const Center(
              child: Text(
                'No pending doctor or nurse applications.',
                style: TextStyle(color: Color(0xFF6B7A8C)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pendingApplications.length,
              itemBuilder: (context, index) {
                return _ApplicationCard(
                  application: pendingApplications[index],
                  onApprove: () => verificationService.approve(
                    pendingApplications[index].id,
                  ),
                  onReject: () =>
                      verificationService.reject(pendingApplications[index].id),
                );
              },
            ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final StaffApplication application;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${application.name} • ${application.role}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            const SizedBox(height: 6),
            Text('${application.email}  |  ${application.mobile}'),
            const Divider(height: 24),
            _documentRow(
              context,
              'Medical license',
              application.medicalLicenseNumber,
            ),
            _documentRow(
              context,
              'Degree certificate',
              application.degreeCertificate,
              application.degreeCertificateBytes,
            ),
            _documentRow(
              context,
              'Identity proof',
              application.identityProof,
              application.identityProofBytes,
            ),
            _documentRow(
              context,
              'Registration certificate',
              application.registrationCertificate,
              application.registrationCertificateBytes,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentRow(
    BuildContext context,
    String label,
    String value, [
    Uint8List? bytes,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2EAF3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: Color(0xFF1976D2),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDocument(context, label, value, bytes),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocument(
    BuildContext context,
    String label,
    String filename,
    Uint8List? bytes,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bytes != null)
              Image.memory(
                bytes,
                height: 220,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stackTrace) => const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 64,
                  color: Color(0xFFD95757),
                ),
              )
            else
              const Icon(
                Icons.description_rounded,
                size: 48,
                color: Color(0xFF1976D2),
              ),
            const SizedBox(height: 12),
            Text(filename, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'This uploaded document is attached to the professional application and ready for admin review.',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

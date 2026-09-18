import 'dart:typed_data';

enum StaffApplicationStatus { pending, approved, rejected }

class StaffApplication {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String role;
  final String department;
  final String medicalLicenseNumber;
  final String degreeCertificate;
  final String identityProof;
  final String registrationCertificate;
  final Uint8List? degreeCertificateBytes;
  final Uint8List? identityProofBytes;
  final Uint8List? registrationCertificateBytes;
  StaffApplicationStatus status;

  StaffApplication({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.role,
    required this.department,
    required this.medicalLicenseNumber,
    required this.degreeCertificate,
    required this.identityProof,
    required this.registrationCertificate,
    this.degreeCertificateBytes,
    this.identityProofBytes,
    this.registrationCertificateBytes,
    this.status = StaffApplicationStatus.pending,
  });
}

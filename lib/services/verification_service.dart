import 'package:flutter/foundation.dart';

import '../models/staff_application.dart';

class VerificationService extends ChangeNotifier {
  VerificationService._();

  static final VerificationService instance = VerificationService._();

  final List<StaffApplication> _applications = [];
  String? rememberedEmail;
  String? rememberedDoctorEmail;
  String? rememberedReceptionistEmail;
  StaffApplication? _currentStaff;

  List<StaffApplication> get applications => List.unmodifiable(_applications);
  StaffApplication? get currentStaff => _currentStaff;

  void logout() {
    _currentStaff = null;
    notifyListeners();
  }

  StaffApplication submitApplication({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String role,
    required String department,
    required String medicalLicenseNumber,
    required String degreeCertificate,
    required String identityProof,
    required String registrationCertificate,
    Uint8List? degreeCertificateBytes,
    Uint8List? identityProofBytes,
    Uint8List? registrationCertificateBytes,
  }) {
    final cleanEmail = email.trim();
    rememberedEmail = cleanEmail;
    if (role == 'Doctor') {
      rememberedDoctorEmail = cleanEmail;
    } else {
      rememberedReceptionistEmail = cleanEmail;
    }

    final application = StaffApplication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      role: role,
      department: department,
      medicalLicenseNumber: medicalLicenseNumber,
      degreeCertificate: degreeCertificate,
      identityProof: identityProof,
      registrationCertificate: registrationCertificate,
      degreeCertificateBytes: degreeCertificateBytes,
      identityProofBytes: identityProofBytes,
      registrationCertificateBytes: registrationCertificateBytes,
    );

    _applications.add(application);
    notifyListeners();
    return application;
  }

  StaffApplication? findByLogin(String identifier) {
    final normalizedIdentifier = identifier.trim().toLowerCase();
    for (final application in _applications) {
      if (application.email.toLowerCase() == normalizedIdentifier ||
          application.mobile == identifier.trim()) {
        return application;
      }
    }
    return null;
  }

  StaffApplication? authenticate(String identifier, String password) {
    final application = findByLogin(identifier);
    if (application == null || application.password != password) return null;

    final clean = identifier.trim();
    rememberedEmail = clean;
    if (application.role == 'Doctor') {
      rememberedDoctorEmail = clean;
    } else {
      rememberedReceptionistEmail = clean;
    }
    _currentStaff = application;
    notifyListeners();
    return application;
  }

  List<StaffApplication> approvedProfessionals(String department) {
    return _applications
        .where(
          (application) =>
              application.status == StaffApplicationStatus.approved &&
              application.department == department,
        )
        .toList(growable: false);
  }

  void approve(String id) => _setStatus(id, StaffApplicationStatus.approved);

  void reject(String id) => _setStatus(id, StaffApplicationStatus.rejected);

  void _setStatus(String id, StaffApplicationStatus status) {
    final application = _applications.cast<StaffApplication?>().firstWhere(
      (item) => item?.id == id,
      orElse: () => null,
    );
    if (application == null) return;

    application.status = status;
    notifyListeners();
  }
}

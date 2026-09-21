import 'package:flutter/foundation.dart';
import '../models/staff_application.dart';
import 'patient_api_service.dart';

class VerificationService extends ChangeNotifier {
  VerificationService._() {
    _seedDefaultStaff();
  }

  static final VerificationService instance = VerificationService._();

  final List<StaffApplication> _applications = [];
  String? rememberedEmail;
  String? rememberedDoctorEmail;
  String? rememberedReceptionistEmail;
  StaffApplication? _currentStaff;

  List<StaffApplication> get applications => List.unmodifiable(_applications);
  StaffApplication? get currentStaff => _currentStaff;

  void _seedDefaultStaff() {
    // Seed Dr. Priya Sharma (matches backend seed)
    _applications.add(
      StaffApplication(
        id: '1',
        name: 'Dr. Priya Sharma',
        email: 'priya.sharma@hospital.org',
        mobile: '9876543210',
        password: 'DoctorPass123!',
        role: 'Doctor',
        department: 'General Medicine',
        medicalLicenseNumber: 'MCI-102938',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      ),
    );

    // Seed Sunita Rao - Receptionist (matches backend seed)
    _applications.add(
      StaffApplication(
        id: '2',
        name: 'Sunita Rao',
        email: 'receptionist@hospital.org',
        mobile: '9876543220',
        password: 'ReceptionPass123!',
        role: 'Receptionist',
        department: 'Front Desk',
        medicalLicenseNumber: 'REC-998811',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      ),
    );
  }

  void setCurrentStaff(StaffApplication? staff) {
    _currentStaff = staff;
    notifyListeners();
  }

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

  Future<StaffApplication?> authenticateAsync(String identifier, String password) async {
    final clean = identifier.trim();
    final local = authenticate(clean, password);
    if (local != null) return local;

    // Try backend authentication
    try {
      final res = await PatientApiService.instance.staffLogin(
        email: clean,
        password: password,
      );

      final userObj = res['user'] as Map<String, dynamic>?;
      final staffApp = StaffApplication(
        id: userObj?['id']?.toString() ?? '1',
        name: userObj?['name']?.toString() ?? (clean.contains('priya') ? 'Dr. Priya Sharma' : 'Staff Member'),
        email: clean,
        mobile: userObj?['mobile']?.toString() ?? '',
        password: password,
        role: userObj?['role']?.toString() ?? (clean.contains('priya') ? 'Doctor' : 'Receptionist'),
        department: userObj?['department']?.toString() ?? 'General Medicine',
        medicalLicenseNumber: 'VERIFIED',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      );

      _applications.removeWhere((a) => a.email.toLowerCase() == clean.toLowerCase());
      _applications.add(staffApp);
      _currentStaff = staffApp;
      rememberedEmail = clean;
      notifyListeners();
      return staffApp;
    } catch (e) {
      debugPrint('Backend staff login error: $e');
      return null;
    }
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

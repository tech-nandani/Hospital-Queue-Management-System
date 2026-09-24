import 'package:flutter/foundation.dart';
import '../models/staff_application.dart';
import 'patient_api_service.dart';
import 'storage/staff_storage.dart';

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
    _applications.clear();

    // 1. Seed Dr. Priya Sharma - Doctor (matches backend seed)
    _applications.add(
      StaffApplication(
        id: 'fixed_staff_1',
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

    // 2. Seed Sunita Rao - Receptionist (matches backend seed)
    _applications.add(
      StaffApplication(
        id: 'fixed_staff_2',
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

    // Re-hydrate registered staff from persistent storage
    _loadFromStorage();
  }

  void _loadFromStorage() {
    try {
      final savedList = StaffStorage.loadApplications();
      for (final item in savedList) {
        final app = StaffApplication.fromJson(item);
        // Skip default fixed seeds to keep them canonical
        if (app.email.toLowerCase() == 'priya.sharma@hospital.org' ||
            app.email.toLowerCase() == 'receptionist@hospital.org') {
          continue;
        }
        // Filter out legacy hardcoded duplicate seed if present in browser localStorage
        if (app.email.toLowerCase() == 'priyasharma@gmail.com' &&
            app.name == 'Dr. Priya Sharma' &&
            (app.id == '1' || app.id == 'fixed_staff_1')) {
          continue;
        }
        final existingIdx = _applications.indexWhere(
          (a) => a.email.toLowerCase() == app.email.toLowerCase(),
        );
        if (existingIdx != -1) {
          _applications[existingIdx] = app;
        } else {
          _applications.add(app);
        }
      }
      final emails = StaffStorage.loadRememberedEmails();
      rememberedEmail = emails['rememberedEmail'] ?? rememberedEmail;
      rememberedDoctorEmail =
          emails['rememberedDoctorEmail'] ?? rememberedDoctorEmail;
      rememberedReceptionistEmail =
          emails['rememberedReceptionistEmail'] ?? rememberedReceptionistEmail;
    } catch (e) {
      debugPrint('Error loading staff from storage: $e');
    }
  }

  void refreshFromStorage() {
    _loadFromStorage();
    notifyListeners();
  }

  void _saveToStorage() {
    try {
      final data = _applications.map((a) => a.toJson()).toList();
      StaffStorage.saveApplications(data);
      StaffStorage.saveRememberedEmails({
        'rememberedEmail': rememberedEmail,
        'rememberedDoctorEmail': rememberedDoctorEmail,
        'rememberedReceptionistEmail': rememberedReceptionistEmail,
      });
    } catch (e) {
      debugPrint('Error saving staff to storage: $e');
    }
  }

  void setCurrentStaff(StaffApplication? staff) {
    _currentStaff = staff;
    notifyListeners();
  }

  void logout() {
    _currentStaff = null;
    notifyListeners();
  }

  Future<StaffApplication> submitApplication({
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
    String? hospitalName,
    String? city,
    Uint8List? degreeCertificateBytes,
    Uint8List? identityProofBytes,
    Uint8List? registrationCertificateBytes,
    StaffApplicationStatus status = StaffApplicationStatus.pending,
  }) async {
    final cleanEmail = email.trim();
    rememberedEmail = cleanEmail;
    if (role == 'Doctor') {
      rememberedDoctorEmail = cleanEmail;
    } else {
      rememberedReceptionistEmail = cleanEmail;
    }

    final uniqueId =
        'staff_${DateTime.now().microsecondsSinceEpoch}_${cleanEmail.hashCode.abs()}';

    final application = StaffApplication(
      id: uniqueId,
      name: name,
      email: cleanEmail,
      mobile: mobile,
      password: password,
      role: role,
      department: department,
      medicalLicenseNumber: medicalLicenseNumber,
      degreeCertificate: degreeCertificate,
      identityProof: identityProof,
      registrationCertificate: registrationCertificate,
      hospitalName: hospitalName ?? '',
      city: city ?? '',
      degreeCertificateBytes: degreeCertificateBytes,
      identityProofBytes: identityProofBytes,
      registrationCertificateBytes: registrationCertificateBytes,
      status: status,
    );

    final existingIndex = _applications.indexWhere(
      (a) => a.email.toLowerCase() == cleanEmail.toLowerCase(),
    );
    if (existingIndex != -1) {
      _applications[existingIndex] = application;
    } else {
      _applications.add(application);
    }
    _saveToStorage();
    notifyListeners();

    // Call backend API to persist registration in SQLite database
    try {
      final res = await PatientApiService.instance.staffRegister(
        name: name,
        email: cleanEmail,
        password: password,
        role: role,
        department: department,
        mobile: mobile,
        medicalLicenseNumber: medicalLicenseNumber,
        hospitalName: hospitalName,
        city: city,
      );

      final staffMap =
          (res['staff'] ?? res['user']) as Map<String, dynamic>?;
      if (staffMap != null && staffMap['id'] != null) {
        final updatedApp = StaffApplication(
          id: uniqueId,
          name: staffMap['name']?.toString() ?? name,
          email: cleanEmail,
          mobile: mobile,
          password: password,
          role: staffMap['role']?.toString() ?? role,
          department: staffMap['department']?.toString() ?? department,
          medicalLicenseNumber: medicalLicenseNumber,
          degreeCertificate: degreeCertificate,
          identityProof: identityProof,
          registrationCertificate: registrationCertificate,
          hospitalName: staffMap['hospital_name']?.toString() ?? hospitalName ?? '',
          city: staffMap['city']?.toString() ?? city ?? '',
          degreeCertificateBytes: degreeCertificateBytes,
          identityProofBytes: identityProofBytes,
          registrationCertificateBytes: registrationCertificateBytes,
          status: status,
        );
        final updateIndex = _applications.indexWhere(
          (a) => a.email.toLowerCase() == cleanEmail.toLowerCase(),
        );
        if (updateIndex != -1) {
          _applications[updateIndex] = updatedApp;
        } else {
          _applications.add(updatedApp);
        }
        _saveToStorage();
        notifyListeners();
        return updatedApp;
      }
    } catch (e) {
      debugPrint('Backend staff register note: $e');
    }

    return application;
  }

  StaffApplication? findByLogin(String identifier) {
    _loadFromStorage();
    final normalizedIdentifier = identifier.trim().toLowerCase();
    for (final application in _applications) {
      if (application.email.toLowerCase() == normalizedIdentifier ||
          application.mobile == identifier.trim()) {
        return application;
      }
    }
    return null;
  }

  Future<StaffApplication?> authenticateAsync(
    String identifier,
    String password,
  ) async {
    final clean = identifier.trim();
    final local = authenticate(clean, password);
    if (local != null) {
      _saveToStorage();
      return local;
    }

    // Try backend authentication
    try {
      final res = await PatientApiService.instance.staffLogin(
        email: clean,
        password: password,
      );

      final userObj =
          (res['staff'] ?? res['user']) as Map<String, dynamic>?;
      final staffApp = StaffApplication(
        id: userObj?['id']?.toString() ?? '1',
        name: userObj?['name']?.toString() ??
            (clean.contains('priya') ? 'Dr. Priya Sharma' : 'Staff Member'),
        email: clean,
        mobile: userObj?['mobile']?.toString() ?? '',
        password: password,
        role: userObj?['role']?.toString() ??
            (clean.contains('priya') ? 'Doctor' : 'Receptionist'),
        department:
            userObj?['department']?.toString() ?? 'General Medicine',
        medicalLicenseNumber: 'VERIFIED',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      );

      _applications.removeWhere(
        (a) => a.email.toLowerCase() == clean.toLowerCase(),
      );
      _applications.add(staffApp);
      _currentStaff = staffApp;
      rememberedEmail = clean;
      if (staffApp.role == 'Doctor') {
        rememberedDoctorEmail = clean;
      } else {
        rememberedReceptionistEmail = clean;
      }
      _saveToStorage();
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
    _saveToStorage();
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
    _saveToStorage();
    notifyListeners();
  }
}

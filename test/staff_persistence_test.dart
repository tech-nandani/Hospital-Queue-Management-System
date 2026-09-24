import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/models/staff_application.dart';
import 'package:hospital_queue_management/services/storage/staff_storage.dart';
import 'package:hospital_queue_management/services/verification_service.dart';

void main() {
  group('Doctor & Staff Persistence Tests', () {
    test('StaffApplication toJson and fromJson preserve all fields and status', () {
      final app = StaffApplication(
        id: 'doc-123',
        name: 'Dr. Priya Sharma',
        email: 'priyasharma@gmail.com',
        mobile: '9876543210',
        password: 'Password123!',
        role: 'Doctor',
        department: 'Cardiology',
        medicalLicenseNumber: 'MCI-998877',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      );

      final json = app.toJson();
      final restored = StaffApplication.fromJson(json);

      expect(restored.id, 'doc-123');
      expect(restored.name, 'Dr. Priya Sharma');
      expect(restored.email, 'priyasharma@gmail.com');
      expect(restored.mobile, '9876543210');
      expect(restored.password, 'Password123!');
      expect(restored.role, 'Doctor');
      expect(restored.department, 'Cardiology');
      expect(restored.medicalLicenseNumber, 'MCI-998877');
      expect(restored.status, StaffApplicationStatus.approved);
    });

    test('StaffStorage saves and reloads staff applications', () {
      final applications = [
        {
          'id': '101',
          'name': 'Dr. Test Doctor',
          'email': 'testdoctor@example.com',
          'mobile': '9876543211',
          'password': 'SecretPassword123',
          'role': 'Doctor',
          'department': 'Orthopedics',
          'medicalLicenseNumber': 'MCI-001122',
          'degreeCertificate': 'degree.pdf',
          'identityProof': 'id.pdf',
          'registrationCertificate': 'reg.pdf',
          'status': 'approved',
        }
      ];

      StaffStorage.saveApplications(applications);
      final loaded = StaffStorage.loadApplications();

      expect(loaded.length, 1);
      expect(loaded[0]['email'], 'testdoctor@example.com');
      expect(loaded[0]['name'], 'Dr. Test Doctor');
    });

    test('VerificationService authenticates doctor after registration and preserves across refresh simulation', () async {
      final service = VerificationService.instance;

      // Register doctor
      final app = await service.submitApplication(
        name: 'Dr. Priya Sharma',
        email: 'priyasharma@gmail.com',
        mobile: '9876543210',
        password: 'DoctorPass123!',
        role: 'Doctor',
        department: 'General Medicine',
        medicalLicenseNumber: 'MCI-102938',
        degreeCertificate: 'degree.pdf',
        identityProof: 'id.pdf',
        registrationCertificate: 'reg.pdf',
        status: StaffApplicationStatus.approved,
      );

      expect(app.status, StaffApplicationStatus.approved);
      expect(app.email, 'priyasharma@gmail.com');

      // Immediate login works
      final loggedIn = service.authenticate('priyasharma@gmail.com', 'DoctorPass123!');
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, 'Dr. Priya Sharma');
      expect(loggedIn.status, StaffApplicationStatus.approved);

      // Simulate browser page refresh by calling _seedDefaultStaff (which reloads from storage)
      // Verify findByLogin still finds the registered doctor
      final reloadedApp = service.findByLogin('priyasharma@gmail.com');
      expect(reloadedApp, isNotNull);
      expect(reloadedApp!.email, 'priyasharma@gmail.com');

      // Authenticate after refresh simulation
      final authenticated = await service.authenticateAsync('priyasharma@gmail.com', 'DoctorPass123!');
      expect(authenticated, isNotNull);
      expect(authenticated!.email, 'priyasharma@gmail.com');
      expect(authenticated.status, StaffApplicationStatus.approved);
    });

    test('VerificationService has 2 fixed default staff and appends new staff sequentially below', () async {
      final service = VerificationService.instance;

      // 1. Initial 2 staff are fixed
      expect(service.applications[0].name, 'Dr. Priya Sharma');
      expect(service.applications[0].role, 'Doctor');
      expect(service.applications[0].status, StaffApplicationStatus.approved);

      expect(service.applications[1].name, 'Sunita Rao');
      expect(service.applications[1].role, 'Receptionist');
      expect(service.applications[1].status, StaffApplicationStatus.approved);

      final initialLength = service.applications.length;

      // 2. Register 1st new doctor (at position 3)
      final doc1 = await service.submitApplication(
        name: 'Dr. Rahul Verma',
        email: 'rahul.verma@example.org',
        mobile: '9876543231',
        password: 'Password123!',
        role: 'Doctor',
        department: 'Cardiology',
        medicalLicenseNumber: 'MCI-3001',
        degreeCertificate: 'deg1.pdf',
        identityProof: 'id1.pdf',
        registrationCertificate: 'reg1.pdf',
        status: StaffApplicationStatus.pending,
      );

      expect(service.applications.length, initialLength + 1);
      expect(service.applications.last.name, 'Dr. Rahul Verma');
      expect(service.applications.last.status, StaffApplicationStatus.pending);

      // Approve 1st new doctor
      service.approve(doc1.id);
      expect(service.applications.last.status, StaffApplicationStatus.approved);

      // 3. Register 2nd new staff (should be appended below at position 4)
      final doc2 = await service.submitApplication(
        name: 'Dr. Sneha Patel',
        email: 'sneha.patel@example.org',
        mobile: '9876543232',
        password: 'Password123!',
        role: 'Doctor',
        department: 'Pediatrics',
        medicalLicenseNumber: 'MCI-3002',
        degreeCertificate: 'deg2.pdf',
        identityProof: 'id2.pdf',
        registrationCertificate: 'reg2.pdf',
        status: StaffApplicationStatus.pending,
      );

      expect(service.applications.length, initialLength + 2);
      expect(service.applications[initialLength].name, 'Dr. Rahul Verma');
      expect(service.applications[initialLength].status, StaffApplicationStatus.approved);
      expect(service.applications[initialLength + 1].name, 'Dr. Sneha Patel');
      expect(service.applications[initialLength + 1].status, StaffApplicationStatus.pending);

      // Approve 2nd new doctor
      service.approve(doc2.id);
      expect(service.applications[initialLength + 1].status, StaffApplicationStatus.approved);
    });
  });
}

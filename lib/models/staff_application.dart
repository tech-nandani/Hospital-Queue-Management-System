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
  final String hospitalName;
  final String city;
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
    this.hospitalName = '',
    this.city = '',
    this.degreeCertificateBytes,
    this.identityProofBytes,
    this.registrationCertificateBytes,
    this.status = StaffApplicationStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'role': role,
      'department': department,
      'medicalLicenseNumber': medicalLicenseNumber,
      'degreeCertificate': degreeCertificate,
      'identityProof': identityProof,
      'registrationCertificate': registrationCertificate,
      'hospitalName': hospitalName,
      'city': city,
      'status': status.name,
    };
  }

  factory StaffApplication.fromJson(Map<String, dynamic> json) {
    return StaffApplication(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Doctor',
      department: json['department']?.toString() ?? 'General Medicine',
      medicalLicenseNumber: json['medicalLicenseNumber']?.toString() ?? '',
      degreeCertificate: json['degreeCertificate']?.toString() ?? '',
      identityProof: json['identityProof']?.toString() ?? '',
      registrationCertificate: json['registrationCertificate']?.toString() ?? '',
      hospitalName: json['hospitalName']?.toString() ??
          json['hospital_name']?.toString() ??
          '',
      city: json['city']?.toString() ?? '',
      status: StaffApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => StaffApplicationStatus.approved,
      ),
    );
  }
}

class AdminAuthService {
  AdminAuthService._();

  static final AdminAuthService instance = AdminAuthService._();

  static const String adminEmail = 'admin@hospital.com';
  static const String adminPassword = 'admin123';

  bool authenticate(String email, String password) {
    return email.trim().toLowerCase() == adminEmail &&
        password == adminPassword;
  }
}

import 'package:flutter/foundation.dart';

import '../models/patient_appointment.dart';
import 'patient_api_service.dart';
import 'symptom_assistant_service.dart';

class PatientAccount {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String? dateOfBirth;
  final String? gender;
  final String? address;

  PatientAccount({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    this.dateOfBirth,
    this.gender,
    this.address,
  });
}

class PatientNotification {
  final String title;
  final String message;
  final DateTime createdAt;
  bool read;

  PatientNotification({
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });
}

class PatientRecord {
  final String category;
  final String title;
  final String description;

  const PatientRecord({
    required this.category,
    required this.title,
    required this.description,
  });
}

class PatientService extends ChangeNotifier {
  PatientService._();

  static final PatientService instance = PatientService._();

  PatientAccount? _account;
  final List<PatientAppointment> _appointments = [];
  final List<PatientNotification> _notifications = [];
  final List<PatientRecord> _records = [];
  String? _authToken;
  String? rememberedEmail;

  PatientAccount? get account => _account;
  List<PatientAppointment> get appointments => List.unmodifiable(_appointments);
  List<PatientNotification> get notifications =>
      List.unmodifiable(_notifications);
  List<PatientRecord> get records => List.unmodifiable(_records);
  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.read).length;
  bool get isBackendAuthenticated => _authToken != null;
  String? get authToken => _authToken;

  void logout() {
    _authToken = null;
    _account = null;
    _appointments.clear();
    _notifications.clear();
    _records.clear();
    SymptomAssistantService.instance.resetForPatient(null);
    notifyListeners();
  }

  Future<void> fetchProfileFromBackend() async {
    final token = _authToken;
    if (token == null) return;
    try {
      final data = await PatientApiService.instance.getProfile(token);
      _account = PatientAccount(
        name: data['name'] as String? ?? _account?.name ?? 'Patient',
        email: data['email'] as String? ?? _account?.email ?? '',
        mobile: data['mobile'] as String? ?? _account?.mobile ?? '',
        password: _account?.password ?? '',
        dateOfBirth: data['date_of_birth'] as String? ?? _account?.dateOfBirth,
        gender: data['gender'] as String? ?? _account?.gender,
        address: data['address'] as String? ?? _account?.address,
      );
      SymptomAssistantService.instance.resetForPatient(_account?.email);
      notifyListeners();
    } catch (_) {}
    await fetchAppointmentsFromBackend();
  }

  Future<void> fetchAppointmentsFromBackend() async {
    final token = _authToken;
    if (token == null) return;
    try {
      final list = await PatientApiService.instance.getAppointments(token);
      _appointments.clear();
      for (final item in list) {
        _appointments.add(PatientAppointment.fromJson(item));
      }
      notifyListeners();
    } catch (_) {}
  }

  static String formatTime24(String raw) {
    final clean = raw.trim().toUpperCase();
    final isPm = clean.endsWith('PM');
    final isAm = clean.endsWith('AM');
    final timePart = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = timePart.split(':');
    int hour = int.tryParse(parts[0]) ?? 9;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  static String formatTime12(String raw) {
    if (raw.toUpperCase().contains('AM') || raw.toUpperCase().contains('PM')) {
      return raw;
    }
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    int hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<PatientAccount> updateProfileWithBackend({
    required String name,
    required String mobile,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final token = _authToken;
    if (token != null) {
      final data = await PatientApiService.instance.updateProfile(
        token: token,
        name: name,
        mobile: mobile,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
      );
      _account = PatientAccount(
        name: data['name'] as String? ?? name,
        email: data['email'] as String? ?? _account?.email ?? '',
        mobile: data['mobile'] as String? ?? mobile,
        password: _account?.password ?? '',
        dateOfBirth: data['date_of_birth'] as String? ?? dateOfBirth,
        gender: data['gender'] as String? ?? gender,
        address: data['address'] as String? ?? address ?? _account?.address,
      );
    } else {
      _account = PatientAccount(
        name: name,
        email: _account?.email ?? '',
        mobile: mobile,
        password: _account?.password ?? '',
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address ?? _account?.address,
      );
    }
    notifyListeners();
    return _account!;
  }

  Future<PatientAccount> registerWithBackend({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final data = await PatientApiService.instance.register(
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
    );
    _authToken = data['access'] as String?;
    rememberedEmail = email.trim();
    final patient = data['patient'] as Map<String, dynamic>;
    _account = PatientAccount(
      name: patient['name'] as String? ?? name,
      email: patient['email'] as String? ?? email,
      mobile: patient['mobile'] as String? ?? mobile,
      password: password,
      dateOfBirth: patient['date_of_birth'] as String? ?? dateOfBirth,
      gender: patient['gender'] as String? ?? gender,
      address: patient['address'] as String? ?? address,
    );
    notifyListeners();
    return _account!;
  }

  Future<PatientAccount> loginWithBackend({
    required String email,
    required String password,
  }) async {
    final data = await PatientApiService.instance.login(
      email: email,
      password: password,
    );
    _authToken = data['access'] as String?;
    rememberedEmail = email.trim();
    final patient = data['patient'] as Map<String, dynamic>;
    _account = PatientAccount(
      name: patient['name'] as String? ?? 'Patient',
      email: patient['email'] as String? ?? email,
      mobile: patient['mobile'] as String? ?? '',
      password: password,
      dateOfBirth: patient['date_of_birth'] as String?,
      gender: patient['gender'] as String?,
      address: patient['address'] as String? ?? _account?.address,
    );
    notifyListeners();
    await fetchAppointmentsFromBackend();
    return _account!;
  }

  Future<PatientAccount> loginWithGoogle({
    required String email,
    String? name,
    String? googleId,
  }) async {
    final data = await PatientApiService.instance.loginWithGoogle(
      email: email,
      name: name,
      googleId: googleId,
    );
    _authToken = data['access'] as String?;
    rememberedEmail = email.trim();
    final patient = data['patient'] as Map<String, dynamic>;
    _account = PatientAccount(
      name: patient['name'] as String? ?? name ?? 'Patient',
      email: patient['email'] as String? ?? email,
      mobile: patient['mobile'] as String? ?? '',
      password: '',
      dateOfBirth: patient['date_of_birth'] as String?,
      gender: patient['gender'] as String?,
      address: patient['address'] as String? ?? _account?.address,
    );
    notifyListeners();
    await fetchAppointmentsFromBackend();
    return _account!;
  }

  PatientAccount register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? dateOfBirth,
    String? gender,
  }) {
    rememberedEmail = email.trim();
    _account = PatientAccount(
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
    _notifications.insert(
      0,
      PatientNotification(
        title: 'Welcome to Patient Care',
        message: 'Your account is ready for appointment booking.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return _account!;
  }

  bool authenticate(String identifier, String password) {
    final account = _account;
    if (account == null || account.password != password) return false;

    final value = identifier.trim().toLowerCase();
    return account.email.toLowerCase() == value ||
        account.mobile == identifier.trim();
  }

  PatientAppointment? get activeAppointment {
    for (final appointment in _appointments.reversed) {
      if (appointment.status == PatientAppointmentStatus.waiting ||
          appointment.status == PatientAppointmentStatus.upcoming) {
        return appointment;
      }
    }
    return null;
  }

  Future<PatientAppointment> bookAppointmentWithBackend({
    required int doctorId,
    required String departmentName,
    required String doctorName,
    required DateTime date,
    required String time,
    String? reason,
  }) async {
    final token = _authToken;
    if (token != null) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeStr = formatTime24(time);
      final data = await PatientApiService.instance.bookAppointment(
        token: token,
        doctorId: doctorId,
        date: dateStr,
        time: timeStr,
        reason: reason,
      );
      final appointment = PatientAppointment.fromJson(data);
      _appointments.add(appointment);
      _notifications.insert(
        0,
        PatientNotification(
          title: 'Appointment confirmed',
          message:
              '${appointment.department} with ${appointment.doctor} is booked for ${appointment.time}.',
          createdAt: DateTime.now(),
        ),
      );
      notifyListeners();
      return appointment;
    }

    return bookAppointment(
      department: departmentName,
      doctor: doctorName,
      date: date,
      time: time,
    );
  }

  PatientAppointment bookAppointment({
    required String department,
    required String doctor,
    required DateTime date,
    required String time,
  }) {
    final appointment = PatientAppointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      department: department,
      doctor: doctor,
      date: date,
      time: time,
      queueNumber: _appointments.length + 1,
      estimatedWaitMinutes: 15 + (_appointments.length * 5),
      status: PatientAppointmentStatus.waiting,
    );
    _appointments.add(appointment);
    _notifications.insert(
      0,
      PatientNotification(
        title: 'Appointment confirmed',
        message:
            '${appointment.department} with ${appointment.doctor} is booked for ${appointment.time}.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return appointment;
  }

  Future<void> cancelAppointmentWithBackend(String id) async {
    final token = _authToken;
    final numId = int.tryParse(id);
    if (token != null && numId != null) {
      try {
        await PatientApiService.instance.cancelAppointment(
          token: token,
          appointmentId: numId,
        );
      } catch (_) {}
    }
    cancelAppointment(id);
  }

  void cancelAppointment(String id) {
    final appointment = _find(id);
    if (appointment == null) return;
    appointment.status = PatientAppointmentStatus.cancelled;
    _notifications.insert(
      0,
      PatientNotification(
        title: 'Appointment cancelled',
        message: '${appointment.department} appointment has been cancelled.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> rescheduleAppointmentWithBackend({
    required String id,
    required DateTime date,
    required String time,
  }) async {
    final token = _authToken;
    final numId = int.tryParse(id);
    if (token != null && numId != null) {
      try {
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final timeStr = formatTime24(time);
        await PatientApiService.instance.rescheduleAppointment(
          token: token,
          appointmentId: numId,
          date: dateStr,
          time: timeStr,
        );
      } catch (_) {}
    }
    rescheduleAppointment(id: id, date: date, time: time);
  }

  void rescheduleAppointment({
    required String id,
    required DateTime date,
    required String time,
  }) {
    final appointment = _find(id);
    if (appointment == null) return;
    appointment.date = date;
    appointment.time = time;
    appointment.status = PatientAppointmentStatus.upcoming;
    _notifications.insert(
      0,
      PatientNotification(
        title: 'Appointment rescheduled',
        message: '${appointment.department} is now booked for $time.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addFeedback({
    required String appointmentId,
    required int rating,
    String? comment,
  }) {
    _notifications.insert(
      0,
      PatientNotification(
        title: 'Thank you for your feedback',
        message: 'Your $rating-star rating has been submitted.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markNotificationsRead() {
    for (final notification in _notifications) {
      notification.read = true;
    }
    notifyListeners();
  }

  void completeAppointment(String id) {
    final appointment = _find(id);
    if (appointment == null) return;
    appointment.status = PatientAppointmentStatus.completed;
    notifyListeners();
  }

  PatientAppointment? _find(String id) {
    for (final appointment in _appointments) {
      if (appointment.id == id) return appointment;
    }
    return null;
  }
}

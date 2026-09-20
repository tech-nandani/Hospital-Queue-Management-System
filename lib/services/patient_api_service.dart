import 'dart:convert';

import 'package:http/http.dart' as http;

class PatientApiService {
  PatientApiService._();

  static final PatientApiService instance = PatientApiService._();

  // Android emulator uses 10.0.2.2; web and desktop use localhost.
  static const String baseUrl = 'http://127.0.0.1:8000/api/patient';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
    };
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      payload['date_of_birth'] = dateOfBirth;
    }
    if (gender != null && gender.isNotEmpty) {
      payload['gender'] = gender;
    }
    if (address != null && address.isNotEmpty) {
      payload['address'] = address;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    String? name,
    String? googleId,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
    };
    if (name != null && name.isNotEmpty) {
      payload['name'] = name;
    }
    if (googleId != null && googleId.isNotEmpty) {
      payload['google_id'] = googleId;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/google/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String mobile,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'mobile': mobile,
    };
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      payload['date_of_birth'] = dateOfBirth;
    }
    if (gender != null && gender.isNotEmpty) {
      payload['gender'] = gender;
    }
    if (address != null) {
      payload['address'] = address;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> getDepartments({String? token}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse('$baseUrl/departments/'), headers: headers);
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDoctors({String? token, int? departmentId}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url = departmentId != null
        ? '$baseUrl/doctors/?department=$departmentId'
        : '$baseUrl/doctors/';
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAppointments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> bookAppointment({
    required String token,
    required int doctorId,
    required String date,
    required String time,
    String? reason,
  }) async {
    final payload = <String, dynamic>{
      'doctor': doctorId,
      'appointment_date': date,
      'appointment_time': time,
    };
    if (reason != null && reason.trim().isNotEmpty) {
      payload['reason'] = reason.trim();
    }
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> cancelAppointment({
    required String token,
    required int appointmentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/cancel/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> rescheduleAppointment({
    required String token,
    required int appointmentId,
    required String date,
    required String time,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/reschedule/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'appointment_date': date,
        'appointment_time': time,
      }),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> chatWithAI({
    required String message,
    List<Map<String, dynamic>>? history,
    String? token,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final payload = <String, dynamic>{
      'message': message,
    };
    if (history != null) {
      payload['history'] = history;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat/'),
      headers: headers,
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  // ============================================================
  // STAFF & QUEUE API ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> staffLogin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/staff-login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> getStaffQueue({
    int? doctorId,
    String? department,
    String? status,
  }) async {
    final params = <String>[];
    if (doctorId != null) params.add('doctor=$doctorId');
    if (department != null && department.isNotEmpty) params.add('department=${Uri.encodeComponent(department)}');
    if (status != null && status.isNotEmpty) params.add('status=${Uri.encodeComponent(status)}');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';

    final response = await http.get(
      Uri.parse('$baseUrl/staff/queue/$query'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> generateStaffToken({
    required String patientName,
    required String patientMobile,
    required int doctorId,
    String? patientGender,
    int? patientAge,
    String? patientEmail,
    String? patientAddress,
    String? reason,
    String priority = 'Normal',
    String? appointmentDate,
    String? appointmentTime,
    bool isWalkIn = false,
  }) async {
    final payload = <String, dynamic>{
      'patient_name': patientName,
      'patient_mobile': patientMobile,
      'doctor_id': doctorId,
      'priority': priority,
      'is_walk_in': isWalkIn,
    };
    if (patientGender != null) payload['patient_gender'] = patientGender;
    if (patientAge != null) payload['patient_age'] = patientAge;
    if (patientEmail != null) payload['patient_email'] = patientEmail;
    if (patientAddress != null) payload['patient_address'] = patientAddress;
    if (reason != null) payload['reason'] = reason;
    if (appointmentDate != null) payload['appointment_date'] = appointmentDate;
    if (appointmentTime != null) payload['appointment_time'] = appointmentTime;

    final response = await http.post(
      Uri.parse('$baseUrl/staff/generate-token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> getDoctorAvailability() async {
    final response = await http.get(
      Uri.parse('$baseUrl/staff/doctor-availability/'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> toggleDoctorAvailability(int doctorId, bool isAvailable) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/doctors/$doctorId/toggle-availability/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_available': isAvailable}),
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> getStaffAppointments({
    int? doctorId,
    String? department,
    String? date,
    String? status,
  }) async {
    final params = <String>['for_staff=1'];
    if (doctorId != null) params.add('doctor=$doctorId');
    if (department != null && department.isNotEmpty) params.add('department=${Uri.encodeComponent(department)}');
    if (date != null && date.isNotEmpty) params.add('date=${Uri.encodeComponent(date)}');
    if (status != null && status.isNotEmpty) params.add('status=${Uri.encodeComponent(status)}');
    final query = '?${params.join('&')}';

    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$query'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = _decodeListOrMap(response);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> callAppointment(int appointmentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/call/'),
      headers: {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> startConsultation(int appointmentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/start_consultation/'),
      headers: {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> completeConsultation(
    int appointmentId, {
    String? diagnosis,
    String? symptoms,
    String? clinicalNotes,
    String? prescription,
    String? treatmentAdvice,
    String? followUpDate,
  }) async {
    final payload = <String, dynamic>{};
    if (diagnosis != null) payload['diagnosis'] = diagnosis;
    if (symptoms != null) payload['symptoms'] = symptoms;
    if (clinicalNotes != null) payload['clinical_notes'] = clinicalNotes;
    if (prescription != null) payload['prescription'] = prescription;
    if (treatmentAdvice != null) payload['treatment_advice'] = treatmentAdvice;
    if (followUpDate != null) payload['follow_up_date'] = followUpDate;

    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/complete_consultation/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> checkInAppointment(int appointmentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/check_in/'),
      headers: {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> markAppointmentNoShow(int appointmentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/no_show/'),
      headers: {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> staffCancelAppointment(int appointmentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/cancel/'),
      headers: {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  dynamic _decodeListOrMap(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Server returned ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      if (response.body.contains('<title>')) {
        final match =
            RegExp(r'<title>(.*?)</title>', dotAll: true).firstMatch(response.body);
        if (match != null) {
          final cleanTitle = match.group(1)!.trim();
          throw Exception(cleanTitle);
        }
      }
      throw Exception(
          'Server returned an error (${response.statusCode}). Please try again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          throw Exception(data['detail'].toString());
        }
        final messages = <String>[];
        data.forEach((key, val) {
          if (val is List) {
            messages.add(val.join(', '));
          } else {
            messages.add(val.toString());
          }
        });
        if (messages.isNotEmpty) {
          throw Exception(messages.join(' '));
        }
        throw Exception(data.toString());
      }
      throw Exception('Request failed with status ${response.statusCode}');
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from server');
    }
    return data;
  }
}

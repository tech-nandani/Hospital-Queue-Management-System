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

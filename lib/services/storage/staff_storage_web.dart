// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

List<Map<String, dynamic>> loadApplicationsImpl() {
  try {
    final raw = html.window.localStorage['careflow_staff_applications'];
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  } catch (_) {}
  return [];
}

void saveApplicationsImpl(List<Map<String, dynamic>> applications) {
  try {
    html.window.localStorage['careflow_staff_applications'] =
        jsonEncode(applications);
  } catch (_) {}
}

Map<String, String?> loadRememberedEmailsImpl() {
  try {
    return {
      'rememberedEmail': html.window.localStorage['careflow_remembered_email'],
      'rememberedDoctorEmail':
          html.window.localStorage['careflow_remembered_doctor_email'],
      'rememberedReceptionistEmail':
          html.window.localStorage['careflow_remembered_receptionist_email'],
    };
  } catch (_) {
    return {};
  }
}

void saveRememberedEmailsImpl(Map<String, String?> emails) {
  try {
    if (emails['rememberedEmail'] != null) {
      html.window.localStorage['careflow_remembered_email'] =
          emails['rememberedEmail']!;
    }
    if (emails['rememberedDoctorEmail'] != null) {
      html.window.localStorage['careflow_remembered_doctor_email'] =
          emails['rememberedDoctorEmail']!;
    }
    if (emails['rememberedReceptionistEmail'] != null) {
      html.window.localStorage['careflow_remembered_receptionist_email'] =
          emails['rememberedReceptionistEmail']!;
    }
  } catch (_) {}
}

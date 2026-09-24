import 'dart:convert';

final Map<String, String> _memStorage = {};

List<Map<String, dynamic>> loadApplicationsImpl() {
  final raw = _memStorage['careflow_staff_applications'];
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  } catch (_) {}
  return [];
}

void saveApplicationsImpl(List<Map<String, dynamic>> applications) {
  try {
    _memStorage['careflow_staff_applications'] = jsonEncode(applications);
  } catch (_) {}
}

Map<String, String?> loadRememberedEmailsImpl() {
  return {
    'rememberedEmail': _memStorage['careflow_remembered_email'],
    'rememberedDoctorEmail': _memStorage['careflow_remembered_doctor_email'],
    'rememberedReceptionistEmail':
        _memStorage['careflow_remembered_receptionist_email'],
  };
}

void saveRememberedEmailsImpl(Map<String, String?> emails) {
  if (emails.containsKey('rememberedEmail')) {
    _memStorage['careflow_remembered_email'] = emails['rememberedEmail'] ?? '';
  }
  if (emails.containsKey('rememberedDoctorEmail')) {
    _memStorage['careflow_remembered_doctor_email'] =
        emails['rememberedDoctorEmail'] ?? '';
  }
  if (emails.containsKey('rememberedReceptionistEmail')) {
    _memStorage['careflow_remembered_receptionist_email'] =
        emails['rememberedReceptionistEmail'] ?? '';
  }
}

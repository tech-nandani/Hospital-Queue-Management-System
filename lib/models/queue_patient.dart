class QueuePatient {
  final String id;
  final int token;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String reason;
  final String priority; // Normal, High, Emergency
  final String time;
  final String department;
  final String doctorName;
  final int? doctorId;
  final bool isWalkIn;

  String status; // Waiting, Calling, In Consultation, Completed, Cancelled, No Show, Checked-in
  String? diagnosis;
  String? clinicalNotes;
  String? prescription;
  String? treatmentAdvice;
  String? followUpDate;

  QueuePatient({
    required this.id,
    required this.token,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.reason,
    required this.priority,
    required this.time,
    this.department = 'General Medicine',
    this.doctorName = 'Dr. Priya Sharma',
    this.doctorId,
    this.isWalkIn = false,
    this.status = 'Waiting',
    this.diagnosis,
    this.clinicalNotes,
    this.prescription,
    this.treatmentAdvice,
    this.followUpDate,
  });

  factory QueuePatient.fromJson(Map<String, dynamic> json) {
    final docDetails = json['doctor_details'] as Map<String, dynamic>?;
    final doctorName = docDetails?['name'] as String? ?? (json['doctor_name'] as String? ?? 'Doctor');
    final deptName = json['department'] as String? ??
        (docDetails?['department'] is Map ? (docDetails!['department'] as Map)['name'] as String? : null) ??
        'General Medicine';

    // Map backend status to user friendly display
    final rawStatus = (json['status'] as String? ?? 'waiting').toLowerCase();
    String mappedStatus;
    if (rawStatus == 'in_consultation') {
      mappedStatus = 'In Consultation';
    } else if (rawStatus == 'calling') {
      mappedStatus = 'Calling';
    } else if (rawStatus == 'completed') {
      mappedStatus = 'Completed';
    } else if (rawStatus == 'cancelled') {
      mappedStatus = 'Cancelled';
    } else if (rawStatus == 'no_show') {
      mappedStatus = 'No Show';
    } else if (rawStatus == 'checked_in') {
      mappedStatus = 'Checked-in';
    } else {
      mappedStatus = 'Waiting';
    }

    final rawPriority = json['priority'] as String? ?? 'Normal';
    String mappedPriority = 'Normal';
    if (rawPriority.toLowerCase() == 'emergency') {
      mappedPriority = 'Emergency';
    } else if (rawPriority.toLowerCase() == 'high') {
      mappedPriority = 'High';
    }

    int parsedAge = 30;
    final ageVal = json['patient_age'];
    if (ageVal is num) {
      parsedAge = ageVal.toInt();
    } else if (ageVal is String) {
      parsedAge = int.tryParse(ageVal) ?? 30;
    }

    return QueuePatient(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      token: (json['queue_token'] as num?)?.toInt() ?? 1,
      name: json['patient_name'] as String? ?? 'Patient',
      age: parsedAge,
      gender: json['patient_gender'] as String? ?? 'Other',
      phone: json['patient_mobile'] as String? ?? '',
      email: json['patient_email'] as String? ?? '',
      address: json['patient_address'] as String? ?? '',
      reason: json['reason'] as String? ?? 'General Consultation',
      priority: mappedPriority,
      time: json['appointment_time'] as String? ?? '10:00 AM',
      department: deptName,
      doctorName: doctorName,
      doctorId: (json['doctor'] as num?)?.toInt() ?? (docDetails?['id'] as num?)?.toInt(),
      isWalkIn: json['is_walk_in'] as bool? ?? false,
      status: mappedStatus,
      diagnosis: json['diagnosis'] as String?,
      clinicalNotes: json['clinical_notes'] as String?,
      prescription: json['prescription'] as String?,
      treatmentAdvice: json['treatment_advice'] as String?,
      followUpDate: json['follow_up_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'queue_token': token,
    'patient_name': name,
    'patient_age': age,
    'patient_gender': gender,
    'patient_mobile': phone,
    'patient_email': email,
    'patient_address': address,
    'reason': reason,
    'priority': priority,
    'appointment_time': time,
    'department': department,
    'doctor_name': doctorName,
    'doctor': doctorId,
    'status': status,
    'diagnosis': diagnosis,
    'clinical_notes': clinicalNotes,
    'prescription': prescription,
    'treatment_advice': treatmentAdvice,
    'follow_up_date': followUpDate,
  };
}
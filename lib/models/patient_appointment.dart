enum PatientAppointmentStatus { upcoming, waiting, completed, cancelled }

class PatientAppointment {
  final String id;
  final String department;
  final String doctor;
  final String doctorQualification;
  final String hospitalName;
  final String reason;
  DateTime date;
  String time;
  final int queueNumber;
  final int estimatedWaitMinutes;
  PatientAppointmentStatus status;

  PatientAppointment({
    required this.id,
    required this.department,
    required this.doctor,
    this.doctorQualification = 'MBBS, MD',
    this.hospitalName = 'City Care Hospital, Lucknow',
    this.reason = '',
    required this.date,
    required this.time,
    required this.queueNumber,
    required this.estimatedWaitMinutes,
    this.status = PatientAppointmentStatus.upcoming,
  });

  factory PatientAppointment.fromJson(Map<String, dynamic> json) {
    final doctorDetails = json['doctor_details'] as Map<String, dynamic>?;
    final doctorName = doctorDetails?['name'] as String? ?? 'Doctor';
    final doctorQual = doctorDetails?['qualification'] as String? ?? 'MBBS, MD';
    final deptName = json['department'] as String? ??
        (doctorDetails?['department'] is Map
            ? (doctorDetails!['department'] as Map)['name'] as String?
            : null) ??
        'General Medicine';

    final rawStatus = (json['status'] as String? ?? 'upcoming').toLowerCase();
    PatientAppointmentStatus mappedStatus;
    if (rawStatus == 'cancelled' || rawStatus == 'no_show') {
      mappedStatus = PatientAppointmentStatus.cancelled;
    } else if (rawStatus == 'completed') {
      mappedStatus = PatientAppointmentStatus.completed;
    } else if (rawStatus == 'waiting' || rawStatus == 'in_consultation') {
      mappedStatus = PatientAppointmentStatus.waiting;
    } else {
      mappedStatus = PatientAppointmentStatus.upcoming;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['appointment_date'] as String);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return PatientAppointment(
      id: json['id']?.toString() ?? '',
      department: deptName,
      doctor: doctorName,
      doctorQualification: doctorQual,
      hospitalName: json['hospital_name'] as String? ?? 'City Care Hospital, Lucknow',
      reason: json['reason'] as String? ?? '',
      date: parsedDate,
      time: json['appointment_time'] as String? ?? '09:00 AM',
      queueNumber: (json['queue_token'] as num?)?.toInt() ?? 1,
      estimatedWaitMinutes: (json['estimated_wait_minutes'] as num?)?.toInt() ?? 15,
      status: mappedStatus,
    );
  }
}

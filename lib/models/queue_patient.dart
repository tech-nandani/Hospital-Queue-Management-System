class QueuePatient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String reason;
  final String priority;
  final int token;
  final String time;

  String status;

  QueuePatient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.reason,
    required this.priority,
    required this.token,
    required this.time,
    this.status = 'Waiting',
  });
}
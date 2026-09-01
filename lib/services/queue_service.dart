import 'package:flutter/foundation.dart';
import '../models/queue_patient.dart';

class QueueService extends ChangeNotifier {
  QueueService._();

  static final QueueService instance = QueueService._();

  final List<QueuePatient> _patients = [];

  List<QueuePatient> get patients =>
      List.unmodifiable(_patients);

  // ============================================================
  // COUNTS
  // ============================================================

  int get totalPatients => _patients.length;

  int get waitingCount =>
      _patients.where((p) => p.status == 'Waiting').length;

  int get consultationCount =>
      _patients
          .where((p) => p.status == 'In Consultation')
          .length;

  int get completedCount =>
      _patients.where((p) => p.status == 'Completed').length;

  int get noShowCount =>
      _patients.where((p) => p.status == 'No Show').length;

  int get queueCount =>
      _patients
          .where(
            (p) =>
        p.status == 'Waiting' ||
            p.status == 'In Consultation',
      )
          .length;

  int get priorityCount =>
      _patients
          .where(
            (p) =>
        p.priority == 'High' &&
            p.status != 'Completed' &&
            p.status != 'No Show',
      )
          .length;

  // ============================================================
  // ADD PATIENT
  // ============================================================

  QueuePatient addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    required String reason,
    required String priority,
  }) {
    final int nextToken =
    _patients.isEmpty
        ? 1
        : _patients
        .map((p) => p.token)
        .reduce((a, b) => a > b ? a : b) +
        1;

    final patient = QueuePatient(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      reason: reason,
      priority: priority,
      token: nextToken,
      time: _currentTime(),
    );

    _patients.add(patient);

    notifyListeners();

    return patient;
  }

  // ============================================================
  // CALL NEXT
  // ============================================================

  QueuePatient? callNextPatient() {
    QueuePatient? next;

    for (final patient in _patients) {
      if (patient.status == 'Waiting') {
        if (next == null) {
          next = patient;
        } else if (patient.priority == 'High' &&
            next.priority != 'High') {
          next = patient;
        } else if (patient.priority == next.priority &&
            patient.token < next.token) {
          next = patient;
        }
      }
    }

    if (next == null) {
      return null;
    }

    next.status = 'In Consultation';

    notifyListeners();

    return next;
  }

  // ============================================================
  // COMPLETE
  // ============================================================

  void completePatient(String id) {
    final index =
    _patients.indexWhere((p) => p.id == id);

    if (index == -1) return;

    _patients[index].status = 'Completed';

    notifyListeners();
  }

  // ============================================================
  // NO SHOW
  // ============================================================

  void markNoShow(String id) {
    final index =
    _patients.indexWhere((p) => p.id == id);

    if (index == -1) return;

    _patients[index].status = 'No Show';

    notifyListeners();
  }

  // ============================================================
  // TIME
  // ============================================================

  String _currentTime() {
    final now = DateTime.now();

    final hour =
    now.hour > 12 ? now.hour - 12 : now.hour;

    final displayHour = hour == 0 ? 12 : hour;

    final minute =
    now.minute.toString().padLeft(2, '0');

    final period =
    now.hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:$minute $period';
  }
}
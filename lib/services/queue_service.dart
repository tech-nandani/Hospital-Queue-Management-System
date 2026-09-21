import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/queue_patient.dart';
import 'patient_api_service.dart';

class QueueService extends ChangeNotifier {
  QueueService._() {
    // Initial fetch from backend
    fetchQueue();
  }

  static final QueueService instance = QueueService._();

  final List<QueuePatient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<QueuePatient> get patients => List.unmodifiable(_patients);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================================================
  // COUNTS & METRICS
  // ============================================================

  int get totalPatients => _patients.length;

  int get waitingCount => _patients.where((p) => p.status == 'Waiting' || p.status == 'Checked-in').length;

  int get callingCount => _patients.where((p) => p.status == 'Calling').length;

  int get consultationCount =>
      _patients.where((p) => p.status == 'In Consultation').length;

  int get completedCount =>
      _patients.where((p) => p.status == 'Completed').length;

  int get noShowCount => _patients.where((p) => p.status == 'No Show').length;

  int get queueCount => _patients
      .where((p) => p.status == 'Waiting' || p.status == 'Calling' || p.status == 'In Consultation' || p.status == 'Checked-in')
      .length;

  int get priorityCount => _patients
      .where(
        (p) =>
            (p.priority == 'High' || p.priority == 'Emergency') &&
            p.status != 'Completed' &&
            p.status != 'Cancelled' &&
            p.status != 'No Show',
      )
      .length;

  int get emergencyCount => _patients
      .where(
        (p) =>
            p.priority == 'Emergency' &&
            p.status != 'Completed' &&
            p.status != 'Cancelled' &&
            p.status != 'No Show',
      )
      .length;

  int get averageWaitingMinutes {
    final waiting = waitingCount;
    return waiting == 0 ? 0 : waiting * 10;
  }

  // ============================================================
  // BACKEND SYNCHRONIZATION
  // ============================================================

  Future<void> fetchQueue({int? doctorId, String? department}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await PatientApiService.instance.getStaffQueue(
        doctorId: doctorId,
        department: department,
      );

      _patients.clear();
      for (final item in data) {
        try {
          _patients.add(QueuePatient.fromJson(item));
        } catch (e) {
          debugPrint('Error parsing queue item: $e');
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('Queue fetch error: $e');
      notifyListeners();
    }
  }

  // ============================================================
  // ADD PATIENT / GENERATE TOKEN
  // ============================================================

  Future<QueuePatient> addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    String email = '',
    String address = '',
    required String reason,
    required String priority,
    required int doctorId,
    String? appointmentDate,
    String? appointmentTime,
    bool isWalkIn = false,
  }) async {
    try {
      final res = await PatientApiService.instance.generateStaffToken(
        patientName: name,
        patientMobile: phone,
        patientAge: age,
        patientGender: gender,
        patientEmail: email,
        patientAddress: address,
        reason: reason,
        priority: priority,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        isWalkIn: isWalkIn,
      );

      final newPatient = QueuePatient.fromJson(res);
      _patients.removeWhere((p) => p.id == newPatient.id);
      _patients.add(newPatient);
      notifyListeners();
      return newPatient;
    } catch (e) {
      debugPrint('Backend token generation error, falling back locally: $e');
      final int nextToken = _patients.isEmpty
          ? 1
          : _patients.map((p) => p.token).reduce((a, b) => a > b ? a : b) + 1;

      final patient = QueuePatient(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        email: email,
        address: address,
        reason: reason,
        priority: priority,
        token: nextToken,
        time: _currentTime(),
        doctorId: doctorId,
        isWalkIn: isWalkIn,
        status: 'Waiting',
      );
      _patients.add(patient);
      notifyListeners();
      return patient;
    }
  }

  // ============================================================
  // CALL NEXT PATIENT (DOCTOR)
  // ============================================================

  QueuePatient? callNextPatient({int? doctorId}) {
    QueuePatient? next;

    final pool = _patients.where((p) {
      final matchDoc = doctorId == null || p.doctorId == doctorId;
      final matchStatus = p.status == 'Waiting' || p.status == 'Checked-in';
      return matchDoc && matchStatus;
    }).toList();

    for (final patient in pool) {
      if (next == null) {
        next = patient;
      } else if (patient.priority == 'Emergency' && next.priority != 'Emergency') {
        next = patient;
      } else if (patient.priority == 'High' && (next.priority != 'High' && next.priority != 'Emergency')) {
        next = patient;
      } else if (patient.priority == next.priority && patient.token < next.token) {
        next = patient;
      }
    }

    if (next == null) {
      return null;
    }

    final id = next.id;
    next.status = 'Calling';
    notifyListeners();

    final aptId = int.tryParse(id);
    if (aptId != null) {
      PatientApiService.instance.callAppointment(aptId).catchError((e) {
        debugPrint('Call appointment backend error: $e');
        return <String, dynamic>{};
      });
    }

    return next;
  }

  Future<QueuePatient?> callNextPatientAsync({int? doctorId}) async {
    return callNextPatient(doctorId: doctorId);
  }

  // ============================================================
  // START CONSULTATION (DOCTOR)
  // ============================================================

  Future<void> startConsultation(String id) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'In Consultation';
      notifyListeners();
    }

    final aptId = int.tryParse(id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.startConsultation(aptId);
      } catch (e) {
        debugPrint('Start consultation backend error: $e');
      }
    }
  }

  // ============================================================
  // COMPLETE CONSULTATION (DOCTOR)
  // ============================================================

  Future<void> completePatient(
    String id, {
    String? diagnosis,
    String? symptoms,
    String? clinicalNotes,
    String? prescription,
    String? treatmentAdvice,
    String? followUpDate,
  }) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'Completed';
      if (diagnosis != null) _patients[index].diagnosis = diagnosis;
      if (clinicalNotes != null) _patients[index].clinicalNotes = clinicalNotes;
      if (prescription != null) _patients[index].prescription = prescription;
      if (treatmentAdvice != null) _patients[index].treatmentAdvice = treatmentAdvice;
      if (followUpDate != null) _patients[index].followUpDate = followUpDate;
      notifyListeners();
    }

    final aptId = int.tryParse(id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.completeConsultation(
          aptId,
          diagnosis: diagnosis,
          symptoms: symptoms,
          clinicalNotes: clinicalNotes,
          prescription: prescription,
          treatmentAdvice: treatmentAdvice,
          followUpDate: followUpDate,
        );
      } catch (e) {
        debugPrint('Complete consultation backend error: $e');
      }
    }
  }

  // ============================================================
  // CHECK-IN (RECEPTIONIST)
  // ============================================================

  Future<void> checkInPatient(String id) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'Checked-in';
      notifyListeners();
    }

    final aptId = int.tryParse(id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.checkInAppointment(aptId);
      } catch (e) {
        debugPrint('Check-in backend error: $e');
      }
    }
  }

  // ============================================================
  // NO SHOW & CANCEL
  // ============================================================

  Future<void> markNoShow(String id) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'No Show';
      notifyListeners();
    }

    final aptId = int.tryParse(id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.markAppointmentNoShow(aptId);
      } catch (e) {
        debugPrint('No-show backend error: $e');
      }
    }
  }

  Future<void> cancelPatient(String id) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'Cancelled';
      notifyListeners();
    }

    final aptId = int.tryParse(id);
    if (aptId != null) {
      try {
        await PatientApiService.instance.staffCancelAppointment(aptId);
      } catch (e) {
        debugPrint('Cancel backend error: $e');
      }
    }
  }

  void skipPatient(String id) => markNoShow(id);

  void recallPatient(String id) {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index].status = 'Waiting';
      notifyListeners();
    }
  }

  void updateStatus(String id, String status) {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _patients[index].status = status;
    notifyListeners();

    final aptId = int.tryParse(id);
    if (aptId != null) {
      if (status == 'In Consultation') {
        startConsultation(id);
      } else if (status == 'Completed') {
        completePatient(id);
      } else if (status == 'No Show') {
        markNoShow(id);
      } else if (status == 'Checked-in') {
        checkInPatient(id);
      } else if (status == 'Cancelled') {
        cancelPatient(id);
      }
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  @visibleForTesting
  void setPatientsForTesting(List<QueuePatient> list) {
    _patients.clear();
    _patients.addAll(list);
    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _patients.clear();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class DoctorService extends ChangeNotifier {
  DoctorService._();

  static final DoctorService instance = DoctorService._();

  String availability = 'Available';
  final List<String> workingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  String consultationHours = '09:00 AM - 05:00 PM';
  String breakHours = '01:00 PM - 02:00 PM';
  String followUpDate = '';
  String symptoms = '';
  String diagnosis = '';
  String clinicalNotes = '';
  String treatmentAdvice = '';
  String medicineName = '';
  String dosage = '';
  String frequency = '';
  String duration = '';
  String instructions = '';

  void setAvailability(String value) {
    availability = value;
    notifyListeners();
  }

  void saveConsultation({
    required String symptoms,
    required String diagnosis,
    required String notes,
    required String advice,
    String? followUpDate,
  }) {
    this.symptoms = symptoms;
    this.diagnosis = diagnosis;
    clinicalNotes = notes;
    treatmentAdvice = advice;
    this.followUpDate = followUpDate ?? '';
    notifyListeners();
  }

  void savePrescription({
    required String medicineName,
    required String dosage,
    required String frequency,
    required String duration,
    required String instructions,
  }) {
    this.medicineName = medicineName;
    this.dosage = dosage;
    this.frequency = frequency;
    this.duration = duration;
    this.instructions = instructions;
    notifyListeners();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/utils/appointment_time_utils.dart';

void main() {
  group('Appointment Time Slot Verification Tests', () {
    const slots = AppointmentTimeUtils.defaultTimeSlots;

    test('Future date slots are never considered in the past', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      for (final slot in slots) {
        expect(AppointmentTimeUtils.isSlotInPast(slot, tomorrow), isFalse,
            reason: '$slot on a future date should be available');
      }
      final defaultSlot = AppointmentTimeUtils.getDefaultSlotForDate(tomorrow, slots);
      expect(defaultSlot, equals('09:00 AM'));
    });

    test('Past date slots are always considered in the past', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      for (final slot in slots) {
        expect(AppointmentTimeUtils.isSlotInPast(slot, yesterday), isTrue,
            reason: '$slot on a past date should be considered in the past');
      }
      final defaultSlot = AppointmentTimeUtils.getDefaultSlotForDate(yesterday, slots);
      expect(defaultSlot, isNull);
    });

    test('parseSlotDateTime parses 12-hour AM/PM correctly', () {
      final baseDate = DateTime(2026, 9, 23);
      final dt9am = AppointmentTimeUtils.parseSlotDateTime('09:30 AM', baseDate);
      expect(dt9am, equals(DateTime(2026, 9, 23, 9, 30)));

      final dt12pm = AppointmentTimeUtils.parseSlotDateTime('12:00 PM', baseDate);
      expect(dt12pm, equals(DateTime(2026, 9, 23, 12, 0)));

      final dt2pm = AppointmentTimeUtils.parseSlotDateTime('02:30 PM', baseDate);
      expect(dt2pm, equals(DateTime(2026, 9, 23, 14, 30)));

      final dt5pm = AppointmentTimeUtils.parseSlotDateTime('05:30 PM', baseDate);
      expect(dt5pm, equals(DateTime(2026, 9, 23, 17, 30)));
    });

    test('Today past slots vs upcoming slots behave accurately', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // A slot definitively in the past today
      final pastHour = now.hour > 0 ? (now.hour - 1) : 0;
      if (pastHour >= 9) {
        final isPm = pastHour >= 12;
        final displayHour = isPm ? (pastHour > 12 ? pastHour - 12 : 12) : (pastHour == 0 ? 12 : pastHour);
        final hourStr = displayHour.toString().padLeft(2, '0');
        final testSlot = '$hourStr:00 ${isPm ? 'PM' : 'AM'}';
        expect(AppointmentTimeUtils.isSlotInPast(testSlot, today), isTrue);
      }

      final futureDt = DateTime(now.year, now.month, now.day + 1);
      expect(AppointmentTimeUtils.isSlotInPast('05:00 PM', futureDt), isFalse);
    });
  });
}

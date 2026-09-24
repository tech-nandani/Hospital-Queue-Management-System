class AppointmentTimeUtils {
  static const List<String> defaultTimeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
  ];

  static DateTime? parseSlotDateTime(String slot, DateTime date) {
    try {
      final parts = slot.trim().split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static bool isSlotInPast(String slot, DateTime date) {
    final now = DateTime.now();
    final targetDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (targetDate.isBefore(today)) return true;
    if (targetDate.isAfter(today)) return false;

    final slotDt = parseSlotDateTime(slot, date);
    if (slotDt == null) return false;
    return slotDt.isBefore(now);
  }

  static String? getDefaultSlotForDate(DateTime date, [List<String>? slots]) {
    final available = slots ?? defaultTimeSlots;
    final now = DateTime.now();
    final targetDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (targetDate.isAfter(today)) {
      return available.isNotEmpty ? available.first : null;
    }

    for (final slot in available) {
      if (!isSlotInPast(slot, date)) {
        return slot;
      }
    }
    return null;
  }
}

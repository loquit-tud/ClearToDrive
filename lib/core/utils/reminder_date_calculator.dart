import 'package:cleartodrive/domain/entities/reminder_policy.dart';

class ReminderDateCalculator {
  const ReminderDateCalculator._();

  /// Default fire time: 09:00 local on the reminder day.
  static const defaultReminderHour = 9;

  /// Returns sorted reminder trigger dates for a document expiry.
  static List<ReminderTrigger> calculateTriggers({
    required DateTime expiryDate,
    required ReminderPolicy policy,
    DateTime? referenceDate,
    int reminderHour = defaultReminderHour,
  }) {
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final triggers = <ReminderTrigger>[];

    for (final offset in policy.sortedOffsets) {
      final triggerDay = expiry.subtract(Duration(days: offset));
      final triggerAt = DateTime(
        triggerDay.year,
        triggerDay.month,
        triggerDay.day,
        reminderHour,
      );
      final now = referenceDate ?? DateTime.now();
      if (triggerAt.isAfter(now) || _isSameDay(triggerAt, now)) {
        triggers.add(ReminderTrigger(offsetDays: offset, triggerAt: triggerAt));
      }
    }

    triggers.sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
    return triggers;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class ReminderTrigger {
  const ReminderTrigger({
    required this.offsetDays,
    required this.triggerAt,
  });

  final int offsetDays;
  final DateTime triggerAt;
}

import 'package:cleartodrive/domain/enums/document_enums.dart';

class ExpiryStatusCalculator {
  const ExpiryStatusCalculator._();

  /// [expiringSoonThresholdDays] defaults to 7 per PRD urgency colors.
  static ExpiryStatus calculate(
    DateTime expiryDate, {
    DateTime? referenceDate,
    int expiringSoonThresholdDays = 7,
  }) {
    final today = _dateOnly(referenceDate ?? DateTime.now());
    final expiry = _dateOnly(expiryDate);
    final daysRemaining = expiry.difference(today).inDays;

    if (daysRemaining < 0) return ExpiryStatus.expired;
    if (daysRemaining <= expiringSoonThresholdDays) {
      return ExpiryStatus.expiringSoon;
    }
    return ExpiryStatus.valid;
  }

  static int daysUntilExpiry(DateTime expiryDate, {DateTime? referenceDate}) {
    final today = _dateOnly(referenceDate ?? DateTime.now());
    final expiry = _dateOnly(expiryDate);
    return expiry.difference(today).inDays;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

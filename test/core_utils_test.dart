import 'package:cleartodrive/core/utils/document_type_labels.dart';
import 'package:cleartodrive/core/utils/expiry_status_calculator.dart';
import 'package:cleartodrive/core/utils/reminder_date_calculator.dart';
import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LicensePlateValidator', () {
    test('normalize uppercases and collapses spaces', () {
      expect(
        LicensePlateValidator.normalize('  b  123 abc  '),
        'B 123 ABC',
      );
    });

    test('looksLikeRomanianPlate accepts common format', () {
      expect(
        LicensePlateValidator.looksLikeRomanianPlate('B 123 ABC'),
        isTrue,
      );
    });
  });

  group('ExpiryStatusCalculator', () {
    test('returns expired when date is in the past', () {
      final status = ExpiryStatusCalculator.calculate(
        DateTime(2020, 1, 1),
        referenceDate: DateTime(2026, 5, 27),
      );
      expect(status, ExpiryStatus.expired);
    });

    test('returns expiringSoon within 7 days', () {
      final status = ExpiryStatusCalculator.calculate(
        DateTime(2026, 6, 1),
        referenceDate: DateTime(2026, 5, 27),
      );
      expect(status, ExpiryStatus.expiringSoon);
    });

    test('returns valid when more than 7 days remain', () {
      final status = ExpiryStatusCalculator.calculate(
        DateTime(2026, 8, 1),
        referenceDate: DateTime(2026, 5, 27),
      );
      expect(status, ExpiryStatus.valid);
    });

    test('daysUntilExpiry matches expected countdown (93 days)', () {
      final days = ExpiryStatusCalculator.daysUntilExpiry(
        DateTime(2026, 8, 29),
        referenceDate: DateTime(2026, 5, 28),
      );
      expect(days, 93);
    });
  });

  group('ReminderDateCalculator', () {
    test('calculates default offsets before expiry', () {
      final expiry = DateTime(2026, 12, 31);
      final reference = DateTime(2026, 5, 27, 10);
      final triggers = ReminderDateCalculator.calculateTriggers(
        expiryDate: expiry,
        policy: ReminderPolicy.defaults,
        referenceDate: reference,
      );

      expect(triggers.map((t) => t.offsetDays).toSet(), {30, 14, 7, 1});
      expect(triggers.first.offsetDays, 30);
    });

    test('includes day-of when enabled', () {
      final expiry = DateTime(2026, 12, 31);
      final reference = DateTime(2026, 5, 27);
      final triggers = ReminderDateCalculator.calculateTriggers(
        expiryDate: expiry,
        policy: const ReminderPolicy(dayOf: true),
        referenceDate: reference,
      );

      expect(triggers.any((t) => t.offsetDays == 0), isTrue);
    });
  });

  group('DocumentTypeLabels', () {
    test('labelRo uses Rovinietă for rovinieta enum', () {
      expect(
        DocumentTypeLabels.labelRo(DocumentType.rovinieta),
        'Rovinietă',
      );
    });

    test('fromStorageKey parses rovinieta', () {
      expect(
        DocumentTypeLabels.fromStorageKey('rovinieta'),
        DocumentType.rovinieta,
      );
    });
  });
}

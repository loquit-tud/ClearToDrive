import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';

class DriftAppPreferencesRepository implements AppPreferencesRepository {
  DriftAppPreferencesRepository(this._db);

  final AppDatabase _db;

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyReminderOffsets = 'reminder_days_before'; // csv e.g. 30,14,7,1
  static const _keyReminderDayOf = 'reminder_day_of';

  @override
  Future<ReminderPolicy> getReminderPolicy() async {
    final offsetsCsv = await _getString(_keyReminderOffsets);
    final dayOf = await _getBool(_keyReminderDayOf) ?? false;

    final offsets = <int>{};
    if (offsetsCsv != null && offsetsCsv.trim().isNotEmpty) {
      for (final part in offsetsCsv.split(',')) {
        final parsed = int.tryParse(part.trim());
        if (parsed != null && parsed > 0) offsets.add(parsed);
      }
    }

    return ReminderPolicy(
      daysBefore: offsets.isEmpty ? ReminderPolicy.defaults.daysBefore : offsets,
      dayOf: dayOf,
    );
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return (await _getBool(_keyOnboardingComplete)) ?? false;
  }

  @override
  Future<void> setOnboardingComplete(bool value) async {
    await _setString(_keyOnboardingComplete, value ? '1' : '0');
  }

  @override
  Future<void> setReminderPolicy(ReminderPolicy policy) async {
    final offsets = policy.daysBefore.toList()..sort((a, b) => b.compareTo(a));
    await _setString(_keyReminderOffsets, offsets.join(','));
    await _setString(_keyReminderDayOf, policy.dayOf ? '1' : '0');
  }

  Future<String?> _getString(String key) async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<bool?> _getBool(String key) async {
    final v = await _getString(key);
    if (v == null) return null;
    return v == '1' || v.toLowerCase() == 'true';
  }

  Future<void> _setString(String key, String value) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }
}


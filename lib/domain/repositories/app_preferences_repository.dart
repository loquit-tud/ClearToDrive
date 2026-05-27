import 'package:cleartodrive/domain/entities/reminder_policy.dart';

abstract class AppPreferencesRepository {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete(bool value);
  Future<ReminderPolicy> getReminderPolicy();
  Future<void> setReminderPolicy(ReminderPolicy policy);
}

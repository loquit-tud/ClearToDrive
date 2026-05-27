import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';

class RescheduleAllRemindersUseCase {
  RescheduleAllRemindersUseCase(
    this._documentRepo,
    this._preferences,
    this._reminderService,
  );

  final DocumentRepository _documentRepo;
  final AppPreferencesRepository _preferences;
  final ReminderService _reminderService;

  /// Cancels + reschedules reminders for all saved documents using current policy.
  ///
  /// Idempotency is enforced by the ReminderService implementation.
  Future<int> execute() async {
    final ReminderPolicy policy = await _preferences.getReminderPolicy();
    final documents = await _documentRepo.getAll();
    for (final doc in documents) {
      await _reminderService.scheduleForDocument(doc, policy);
    }
    return documents.length;
  }
}


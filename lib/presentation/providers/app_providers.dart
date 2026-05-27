import 'package:cleartodrive/application/use_cases/confirm_document_use_case.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/application/use_cases/reschedule_all_reminders_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/application/use_cases/send_test_notification_use_case.dart';
import 'package:cleartodrive/di/injection.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final scanAndExtractUseCaseProvider = Provider<ScanAndExtractUseCase>(
  (ref) => ScanAndExtractUseCase(
    getIt<DocumentScannerService>(),
    getIt<DocumentFieldExtractor>(),
  ),
);

final confirmDocumentUseCaseProvider = Provider<ConfirmDocumentUseCase>(
  (ref) => ConfirmDocumentUseCase(
    getIt<VehicleRepository>(),
    getIt<DocumentRepository>(),
    getIt<ReminderService>(),
    getIt<AppPreferencesRepository>(),
    getIt<Uuid>(),
  ),
);

final listDocumentsUseCaseProvider = Provider<ListDocumentsUseCase>(
  (ref) => ListDocumentsUseCase(
    getIt<DocumentRepository>(),
    getIt<VehicleRepository>(),
  ),
);

final rescheduleAllRemindersUseCaseProvider =
    Provider<RescheduleAllRemindersUseCase>(
  (ref) => RescheduleAllRemindersUseCase(
    getIt<DocumentRepository>(),
    getIt<AppPreferencesRepository>(),
    getIt<ReminderService>(),
  ),
);

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>(
  (ref) => DeleteDocumentUseCase(
    getIt<DocumentRepository>(),
    getIt<ReminderService>(),
  ),
);

final getDocumentDetailUseCaseProvider = Provider<GetDocumentDetailUseCase>(
  (ref) => GetDocumentDetailUseCase(
    getIt<DocumentRepository>(),
    getIt<VehicleRepository>(),
    getIt<ReminderService>(),
  ),
);

final manualEntryDraftFactoryProvider = Provider<ManualEntryDraftFactory>(
  (ref) => ManualEntryDraftFactory(),
);

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => getIt<VehicleRepository>(),
);

final appPreferencesProvider = Provider<AppPreferencesRepository>(
  (ref) => getIt<AppPreferencesRepository>(),
);

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => getIt<NotificationScheduler>(),
);

final sendTestNotificationUseCaseProvider = Provider<SendTestNotificationUseCase>(
  (ref) => SendTestNotificationUseCase(getIt<NotificationScheduler>()),
);

final confirmDraftProvider = StateProvider<ConfirmDraft?>(
  (ref) => null,
);

final selectedDocumentTypeProvider = StateProvider<DocumentType?>(
  (ref) => null,
);

final documentsRefreshProvider = StateProvider<int>((ref) => 0);

final reminderPolicyProvider =
    StateNotifierProvider<ReminderPolicyNotifier, ReminderPolicy>(
  (ref) => ReminderPolicyNotifier(getIt<AppPreferencesRepository>()),
);

class ReminderPolicyNotifier extends StateNotifier<ReminderPolicy> {
  ReminderPolicyNotifier(this._prefs) : super(ReminderPolicy.defaults) {
    _load();
  }

  final AppPreferencesRepository _prefs;

  Future<void> _load() async {
    state = await _prefs.getReminderPolicy();
  }

  Future<bool> setDayOf(bool value) async {
    final next = state.copyWith(dayOf: value);
    if (!next.isValid) return false;
    state = next;
    await _prefs.setReminderPolicy(next);
    return true;
  }

  Future<bool> toggleOffset(int days, bool enabled) async {
    final offsets = Set<int>.from(state.daysBefore);
    if (enabled) {
      offsets.add(days);
    } else {
      offsets.remove(days);
    }
    final next = state.copyWith(daysBefore: offsets);
    if (!next.isValid) return false;
    state = next;
    await _prefs.setReminderPolicy(next);
    return true;
  }
}

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<bool>>(
  (ref) => OnboardingNotifier(getIt<AppPreferencesRepository>()),
);

class OnboardingNotifier extends StateNotifier<AsyncValue<bool>> {
  OnboardingNotifier(this._prefs) : super(const AsyncValue.loading()) {
    _load();
  }

  final AppPreferencesRepository _prefs;

  Future<void> _load() async {
    state = AsyncValue.data(await _prefs.isOnboardingComplete());
  }

  Future<void> complete() async {
    await _prefs.setOnboardingComplete(true);
    state = const AsyncValue.data(true);
  }
}

final notificationPermissionProvider =
    StateNotifierProvider<NotificationPermissionNotifier, AsyncValue<bool>>(
  (ref) => NotificationPermissionNotifier(getIt<NotificationScheduler>()),
);

class NotificationPermissionNotifier extends StateNotifier<AsyncValue<bool>> {
  NotificationPermissionNotifier(this._scheduler)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final NotificationScheduler _scheduler;

  Future<void> _load() async {
    try {
      await _scheduler.initialize();
      state = AsyncValue.data(await _scheduler.areNotificationsEnabled());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> request() async {
    try {
      await _scheduler.initialize();
      await _scheduler.requestPermissionIfNeeded();
      state = AsyncValue.data(await _scheduler.areNotificationsEnabled());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

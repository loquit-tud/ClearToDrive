import 'package:cleartodrive/application/use_cases/reschedule_all_reminders_use_case.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePrefs implements AppPreferencesRepository {
  FakePrefs(this.policy);
  final ReminderPolicy policy;

  @override
  Future<ReminderPolicy> getReminderPolicy() async => policy;

  @override
  Future<bool> isOnboardingComplete() async => true;

  @override
  Future<void> setOnboardingComplete(bool value) async {}

  @override
  Future<void> setReminderPolicy(ReminderPolicy policy) async {}
}

class FakeDocumentRepo implements DocumentRepository {
  FakeDocumentRepo(this.documents);
  final List<VehicleDocument> documents;

  @override
  Future<void> delete(String id) async {
    documents.removeWhere((d) => d.id == id);
  }

  @override
  Future<List<VehicleDocument>> getAll({String? vehicleId}) async => List.of(documents);

  @override
  Future<VehicleDocument?> getById(String id) async {
    for (final d in documents) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Future<VehicleDocument> save(VehicleDocument document) async {
    documents.removeWhere((d) => d.id == document.id);
    documents.add(document);
    return document;
  }
}

class TrackingReminderService implements ReminderService {
  final scheduled = <String>[];

  @override
  Future<void> cancelForDocument(String documentId) async {}

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId) async =>
      const [];

  @override
  Future<void> scheduleForDocument(
    VehicleDocument document,
    ReminderPolicy policy,
  ) async {
    scheduled.add('${document.id}:${policy.sortedOffsets.join(",")}');
  }
}

void main() {
  test('RescheduleAllRemindersUseCase reschedules all saved documents', () async {
    final docs = [
      VehicleDocument(
        id: 'd1',
        vehicleId: 'v1',
        type: DocumentType.rca,
        expiryDate: DateTime(2027, 1, 1),
        source: DocumentSource.manual,
        confirmedAt: DateTime(2026, 5, 27),
        createdAt: DateTime(2026, 5, 27),
        updatedAt: DateTime(2026, 5, 27),
      ),
      VehicleDocument(
        id: 'd2',
        vehicleId: 'v2',
        type: DocumentType.itp,
        expiryDate: DateTime(2027, 2, 2),
        source: DocumentSource.manual,
        confirmedAt: DateTime(2026, 5, 27),
        createdAt: DateTime(2026, 5, 27),
        updatedAt: DateTime(2026, 5, 27),
      ),
    ];

    final docRepo = FakeDocumentRepo(docs);
    final prefs = FakePrefs(const ReminderPolicy(daysBefore: {14, 7}, dayOf: true));
    final reminder = TrackingReminderService();

    final useCase = RescheduleAllRemindersUseCase(docRepo, prefs, reminder);
    final count = await useCase.execute();

    expect(count, 2);
    expect(reminder.scheduled, hasLength(2));
    expect(reminder.scheduled.first, startsWith('d1:'));
    expect(reminder.scheduled.last, startsWith('d2:'));
  });
}


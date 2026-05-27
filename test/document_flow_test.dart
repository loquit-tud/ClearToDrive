import 'package:cleartodrive/application/use_cases/confirm_document_use_case.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/data/repositories/drift_app_preferences_repository.dart';
import 'package:cleartodrive/data/repositories/drift_document_repository.dart';
import 'package:cleartodrive/data/repositories/drift_vehicle_repository.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

class TrackingReminderService implements ReminderService {
  final cancelCalls = <String>[];
  final scheduleCalls = <String>[];

  @override
  Future<void> cancelForDocument(String documentId) async {
    cancelCalls.add(documentId);
  }

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId) async =>
      const [];

  @override
  Future<void> scheduleForDocument(
    VehicleDocument document,
    ReminderPolicy policy,
  ) async {
    scheduleCalls.add(document.id);
  }
}

void main() {
  late AppDatabase db;
  late DriftVehicleRepository vehicleRepo;
  late DriftDocumentRepository docRepo;
  late DriftAppPreferencesRepository prefs;
  late TrackingReminderService reminder;
  late ConfirmDocumentUseCase confirmUseCase;
  late DeleteDocumentUseCase deleteUseCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleRepo = DriftVehicleRepository(db);
    docRepo = DriftDocumentRepository(db);
    prefs = DriftAppPreferencesRepository(db);
    reminder = TrackingReminderService();
    confirmUseCase = ConfirmDocumentUseCase(
      vehicleRepo,
      docRepo,
      reminder,
      prefs,
      const Uuid(),
    );
    deleteUseCase = DeleteDocumentUseCase(docRepo, reminder);
  });

  tearDown(() async {
    await db.close();
  });

  test('edit document flow: expiry change reschedules reminders', () async {
    final draft = ManualEntryDraftFactory().empty(type: DocumentType.itp).copyWith(
          licensePlate: 'B 123 ABC',
          expiryDate: DateTime(2027, 1, 1),
        );

    final saved = await confirmUseCase.save(draft);
    expect(reminder.scheduleCalls, [saved.id]);

    final editDraft = ConfirmDraft(
      documentId: saved.id,
      vehicleId: saved.vehicleId,
      type: saved.type,
      licensePlate: 'B 123 ABC',
      expiryDate: DateTime(2028, 6, 15),
      source: saved.source,
      imagePath: saved.imagePath,
    );

    await confirmUseCase.save(editDraft);
    expect(reminder.scheduleCalls, [saved.id, saved.id]);

    final updated = await docRepo.getById(saved.id);
    expect(updated!.expiryDate, DateTime(2028, 6, 15));
  });

  test('delete document flow: cancels reminders and removes document', () async {
    final draft = ManualEntryDraftFactory().empty(type: DocumentType.rca).copyWith(
          licensePlate: 'CJ 45 XYZ',
          expiryDate: DateTime(2027, 3, 1),
        );

    final saved = await confirmUseCase.save(draft);
    expect(await docRepo.getById(saved.id), isNotNull);

    await deleteUseCase.execute(saved.id);

    expect(reminder.cancelCalls, [saved.id]);
    expect(await docRepo.getById(saved.id), isNull);

    final listUseCase = ListDocumentsUseCase(docRepo, vehicleRepo);
    expect(await listUseCase.execute(), isEmpty);
  });
}

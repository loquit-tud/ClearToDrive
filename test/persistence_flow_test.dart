import 'package:cleartodrive/application/use_cases/confirm_document_use_case.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/data/repositories/drift_app_preferences_repository.dart';
import 'package:cleartodrive/data/repositories/drift_document_repository.dart';
import 'package:cleartodrive/data/repositories/drift_reminder_schedule_repository.dart';
import 'package:cleartodrive/data/repositories/drift_vehicle_repository.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';

class FakeReminderService implements ReminderService {
  final calls = <String>[];
  @override
  Future<void> cancelForDocument(String documentId) async {
    calls.add('cancel:$documentId');
  }

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId) async =>
      const [];

  @override
  Future<void> scheduleForDocument(VehicleDocument document, ReminderPolicy policy) async {
    calls.add('schedule:${document.id}');
  }
}

void main() {
  test('Drift persistence: save → load survives new repository instance', () async {
    final executor = NativeDatabase.memory();
    final db = AppDatabase.forTesting(executor);

    final vehicleRepo = DriftVehicleRepository(db);
    final docRepo = DriftDocumentRepository(db);
    final schedulesRepo = DriftReminderScheduleRepository(db);
    final prefs = DriftAppPreferencesRepository(db);
    final reminder = FakeReminderService();

    final confirmUseCase = ConfirmDocumentUseCase(
      vehicleRepo,
      docRepo,
      reminder,
      prefs,
      const Uuid(),
    );

    final draft = ManualEntryDraftFactory().empty(type: DocumentType.rca).copyWith(
          licensePlate: 'B 123 ABC',
          expiryDate: DateTime(2027, 1, 1),
        );

    final saved = await confirmUseCase.save(draft);
    expect(saved.id, isNotEmpty);
    expect(reminder.calls.where((c) => c.startsWith('schedule:')).length, 1);

    // New repo instances, same underlying DB.
    final docRepo2 = DriftDocumentRepository(db);
    final vehicleRepo2 = DriftVehicleRepository(db);
    final listUseCase = ListDocumentsUseCase(docRepo2, vehicleRepo2);
    final dashboard = await listUseCase.execute();
    expect(dashboard, hasLength(1));
    expect(dashboard.first.plate, 'B 123 ABC');

    // Reminder schedules repo empty here because FakeReminderService doesn't write.
    final schedules = await schedulesRepo.getForDocument(saved.id);
    expect(schedules, isEmpty);

    await db.close();
  });
}


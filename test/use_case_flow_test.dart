import 'package:cleartodrive/application/use_cases/confirm_document_use_case.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:cleartodrive/platform/document_scanner/fake_document_scanner_service.dart';
import 'package:cleartodrive/platform/ocr/fake_document_field_extractor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('core flow: fake scan/OCR → confirm save → dashboard + reminders', () async {
    // This test focuses on scan+extract→confirm. Reminder + persistence covered elsewhere.
    final vehicleRepo = _InMemoryVehicleRepository();
    final documentRepo = _InMemoryDocumentRepository();
    final reminderService = _NoopReminderService();
    final prefs = _InMemoryPrefs();
    const uuid = Uuid();

    final scanUseCase = ScanAndExtractUseCase(
      FakeDocumentScannerService(),
      FakeDocumentFieldExtractor(),
    );
    final confirmUseCase = ConfirmDocumentUseCase(
      vehicleRepo,
      documentRepo,
      reminderService,
      prefs,
      uuid,
    );
    final listUseCase = ListDocumentsUseCase(documentRepo, vehicleRepo);

    final draft = await scanUseCase.fromScan(typeHint: DocumentType.rca);
    expect(draft.licensePlate, 'B 123 ABC');
    expect(draft.type, DocumentType.rca);

    await confirmUseCase.save(draft);

    final dashboard = await listUseCase.execute();
    expect(dashboard, hasLength(1));
    expect(dashboard.first.plate, 'B 123 ABC');
    expect(dashboard.first.document.type, DocumentType.rca);

    // Noop reminder service in this test.
  });

  test('manual entry saves without scan', () async {
    final vehicleRepo = _InMemoryVehicleRepository();
    final documentRepo = _InMemoryDocumentRepository();
    final reminderService = _NoopReminderService();
    final prefs = _InMemoryPrefs();
    const uuid = Uuid();

    final confirmUseCase = ConfirmDocumentUseCase(
      vehicleRepo,
      documentRepo,
      reminderService,
      prefs,
      uuid,
    );

    final draft = ManualEntryDraftFactory().empty(type: DocumentType.rovinieta);
    final saved = await confirmUseCase.save(
      draft.copyWith(
        licensePlate: 'CJ 45 XYZ',
        expiryDate: DateTime(2027, 6, 1),
      ),
    );

    expect(saved.type, DocumentType.rovinieta);
    expect(saved.source, DocumentSource.manual);
  });
}

class _InMemoryPrefs implements AppPreferencesRepository {
  @override
  Future<ReminderPolicy> getReminderPolicy() async => ReminderPolicy.defaults;

  @override
  Future<bool> isOnboardingComplete() async => true;

  @override
  Future<void> setOnboardingComplete(bool value) async {}

  @override
  Future<void> setReminderPolicy(ReminderPolicy policy) async {}
}

class _NoopReminderService implements ReminderService {
  @override
  Future<void> cancelForDocument(String documentId) async {}

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId) async =>
      const [];

  @override
  Future<void> scheduleForDocument(VehicleDocument document, ReminderPolicy policy) async {}
}

class _InMemoryVehicleRepository implements VehicleRepository {
  final Map<String, Vehicle> _vehicles = {};

  @override
  Future<void> delete(String id) async => _vehicles.remove(id);

  @override
  Future<Vehicle?> findByPlate(String normalizedPlate) async {
    for (final v in _vehicles.values) {
      if (v.licensePlate == normalizedPlate) return v;
    }
    return null;
  }

  @override
  Future<List<Vehicle>> getAll() async => _vehicles.values.toList();

  @override
  Future<Vehicle?> getById(String id) async => _vehicles[id];

  @override
  Future<Vehicle> upsert(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
    return vehicle;
  }
}

class _InMemoryDocumentRepository implements DocumentRepository {
  final Map<String, VehicleDocument> _docs = {};

  @override
  Future<void> delete(String id) async => _docs.remove(id);

  @override
  Future<List<VehicleDocument>> getAll({String? vehicleId}) async => _docs.values.toList();

  @override
  Future<VehicleDocument?> getById(String id) async => _docs[id];

  @override
  Future<VehicleDocument> save(VehicleDocument document) async {
    _docs[document.id] = document;
    return document;
  }
}

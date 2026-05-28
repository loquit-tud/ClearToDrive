import 'dart:io';

import 'package:cleartodrive/application/use_cases/confirm_document_use_case.dart';
import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/data/repositories/drift_app_preferences_repository.dart';
import 'package:cleartodrive/data/repositories/drift_document_repository.dart';
import 'package:cleartodrive/data/repositories/drift_reminder_schedule_repository.dart';
import 'package:cleartodrive/data/repositories/drift_vehicle_repository.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class _FakeReminderService implements ReminderService {
  @override
  Future<void> cancelForDocument(String documentId) async {}

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId) async =>
      const [];

  @override
  Future<void> scheduleForDocument(
    VehicleDocument document,
    ReminderPolicy policy,
  ) async {}
}

void main() {
  test('saving imported ITP persists imagePath across repository reload', () async {
    final tempDir = await Directory.systemTemp.createTemp('ctd_persist');
    final imagePath = p.join(tempDir.path, 'itp.jpg');
    await File(imagePath).writeAsBytes([0xFF, 0xD8, 0xFF]);

    final executor = NativeDatabase.memory();
    final db = AppDatabase.forTesting(executor);
    final vehicleRepo = DriftVehicleRepository(db);
    final docRepo = DriftDocumentRepository(db);
    final prefsRepo = DriftAppPreferencesRepository(db);
    final uuid = const Uuid();

    final importDraft = await ImportFromGalleryUseCase(
      _PathScanner(imagePath),
    ).execute(typeHint: DocumentType.itp);

    final confirmUseCase = ConfirmDocumentUseCase(
      vehicleRepo,
      docRepo,
      _FakeReminderService(),
      prefsRepo,
      uuid,
    );

    final saved = await confirmUseCase.save(
      importDraft.copyWith(
        licensePlate: 'B 999 XYZ',
        expiryDate: DateTime(2027, 6, 15),
      ),
    );

    expect(saved.imagePath, imagePath);
    expect(saved.type, DocumentType.itp);

    final reloaded = DriftDocumentRepository(db);
    final loaded = await reloaded.getById(saved.id);
    expect(loaded?.imagePath, imagePath);

    await tempDir.delete(recursive: true);
  });
}

class _PathScanner implements DocumentScannerService {
  _PathScanner(this.path);

  final String path;

  @override
  Future<ScanResult> pickFromGallery() async =>
      ScanResult(imagePaths: [path]);

  @override
  Future<ScanResult> scan() => throw UnimplementedError();
}

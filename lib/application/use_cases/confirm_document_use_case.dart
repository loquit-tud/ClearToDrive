import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/entities/vehicle.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:uuid/uuid.dart';

class ConfirmDocumentUseCase {
  ConfirmDocumentUseCase(
    this._vehicleRepo,
    this._documentRepo,
    this._reminderService,
    this._preferences,
    this._uuid,
  );

  final VehicleRepository _vehicleRepo;
  final DocumentRepository _documentRepo;
  final ReminderService _reminderService;
  final AppPreferencesRepository _preferences;
  final Uuid _uuid;

  Future<VehicleDocument> save(ConfirmDraft draft) async {
    final plate = LicensePlateValidator.normalize(draft.licensePlate);
    if (plate.isEmpty) {
      throw ArgumentError('License plate is required');
    }
    final expiryDate = draft.expiryDate;
    if (expiryDate == null) {
      throw ArgumentError('Expiry date is required');
    }

    final now = DateTime.now();
    Vehicle vehicle;

    if (draft.vehicleId != null) {
      vehicle = (await _vehicleRepo.getById(draft.vehicleId!))!;
    } else {
      vehicle =
          await _vehicleRepo.findByPlate(plate) ??
          Vehicle(
            id: _uuid.v4(),
            licensePlate: plate,
            createdAt: now,
            updatedAt: now,
          );
      await _vehicleRepo.upsert(vehicle);
    }

    final isEdit = draft.documentId != null;
    final document = VehicleDocument(
      id: draft.documentId ?? _uuid.v4(),
      vehicleId: vehicle.id,
      type: draft.type,
      expiryDate: DateTime(expiryDate.year, expiryDate.month, expiryDate.day),
      source: draft.source,
      imagePath: draft.imagePath,
      confirmedAt: now,
      createdAt: isEdit
          ? (await _documentRepo.getById(draft.documentId!))!.createdAt
          : now,
      updatedAt: now,
    );

    final saved = await _documentRepo.save(document);
    final policy = await _preferences.getReminderPolicy();
    await _reminderService.scheduleForDocument(saved, policy);
    return saved;
  }
}

import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/core/utils/expiry_status_calculator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';

class DocumentWithVehicle {
  const DocumentWithVehicle({
    required this.document,
    required this.plate,
    this.displayName,
  });

  final VehicleDocument document;
  final String plate;
  final String? displayName;
}

class ListDocumentsUseCase {
  ListDocumentsUseCase(
    this._documentRepo,
    this._vehicleRepo,
  );

  final DocumentRepository _documentRepo;
  final VehicleRepository _vehicleRepo;

  Future<List<DocumentWithVehicle>> execute() async {
    final documents = await _documentRepo.getAll();
    final result = <DocumentWithVehicle>[];

    for (final doc in documents) {
      final vehicle = await _vehicleRepo.getById(doc.vehicleId);
      result.add(
        DocumentWithVehicle(
          document: doc,
          plate: vehicle?.licensePlate ?? '—',
          displayName: vehicle?.displayName,
        ),
      );
    }

    int rank(ExpiryStatus s) => switch (s) {
          ExpiryStatus.expired => 0,
          ExpiryStatus.expiringSoon => 1,
          ExpiryStatus.valid => 2,
        };

    result.sort((a, b) {
      final sa = ExpiryStatusCalculator.calculate(a.document.expiryDate);
      final sb = ExpiryStatusCalculator.calculate(b.document.expiryDate);
      final ra = rank(sa);
      final rb = rank(sb);
      if (ra != rb) return ra.compareTo(rb);
      return a.document.expiryDate.compareTo(b.document.expiryDate);
    });
    return result;
  }
}

class DeleteDocumentUseCase {
  DeleteDocumentUseCase(
    this._documentRepo,
    this._reminderService,
  );

  final DocumentRepository _documentRepo;
  final ReminderService _reminderService;

  Future<void> execute(String documentId) async {
    await _reminderService.cancelForDocument(documentId);
    await _documentRepo.delete(documentId);
  }
}

class GetDocumentDetailUseCase {
  GetDocumentDetailUseCase(
    this._documentRepo,
    this._vehicleRepo,
    this._reminderService,
  );

  final DocumentRepository _documentRepo;
  final VehicleRepository _vehicleRepo;
  final ReminderService _reminderService;

  Future<DocumentDetail?> execute(String documentId) async {
    final document = await _documentRepo.getById(documentId);
    if (document == null) return null;
    final vehicle = await _vehicleRepo.getById(document.vehicleId);
    final reminders = await _reminderService.getSchedulesForDocument(documentId);
    return DocumentDetail(
      document: document,
      plate: vehicle?.licensePlate ?? '—',
      reminders: reminders,
    );
  }
}

class DocumentDetail {
  const DocumentDetail({
    required this.document,
    required this.plate,
    required this.reminders,
  });

  final VehicleDocument document;
  final String plate;
  final List<ReminderSchedule> reminders;
}

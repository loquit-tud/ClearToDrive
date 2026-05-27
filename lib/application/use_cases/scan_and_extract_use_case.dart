import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

class ConfirmDraft {
  const ConfirmDraft({
    required this.type,
    required this.licensePlate,
    required this.expiryDate,
    required this.source,
    this.imagePath,
    this.documentId,
    this.vehicleId,
  });

  final DocumentType type;
  final String licensePlate;
  final DateTime expiryDate;
  final DocumentSource source;
  final String? imagePath;
  final String? documentId;
  final String? vehicleId;

  ConfirmDraft copyWith({
    DocumentType? type,
    String? licensePlate,
    DateTime? expiryDate,
    DocumentSource? source,
    String? imagePath,
    String? documentId,
    String? vehicleId,
  }) {
    return ConfirmDraft(
      type: type ?? this.type,
      licensePlate: licensePlate ?? this.licensePlate,
      expiryDate: expiryDate ?? this.expiryDate,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      documentId: documentId ?? this.documentId,
      vehicleId: vehicleId ?? this.vehicleId,
    );
  }
}

class ScanAndExtractUseCase {
  ScanAndExtractUseCase(this._scanner, this._extractor);

  final DocumentScannerService _scanner;
  final DocumentFieldExtractor _extractor;

  Future<ConfirmDraft> fromScan({required DocumentType typeHint}) async {
    final scan = await _scanner.scan();
    return _toDraft(
      scan: scan,
      typeHint: typeHint,
      source: DocumentSource.scan,
    );
  }

  Future<ConfirmDraft> fromGallery({required DocumentType typeHint}) async {
    final scan = await _scanner.pickFromGallery();
    return _toDraft(
      scan: scan,
      typeHint: typeHint,
      source: DocumentSource.import,
    );
  }

  Future<ConfirmDraft> _toDraft({
    required ScanResult scan,
    required DocumentType typeHint,
    required DocumentSource source,
  }) async {
    final imagePath = scan.primaryImagePath;
    if (imagePath == null) {
      return ConfirmDraft(
        type: typeHint,
        licensePlate: '',
        expiryDate: DateTime.now(),
        source: source,
      );
    }

    final extraction = await _extractor.extract(
      imagePath: imagePath,
      typeHint: typeHint,
    );

    return ConfirmDraft(
      type: extraction.suggestedType ?? typeHint,
      licensePlate: extraction.licensePlate ?? '',
      expiryDate: extraction.expiryDate ?? DateTime.now(),
      source: source,
      imagePath: imagePath,
    );
  }
}

class ManualEntryDraftFactory {
  ConfirmDraft empty({required DocumentType type}) {
    return ConfirmDraft(
      type: type,
      licensePlate: '',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      source: DocumentSource.manual,
    );
  }
}

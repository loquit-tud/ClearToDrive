import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// How OCR suggested the expiry field on the confirm screen.
enum OcrExpirySuggestion {
  /// OCR found a plausible RCA expiry — user must verify.
  detected,

  /// OCR ran but could not read expiry — user fills manually.
  notDetected,

  /// OCR suggested expiry with low confidence — user must verify carefully.
  lowConfidence,
}

class ConfirmDraft {
  const ConfirmDraft({
    required this.type,
    required this.licensePlate,
    this.expiryDate,
    required this.source,
    this.imagePath,
    this.documentId,
    this.vehicleId,
    this.ocrExpirySuggestion,
  });

  final DocumentType type;
  final String licensePlate;
  final DateTime? expiryDate;
  final DocumentSource source;
  final String? imagePath;
  final String? documentId;
  final String? vehicleId;
  final OcrExpirySuggestion? ocrExpirySuggestion;

  ConfirmDraft copyWith({
    DocumentType? type,
    String? licensePlate,
    DateTime? expiryDate,
    DocumentSource? source,
    String? imagePath,
    String? documentId,
    String? vehicleId,
    OcrExpirySuggestion? ocrExpirySuggestion,
  }) {
    return ConfirmDraft(
      type: type ?? this.type,
      licensePlate: licensePlate ?? this.licensePlate,
      expiryDate: expiryDate ?? this.expiryDate,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      documentId: documentId ?? this.documentId,
      vehicleId: vehicleId ?? this.vehicleId,
      ocrExpirySuggestion: ocrExpirySuggestion ?? this.ocrExpirySuggestion,
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
        source: source,
        ocrExpirySuggestion: typeHint == DocumentType.rca
            ? OcrExpirySuggestion.notDetected
            : null,
      );
    }

    final extraction = await _extractor.extract(
      imagePath: imagePath,
      typeHint: typeHint,
    );

    return ConfirmDraft(
      type: extraction.suggestedType ?? typeHint,
      licensePlate: extraction.licensePlate ?? '',
      expiryDate: extraction.expiryDate,
      source: source,
      imagePath: imagePath,
      ocrExpirySuggestion: _ocrSuggestion(typeHint, extraction),
    );
  }

  OcrExpirySuggestion? _ocrSuggestion(
    DocumentType typeHint,
    ExtractionResult extraction,
  ) {
    if (typeHint != DocumentType.rca) return null;
    if (!extraction.expiryDetected) {
      return OcrExpirySuggestion.notDetected;
    }
    if (extraction.lowConfidence) {
      return OcrExpirySuggestion.lowConfidence;
    }
    return OcrExpirySuggestion.detected;
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

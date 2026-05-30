import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

export 'package:cleartodrive/domain/ocr/document_template.dart';
export 'package:cleartodrive/domain/services/document_field_extractor.dart'
    show OcrExtractionDiagnostics;

enum DocumentAssistStatus { none, ocrSuccess, ocrNoData }

class ConfirmDraft {
  const ConfirmDraft({
    required this.type,
    required this.licensePlate,
    this.expiryDate,
    required this.source,
    this.imagePath,
    this.documentId,
    this.vehicleId,
    this.assistStatus = DocumentAssistStatus.none,
    this.needsManualReview = false,
    this.ocrRawText = '',
    this.expirySelectionReason,
    this.ocrDiagnostics,
    this.helperKey,
    this.detectedTemplate,
    this.typeHintPreserved,
  });

  final DocumentType type;
  final String licensePlate;
  final DateTime? expiryDate;
  final DocumentSource source;
  final String? imagePath;
  final String? documentId;
  final String? vehicleId;
  final DocumentAssistStatus assistStatus;
  final bool needsManualReview;
  final String ocrRawText;
  final String? expirySelectionReason;
  final OcrExtractionDiagnostics? ocrDiagnostics;
  final String? helperKey;
  final DocumentTemplate? detectedTemplate;
  final bool? typeHintPreserved;

  bool get expiryDateInferred =>
      expirySelectionReason == ExtractionReasons.inferredFromGreenCardToYear;

  ConfirmDraft copyWith({
    DocumentType? type,
    String? licensePlate,
    DateTime? expiryDate,
    DocumentSource? source,
    String? imagePath,
    String? documentId,
    String? vehicleId,
    DocumentAssistStatus? assistStatus,
    bool? needsManualReview,
    String? ocrRawText,
    String? expirySelectionReason,
    OcrExtractionDiagnostics? ocrDiagnostics,
    String? helperKey,
    DocumentTemplate? detectedTemplate,
    bool? typeHintPreserved,
  }) {
    return ConfirmDraft(
      type: type ?? this.type,
      licensePlate: licensePlate ?? this.licensePlate,
      expiryDate: expiryDate ?? this.expiryDate,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      documentId: documentId ?? this.documentId,
      vehicleId: vehicleId ?? this.vehicleId,
      assistStatus: assistStatus ?? this.assistStatus,
      needsManualReview: needsManualReview ?? this.needsManualReview,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      expirySelectionReason: expirySelectionReason ?? this.expirySelectionReason,
      ocrDiagnostics: ocrDiagnostics ?? this.ocrDiagnostics,
      helperKey: helperKey ?? this.helperKey,
      detectedTemplate: detectedTemplate ?? this.detectedTemplate,
      typeHintPreserved: typeHintPreserved ?? this.typeHintPreserved,
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

    final extraction = await _extractor.extractFromText(
      ocrText: OcrTextResult.success(_fakeScanText(typeHint)),
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

  String _fakeScanText(DocumentType typeHint) {
    final label = switch (typeHint) {
      DocumentType.rca => 'RCA',
      DocumentType.itp => 'ITP inspectie tehnica',
      DocumentType.rovinieta => 'Rovinieta',
    };
    return '$label B 123 ABC valabil pana 31.12.2026';
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

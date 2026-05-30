import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';

/// Debug diagnostics for QA when OCR expiry selection is ambiguous.
class OcrExtractionDiagnostics {
  const OcrExtractionDiagnostics({
    this.detectedTemplate,
    this.selectedDocumentType,
    this.typeHintPreserved,
    this.candidateFullDates = const [],
    this.candidateToYears = const [],
    this.selectedExpiryDate,
    this.selectionReason,
    this.rawTextPreview = '',
    this.vin,
  });

  final DocumentTemplate? detectedTemplate;
  final DocumentType? selectedDocumentType;
  final bool? typeHintPreserved;
  final List<DateTime> candidateFullDates;
  final List<int> candidateToYears;
  final DateTime? selectedExpiryDate;
  final String? selectionReason;
  final String rawTextPreview;
  final String? vin;
}

class ExtractionResult {
  const ExtractionResult({
    this.licensePlate,
    this.expiryDate,
    this.suggestedType,
    this.confidence,
    this.rawText = '',
    this.needsManualReview = false,
    this.expirySelectionReason,
    this.diagnostics,
    this.detectedTemplate,
    this.helperKey,
    this.vin,
    this.typeHintPreserved,
  });

  final String? licensePlate;
  final DateTime? expiryDate;
  final DocumentType? suggestedType;
  final double? confidence;
  final String rawText;
  final bool needsManualReview;
  final String? expirySelectionReason;
  final OcrExtractionDiagnostics? diagnostics;
  final DocumentTemplate? detectedTemplate;
  final String? helperKey;
  final String? vin;
  final bool? typeHintPreserved;

  bool get expiryDateInferred =>
      expirySelectionReason == ExtractionReasons.inferredFromGreenCardToYear;

  bool get hasUsefulData =>
      licensePlate != null ||
      expiryDate != null ||
      suggestedType != null ||
      vin != null;
}

abstract class DocumentFieldExtractor {
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  });
}

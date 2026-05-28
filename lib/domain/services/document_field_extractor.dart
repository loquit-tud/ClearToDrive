import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';

class ExtractionResult {
  const ExtractionResult({
    this.licensePlate,
    this.expiryDate,
    this.suggestedType,
    this.confidence,
    this.rawText = '',
    this.needsManualReview = false,
  });

  final String? licensePlate;
  final DateTime? expiryDate;
  final DocumentType? suggestedType;
  final double? confidence;
  final String rawText;
  final bool needsManualReview;

  bool get hasUsefulData =>
      licensePlate != null || expiryDate != null || suggestedType != null;
}

abstract class DocumentFieldExtractor {
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  });
}

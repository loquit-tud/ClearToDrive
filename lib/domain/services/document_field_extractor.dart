import 'package:cleartodrive/domain/enums/document_enums.dart';

class ExtractionResult {
  const ExtractionResult({
    this.licensePlate,
    this.expiryDate,
    this.suggestedType,
    this.confidence,
    this.rawText = '',
    this.expiryDetected = false,
    this.lowConfidence = true,
    this.expirySelectionReason,
    this.ocrReturnedText = false,
  });

  final String? licensePlate;
  final DateTime? expiryDate;
  final DocumentType? suggestedType;
  final double? confidence;
  final String rawText;
  final bool expiryDetected;
  final bool lowConfidence;
  final String? expirySelectionReason;
  final bool ocrReturnedText;
}

abstract class DocumentFieldExtractor {
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  });
}

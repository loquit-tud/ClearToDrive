import 'package:cleartodrive/domain/enums/document_enums.dart';

class ExtractionResult {
  const ExtractionResult({
    this.licensePlate,
    this.expiryDate,
    this.suggestedType,
    this.confidence,
    this.rawText = '',
  });

  final String? licensePlate;
  final DateTime? expiryDate;
  final DocumentType? suggestedType;
  final double? confidence;
  final String rawText;
}

abstract class DocumentFieldExtractor {
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  });
}

import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';

/// Fake OCR for prototype — always returns sample fields.
class FakeDocumentFieldExtractor implements DocumentFieldExtractor {
  @override
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final expiry = (referenceDate ?? DateTime.now()).add(
      const Duration(days: 90),
    );
    return ExtractionResult(
      licensePlate: 'B 123 ABC',
      expiryDate: DateTime(expiry.year, expiry.month, expiry.day),
      suggestedType: typeHint ?? DocumentType.rca,
      confidence: 0.85,
      rawText: 'SAMPLE RCA POLITA B 123 ABC Valabil pana la ...',
    );
  }
}

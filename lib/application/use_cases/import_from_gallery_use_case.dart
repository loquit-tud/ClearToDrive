import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Imports a gallery image and runs OCR field extraction (suggestions only).
class ImportFromGalleryUseCase {
  ImportFromGalleryUseCase(this._scanner, this._extractor);

  final DocumentScannerService _scanner;
  final DocumentFieldExtractor _extractor;

  Future<ConfirmDraft> execute({required DocumentType typeHint}) async {
    final scan = await _scanner.pickFromGallery();
    final imagePath = scan.primaryImagePath;
    if (imagePath == null) {
      throw const ScanFailed();
    }

    final extraction = await _extractor.extract(
      imagePath: imagePath,
      typeHint: typeHint,
    );

    return ConfirmDraft(
      type: extraction.suggestedType ?? typeHint,
      licensePlate: extraction.licensePlate ?? '',
      expiryDate: extraction.expiryDate,
      source: DocumentSource.import,
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

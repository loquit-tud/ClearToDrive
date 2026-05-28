import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Imports a real gallery image, runs best-effort local OCR, then asks the
/// user to confirm or correct every suggested field before saving.
class ImportFromGalleryUseCase {
  ImportFromGalleryUseCase(this._scanner, this._ocrService, this._extractor);

  final DocumentScannerService _scanner;
  final DocumentOcrService _ocrService;
  final DocumentFieldExtractor _extractor;

  Future<ConfirmDraft> execute({required DocumentType typeHint}) async {
    final scan = await _scanner.pickFromGallery();
    final imagePath = scan.primaryImagePath;
    if (imagePath == null) {
      throw const ScanFailed();
    }

    final ocrText = await _ocrService.recognizeText(imagePath);
    final extraction = await _extractor.extractFromText(
      ocrText: ocrText,
      typeHint: typeHint,
    );
    final hasUsefulSuggestions =
        extraction.licensePlate != null || extraction.expiryDate != null;

    return ConfirmDraft(
      type: typeHint,
      licensePlate: extraction.licensePlate ?? '',
      expiryDate: extraction.expiryDate,
      source: DocumentSource.import,
      imagePath: imagePath,
      assistStatus: hasUsefulSuggestions
          ? DocumentAssistStatus.ocrSuccess
          : DocumentAssistStatus.ocrNoData,
      needsManualReview: extraction.needsManualReview,
      ocrRawText: extraction.rawText,
    );
  }
}

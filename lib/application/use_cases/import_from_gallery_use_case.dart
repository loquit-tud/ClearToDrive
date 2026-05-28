import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Imports a real gallery image without OCR — user confirms fields manually.
class ImportFromGalleryUseCase {
  ImportFromGalleryUseCase(this._scanner);

  final DocumentScannerService _scanner;

  Future<ConfirmDraft> execute({required DocumentType typeHint}) async {
    final scan = await _scanner.pickFromGallery();
    final imagePath = scan.primaryImagePath;
    if (imagePath == null) {
      throw const ScanFailed();
    }

    return ConfirmDraft(
      type: typeHint,
      licensePlate: '',
      source: DocumentSource.import,
      imagePath: imagePath,
    );
  }
}

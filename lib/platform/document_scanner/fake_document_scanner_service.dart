import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Placeholder scanner — returns a fake sample image path.
class FakeDocumentScannerService implements DocumentScannerService {
  static const sampleImagePath = 'fake://sample-document.jpg';

  @override
  Future<ScanResult> pickFromGallery() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const ScanResult(imagePaths: [sampleImagePath]);
  }

  @override
  Future<ScanResult> scan() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const ScanResult(imagePaths: [sampleImagePath]);
  }
}

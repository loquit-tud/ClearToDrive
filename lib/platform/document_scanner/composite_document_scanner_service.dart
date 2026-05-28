import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Fake scan for MVP; real gallery import via [galleryDelegate].
class CompositeDocumentScannerService implements DocumentScannerService {
  const CompositeDocumentScannerService({
    required this.scanDelegate,
    required this.galleryDelegate,
  });

  final DocumentScannerService scanDelegate;
  final DocumentScannerService galleryDelegate;

  @override
  Future<ScanResult> scan() => scanDelegate.scan();

  @override
  Future<ScanResult> pickFromGallery() => galleryDelegate.pickFromGallery();
}

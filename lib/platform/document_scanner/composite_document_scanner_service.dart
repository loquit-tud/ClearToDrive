import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// Fake scan for MVP; real gallery import via [galleryDelegate].
class CompositeDocumentScannerService implements DocumentScannerService {
  const CompositeDocumentScannerService({
    required DocumentScannerService scanDelegate,
    required DocumentScannerService galleryDelegate,
  })  : _scanDelegate = scanDelegate,
        _galleryDelegate = galleryDelegate;

  final DocumentScannerService _scanDelegate;
  final DocumentScannerService _galleryDelegate;

  @override
  Future<ScanResult> scan() => _scanDelegate.scan();

  @override
  Future<ScanResult> pickFromGallery() => _galleryDelegate.pickFromGallery();
}

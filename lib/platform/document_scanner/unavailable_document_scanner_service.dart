import 'package:cleartodrive/domain/services/document_scanner_service.dart';

/// iOS-ready stub — routes users to gallery/manual until VisionKit ships.
class UnavailableDocumentScannerService implements DocumentScannerService {
  @override
  Future<ScanResult> pickFromGallery() {
    throw const ScannerUnavailable();
  }

  @override
  Future<ScanResult> scan() {
    throw const ScannerUnavailable();
  }
}

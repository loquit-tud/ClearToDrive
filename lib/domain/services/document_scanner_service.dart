class ScanResult {
  const ScanResult({
    required this.imagePaths,
    this.pdfPath,
  });

  final List<String> imagePaths;
  final String? pdfPath;

  String? get primaryImagePath =>
      imagePaths.isNotEmpty ? imagePaths.first : null;
}

sealed class ScanFailure implements Exception {
  const ScanFailure();
}

class ScanCancelled extends ScanFailure {
  const ScanCancelled();
}

class ScanFailed extends ScanFailure {
  const ScanFailed([this.message]);
  final String? message;
}

class ScannerUnavailable extends ScanFailure {
  const ScannerUnavailable();
}

abstract class DocumentScannerService {
  Future<ScanResult> scan();
  Future<ScanResult> pickFromGallery();
}

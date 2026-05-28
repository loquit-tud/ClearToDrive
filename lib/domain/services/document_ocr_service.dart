class OcrTextResult {
  const OcrTextResult({
    required this.text,
    required this.succeeded,
    this.errorMessage,
  });

  const OcrTextResult.success(this.text)
    : succeeded = true,
      errorMessage = null;

  const OcrTextResult.failure([this.errorMessage])
    : text = '',
      succeeded = false;

  final String text;
  final bool succeeded;
  final String? errorMessage;

  bool get hasText => text.trim().isNotEmpty;
}

abstract class DocumentOcrService {
  Future<OcrTextResult> recognizeText(String imagePath);
}

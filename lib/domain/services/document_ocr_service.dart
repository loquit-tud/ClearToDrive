/// Axis-aligned bounding box from OCR (normalized 0–1 when available).
class OcrTextBoundingBox {
  const OcrTextBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

class OcrTextLine {
  const OcrTextLine({required this.text, this.boundingBox, this.confidence});

  final String text;
  final OcrTextBoundingBox? boundingBox;
  final double? confidence;
}

class OcrTextBlock {
  const OcrTextBlock({
    required this.text,
    this.lines = const [],
    this.boundingBox,
  });

  final String text;
  final List<OcrTextLine> lines;
  final OcrTextBoundingBox? boundingBox;
}

class OcrTextResult {
  const OcrTextResult({
    required this.text,
    required this.succeeded,
    this.errorMessage,
    this.blocks = const [],
    this.lines = const [],
  });

  const OcrTextResult.success(
    this.text, {
    this.blocks = const [],
    this.lines = const [],
  }) : succeeded = true,
       errorMessage = null;

  const OcrTextResult.failure([this.errorMessage])
    : text = '',
      succeeded = false,
      blocks = const [],
      lines = const [];

  final String text;
  final bool succeeded;
  final String? errorMessage;
  final List<OcrTextBlock> blocks;
  final List<OcrTextLine> lines;

  bool get hasText => text.trim().isNotEmpty;
}

abstract class DocumentOcrService {
  Future<OcrTextResult> recognizeText(String imagePath);
}

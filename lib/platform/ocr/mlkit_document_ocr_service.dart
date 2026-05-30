import 'dart:io';
import 'dart:ui';

import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlKitDocumentOcrService implements DocumentOcrService {
  MlKitDocumentOcrService({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<OcrTextResult> recognizeText(String imagePath) async {
    if (!Platform.isAndroid) {
      return const OcrTextResult.failure('OCR is only enabled on Android.');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return const OcrTextResult.failure('Image file does not exist.');
    }

    try {
      final image = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(image);
      final text = recognized.text.trim();
      if (text.isEmpty) {
        return const OcrTextResult.failure('No text found.');
      }

      final blocks = <OcrTextBlock>[];
      final lines = <OcrTextLine>[];
      for (final block in recognized.blocks) {
        final blockLines = <OcrTextLine>[];
        for (final line in block.lines) {
          final ocrLine = OcrTextLine(
            text: line.text,
            boundingBox: _boxFromRect(line.boundingBox),
          );
          blockLines.add(ocrLine);
          lines.add(ocrLine);
        }
        blocks.add(
          OcrTextBlock(
            text: block.text,
            lines: blockLines,
            boundingBox: _boxFromRect(block.boundingBox),
          ),
        );
      }

      return OcrTextResult.success(text, blocks: blocks, lines: lines);
    } catch (e) {
      return OcrTextResult.failure(e.toString());
    }
  }

  OcrTextBoundingBox? _boxFromRect(Rect rect) {
    if (rect.width <= 0 || rect.height <= 0) return null;
    return OcrTextBoundingBox(
      left: rect.left,
      top: rect.top,
      right: rect.right,
      bottom: rect.bottom,
    );
  }
}

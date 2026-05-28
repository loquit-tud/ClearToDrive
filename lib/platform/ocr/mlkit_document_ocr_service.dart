import 'dart:io';

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
      return OcrTextResult.success(text);
    } catch (e) {
      return OcrTextResult.failure(e.toString());
    }
  }
}

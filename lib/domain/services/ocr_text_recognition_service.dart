/// Platform text recognition from a document image (ML Kit / VisionKit later).
abstract class OcrTextRecognitionService {
  Future<String> recognizeText({
    required String imagePath,
  });
}

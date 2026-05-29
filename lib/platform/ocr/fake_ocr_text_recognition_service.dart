import 'package:cleartodrive/domain/services/ocr_text_recognition_service.dart';

/// Simulates OCR text for prototype / QA — not legal truth.
class FakeOcrTextRecognitionService implements OcrTextRecognitionService {
  FakeOcrTextRecognitionService({this.textOverrides});

  /// Optional per-path OCR text for tests (path → raw text).
  final Map<String, String>? textOverrides;

  static const sampleRcaText = '''
POLITA RCA ASIGURARE AUTO
Nr. inmatriculare B 123 ABC
Valabilitate: 29.05.2025 - 28.05.2026
Asigurator: Sample S.A.
''';

  static const sampleItpText = '''
CERTIFICAT ITP
Numar: B 123 ABC
Valabil pana la 15.03.2027
''';

  @override
  Future<String> recognizeText({required String imagePath}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final override = textOverrides?[imagePath];
    if (override != null) return override;

    if (imagePath.startsWith('fake://')) {
      return sampleRcaText;
    }

    // Real gallery images: no on-device OCR in MVP — empty text → manual confirm.
    return '';
  }
}

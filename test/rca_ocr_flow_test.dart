import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/platform/document_scanner/fake_document_scanner_service.dart';
import 'package:cleartodrive/platform/ocr/fake_ocr_text_recognition_service.dart';
import 'package:cleartodrive/platform/ocr/parsing_document_field_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ParsingDocumentFieldExtractor extractor;
  late FakeOcrTextRecognitionService recognition;

  setUp(() {
    recognition = FakeOcrTextRecognitionService();
    extractor = ParsingDocumentFieldExtractor(recognition);
  });

  test('fake scan RCA suggests parsed expiry on confirm draft', () async {
    final useCase = ScanAndExtractUseCase(
      FakeDocumentScannerService(),
      extractor,
    );

    final draft = await useCase.fromScan(typeHint: DocumentType.rca);

    expect(draft.expiryDate, DateTime(2026, 5, 28));
    expect(draft.licensePlate, 'B 123 ABC');
    expect(draft.ocrExpirySuggestion, OcrExpirySuggestion.detected);
  });

  test('gallery RCA with OCR text override prefills expiry', () async {
    const path = '/data/imported/rca.jpg';
    const text = 'RCA Valabilitate: 29.05.2025 - 28.05.2026';
    recognition = FakeOcrTextRecognitionService(
      textOverrides: {path: text},
    );
    extractor = ParsingDocumentFieldExtractor(recognition);

    final draft = await ImportFromGalleryUseCase(
      _PathScanner(path),
      extractor,
    ).execute(typeHint: DocumentType.rca);

    expect(draft.expiryDate, DateTime(2026, 5, 28));
    expect(draft.ocrExpirySuggestion, OcrExpirySuggestion.detected);
    expect(draft.imagePath, path);
  });

  test('OCR failure still opens confirm with empty editable expiry', () async {
    const path = '/data/imported/rca-empty.jpg';
    final draft = await ImportFromGalleryUseCase(
      _PathScanner(path),
      extractor,
    ).execute(typeHint: DocumentType.rca);

    expect(draft.expiryDate, isNull);
    expect(draft.ocrExpirySuggestion, OcrExpirySuggestion.notDetected);
  });

  test('user-edited expiry is what confirm save would persist', () async {
    final draft = await ScanAndExtractUseCase(
      FakeDocumentScannerService(),
      extractor,
    ).fromScan(typeHint: DocumentType.rca);

    final userConfirmed = draft.copyWith(expiryDate: DateTime(2027, 1, 15));

    expect(userConfirmed.expiryDate, DateTime(2027, 1, 15));
    expect(userConfirmed.expiryDate, isNot(draft.expiryDate));
  });
}

class _PathScanner implements DocumentScannerService {
  _PathScanner(this.path);

  final String path;

  @override
  Future<ScanResult> pickFromGallery() async =>
      ScanResult(imagePaths: [path]);

  @override
  Future<ScanResult> scan() => throw UnimplementedError();
}

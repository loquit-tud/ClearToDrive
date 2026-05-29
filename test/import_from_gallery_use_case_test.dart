import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockScanner implements DocumentScannerService {
  _MockScanner({this.onPick});

  final Future<ScanResult> Function()? onPick;

  @override
  Future<ScanResult> pickFromGallery() => onPick!();

  @override
  Future<ScanResult> scan() => throw UnimplementedError();
}

class _NoOcrExtractor implements DocumentFieldExtractor {
  @override
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  }) async {
    return const ExtractionResult();
  }
}

void main() {
  test(
    'gallery import success returns draft with imagePath and no OCR plate',
    () async {
      const path = '/data/imported/itp.jpg';
      final useCase = ImportFromGalleryUseCase(
        _MockScanner(onPick: () async => const ScanResult(imagePaths: [path])),
        _NoOcrExtractor(),
      );

      final draft = await useCase.execute(typeHint: DocumentType.itp);

      expect(draft.type, DocumentType.itp);
      expect(draft.imagePath, path);
      expect(draft.licensePlate, isEmpty);
      expect(draft.expiryDate, isNull);
      expect(draft.source, DocumentSource.import);
      expect(draft.ocrExpirySuggestion, isNull);
    },
  );

  test('gallery RCA without OCR text suggests manual expiry', () async {
    const path = '/data/imported/rca.jpg';
    final useCase = ImportFromGalleryUseCase(
      _MockScanner(onPick: () async => const ScanResult(imagePaths: [path])),
      _NoOcrExtractor(),
    );

    final draft = await useCase.execute(typeHint: DocumentType.rca);

    expect(draft.expiryDate, isNull);
    expect(draft.ocrExpirySuggestion, OcrExpirySuggestion.notDetected);
  });

  test('gallery cancel propagates ScanCancelled', () async {
    final useCase = ImportFromGalleryUseCase(
      _MockScanner(onPick: () async => throw const ScanCancelled()),
      _NoOcrExtractor(),
    );

    expect(
      () => useCase.execute(typeHint: DocumentType.itp),
      throwsA(isA<ScanCancelled>()),
    );
  });

  test('gallery failure when no image path', () async {
    final useCase = ImportFromGalleryUseCase(
      _MockScanner(onPick: () async => const ScanResult(imagePaths: [])),
      _NoOcrExtractor(),
    );

    expect(
      () => useCase.execute(typeHint: DocumentType.itp),
      throwsA(isA<ScanFailed>()),
    );
  });
}

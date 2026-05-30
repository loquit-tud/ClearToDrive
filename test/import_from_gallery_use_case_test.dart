import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/platform/ocr/romanian_document_field_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockScanner implements DocumentScannerService {
  _MockScanner({this.onPick});

  final Future<ScanResult> Function()? onPick;

  @override
  Future<ScanResult> pickFromGallery() => onPick!();

  @override
  Future<ScanResult> scan() => throw UnimplementedError();
}

class _MockOcrService implements DocumentOcrService {
  _MockOcrService(this.result);

  final OcrTextResult result;
  var calls = 0;

  @override
  Future<OcrTextResult> recognizeText(String imagePath) async {
    calls++;
    return result;
  }
}

void main() {
  test(
    'gallery import success runs OCR and returns editable suggestions',
    () async {
      const path = '/data/imported/itp.jpg';
      final ocr = _MockOcrService(
        const OcrTextResult.success('ITP B 123 ABC valabil pana 29.08.2026'),
      );
      final useCase = ImportFromGalleryUseCase(
        _MockScanner(onPick: () async => const ScanResult(imagePaths: [path])),
        ocr,
        const RomanianDocumentFieldExtractor(),
      );

      final draft = await useCase.execute(typeHint: DocumentType.itp);

      expect(ocr.calls, 1);
      expect(draft.type, DocumentType.itp);
      expect(draft.imagePath, path);
      expect(draft.licensePlate, 'B 123 ABC');
      expect(draft.expiryDate, DateTime(2026, 8, 29));
      expect(draft.source, DocumentSource.import);
      expect(draft.assistStatus, DocumentAssistStatus.ocrSuccess);
    },
  );

  test(
    'gallery import keeps selected RCA when OCR text contains noisy ITP',
    () async {
      const path = '/data/imported/rca.jpg';
      final ocr = _MockOcrService(
        const OcrTextResult.success(
          'ITP apare ca zgomot OCR\n'
          'CARTE INTERNATIONALA DE ASIGURARE RCA\n'
          'DE LA - FROM 05 08 2026 PANA LA - TO 05 08 2027\n'
          'PH85GLD',
        ),
      );
      final useCase = ImportFromGalleryUseCase(
        _MockScanner(onPick: () async => const ScanResult(imagePaths: [path])),
        ocr,
        const RomanianDocumentFieldExtractor(),
      );

      final draft = await useCase.execute(typeHint: DocumentType.rca);

      expect(draft.type, DocumentType.rca);
      expect(draft.licensePlate, 'PH 85 GLD');
      expect(draft.expiryDate, DateTime(2027, 8, 5));
      expect(draft.assistStatus, DocumentAssistStatus.ocrSuccess);
    },
  );

  test(
    'gallery import infers RCA expiry from fragmented Green Card OCR',
    () async {
      const path = '/data/imported/rca-fragmented.jpg';
      final ocr = _MockOcrService(
        const OcrTextResult.success(
          'DE LA- FROM\n'
          'Ani-Year\n'
          '2026 08\n'
          '05\n'
          'PH85GLD\n'
          'RCA\n'
          'PANA LA -TO\n'
          'Luna-Month Anil-Year\n'
          '05\n'
          'ITP\n'
          '2027\n'
          '05.08.2026',
        ),
      );
      final useCase = ImportFromGalleryUseCase(
        _MockScanner(onPick: () async => const ScanResult(imagePaths: [path])),
        ocr,
        const RomanianDocumentFieldExtractor(),
      );

      final draft = await useCase.execute(typeHint: DocumentType.rca);

      expect(draft.type, DocumentType.rca);
      expect(draft.licensePlate, 'PH 85 GLD');
      expect(draft.expiryDate, DateTime(2027, 8, 5));
      expect(draft.expirySelectionReason, ExtractionReasons.inferredFromGreenCardToYear);
      expect(draft.ocrDiagnostics?.selectionReason,
          ExtractionReasons.inferredFromGreenCardToYear);
    },
  );

  test('gallery cancel propagates ScanCancelled', () async {
    final useCase = ImportFromGalleryUseCase(
      _MockScanner(onPick: () async => throw const ScanCancelled()),
      _MockOcrService(const OcrTextResult.failure()),
      const RomanianDocumentFieldExtractor(),
    );

    expect(
      () => useCase.execute(typeHint: DocumentType.itp),
      throwsA(isA<ScanCancelled>()),
    );
  });

  test('gallery failure when no image path', () async {
    final useCase = ImportFromGalleryUseCase(
      _MockScanner(onPick: () async => const ScanResult(imagePaths: [])),
      _MockOcrService(const OcrTextResult.failure()),
      const RomanianDocumentFieldExtractor(),
    );

    expect(
      () => useCase.execute(typeHint: DocumentType.itp),
      throwsA(isA<ScanFailed>()),
    );
  });
}

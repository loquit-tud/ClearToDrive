import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/platform/ocr/romanian_document_field_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final extractor = RomanianDocumentFieldExtractor();
  final referenceDate = DateTime(2026, 5, 28);

  test(
    'OCR text result with ITP expiry date extracts correct expiry date',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Inspectie tehnica periodica ITP\nB 123 ABC\nValabil pana 29.08.2026',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(result.suggestedType, DocumentType.itp);
      expect(result.expiryDate, DateTime(2026, 8, 29));
      expect(result.licensePlate, 'B 123 ABC');
    },
  );

  test('multiple dates chooses expiry-like future date', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'Data inspectiei 28.05.2026\n'
        'Serie formular 01.01.2025\n'
        'ITP valabil pana la 29/08/2026',
      ),
      typeHint: DocumentType.itp,
      referenceDate: referenceDate,
    );

    expect(result.expiryDate, DateTime(2026, 8, 29));
  });

  test('Romanian plate normalization works for OCR compact spacing', () async {
    expect(LicensePlateValidator.normalize('ph12abc'), 'PH 12 ABC');
    expect(LicensePlateValidator.normalize('CJ99XYZ'), 'CJ 99 XYZ');

    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'ITP PH12ABC valabil pana 2026-08-29',
      ),
      typeHint: DocumentType.itp,
      referenceDate: referenceDate,
    );

    expect(result.licensePlate, 'PH 12 ABC');
  });

  test(
    'ITP expiry tolerates spaced separators and OCR digit mistakes',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Certificat I.T.P.\n'
          'B 123 ABC\n'
          'Data următoarei inspecții tehnice: 29 . O8 . 2026',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(result.suggestedType, DocumentType.itp);
      expect(result.expiryDate, DateTime(2026, 8, 29));
      expect(result.licensePlate, 'B 123 ABC');
    },
  );

  test(
    'ITP expiry supports whitespace separated and month name dates',
    () async {
      final spacedResult = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Valabilitate ITP pana la 29 08 2026',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );
      final monthResult = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Urmatoarea inspectie tehnica 29 august 2026',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(spacedResult.expiryDate, DateTime(2026, 8, 29));
      expect(monthResult.expiryDate, DateTime(2026, 8, 29));
    },
  );

  test('RCA green card table extracts PANA LA date and plate', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'CARTE INTERNATIONALA DE ASIGURARE\n'
        'INTERNATIONAL MOTOR INSURANCE CARD\n'
        '3. VALABILITATE - VALID\n'
        'DE LA - FROM PANA LA - TO\n'
        'Ziua Luna Anul Ziua Luna Anul\n'
        '09 05 2026 08 05 2027\n'
        'Nr. inmatriculare PH85GJD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.suggestedType, DocumentType.rca);
    expect(result.expiryDate, DateTime(2027, 5, 8));
    expect(result.licensePlate, 'PH 85 GJD');
  });

  test(
    'RCA green card vertical OCR dates prefer the PANA LA future date',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'VALABILITATE - VALID\n'
          'DE LA - FROM\n'
          '09\n'
          '05\n'
          '2026\n'
          'PANA LA - TO\n'
          '08\n'
          '05\n'
          '2027\n'
          'PH85GJD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.expiryDate, DateTime(2027, 5, 8));
      expect(result.licensePlate, 'PH 85 GJD');
    },
  );

  test(
    'RCA green card keeps Ziua Luna Anul order for ambiguous date',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CARTE INTERNATIONALA DE ASIGURARE\n'
          'VALABILITATE - VALID\n'
          'DE LA - FROM PANA LA - TO\n'
          'Ziua Luna Anul Ziua Luna Anul\n'
          '09 05 2026 08 05 2027\n'
          'PH85GJD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.expiryDate, DateTime(2027, 5, 8));
      expect(result.expiryDate, isNot(DateTime(2027, 8, 5)));
    },
  );

  test(
    'RCA green card column-major OCR keeps day and month separate',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CARTE INTERNATIONALA DE ASIGURARE\n'
          'VALABILITATE - VALID\n'
          'DE LA - FROM PANA LA - TO\n'
          'Ziua Luna Anul Ziua Luna Anul\n'
          '09 08\n'
          '05 05\n'
          '2026 2027\n'
          'PH85GJD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.expiryDate, DateTime(2027, 5, 8));
      expect(result.expiryDate, isNot(DateTime(2027, 8, 5)));
    },
  );

  test('RCA green card does not keep a generic start-date fallback', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'CARTE INTERNATIONALA DE ASIGURARE\n'
        'VALABILITATE - VALID\n'
        'DE LA - FROM PANA LA - TO\n'
        'Ziua Luna Anul Ziua Luna Anul\n'
        '05 08 2026\n'
        'PH85GJD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, isNull);
    expect(result.licensePlate, 'PH 85 GJD');
  });
}

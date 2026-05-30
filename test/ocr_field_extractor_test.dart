import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
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

  test(
    'RCA green card accepts single future PANA LA date in day month year order',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CARTE INTERNATIONALA DE ASIGURARE\n'
          'VALABILITATE - VALID\n'
          'PANA LA - TO\n'
          'Ziua Luna Anul\n'
          '08 05 2027\n'
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
    'RCA green card tolerates OCR month digit mistakes in expiry date',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CARTE INTERNATIONALA DE ASIGURARE\n'
          'VALABILITATE - VALID\n'
          'PANA LA - TO\n'
          'Ziua Luna Anul\n'
          'O8 OS 2O27\n'
          'PH85GJD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.expiryDate, DateTime(2027, 5, 8));
    },
  );

  test('RCA fragmented Green Card range chooses PANA LA expiry date', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'CARTE INTERNATIONALA DE ASIGURARE\n'
        'DE LA - FROM\n'
        'Ziua-Day / Luna-Month / Anul-Year\n'
        '05 / 08 / 2026\n'
        'PANA LA - TO\n'
        'Ziua-Day / Luna-Month / Anul-Year\n'
        '05 / 08 / 2027\n'
        'PH85GLD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, DateTime(2027, 8, 5));
    expect(result.licensePlate, 'PH 85 GLD');
  });

  test('RCA normal validity range chooses later end date', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'RCA asigurare\n'
        'Valabilitate: 05.08.2026 - 05.08.2027\n'
        'PH85GLD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, DateTime(2027, 8, 5));
    expect(result.licensePlate, 'PH 85 GLD');
  });

  test('RCA de la pana la range chooses pana la date', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'Asigurare RCA PH85GLD de la 05/08/2026 pana la 05/08/2027',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, DateTime(2027, 8, 5));
    expect(result.licensePlate, 'PH 85 GLD');
  });

  test(
    'OCR noisy ITP text does not override selected RCA document type',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'ITP mentionat pe pagina, dar documentul este RCA\n'
          'DE LA - FROM 05 08 2026 PANA LA - TO 05 08 2027\n'
          'PH85GLD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.suggestedType, DocumentType.rca);
      expect(result.expiryDate, DateTime(2027, 8, 5));
    },
  );

  test('RCA plate PH85GLD normalizes with spaces', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success('RCA PH85GLD pana la 05.08.2027'),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.licensePlate, 'PH 85 GLD');
  });

  const qaFragmentedGreenCardText =
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
      '05.08.2026';

  test(
    'QA fragmented Green Card infers expiry from TO year near PANA LA',
    () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(qaFragmentedGreenCardText),
        typeHint: DocumentType.rca,
        referenceDate: DateTime(2026, 5, 29),
      );

      expect(result.suggestedType, DocumentType.rca);
      expect(result.licensePlate, 'PH 85 GLD');
      expect(result.expiryDate, DateTime(2027, 8, 5));
      expect(result.expirySelectionReason, ExtractionReasons.greenCardToYearWithFromDayMonth);
      expect(result.expiryDateInferred, isTrue);
      expect(result.needsManualReview, isTrue);
      expect(result.diagnostics?.candidateToYears, contains(2027));
    },
  );

  test('RCA fragmented Green Card without TO year does not infer expiry', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'DE LA - FROM\n'
        '05 08 2026\n'
        'PANA LA - TO\n'
        '05\n'
        'PH85GLD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, isNull);
    expect(result.expirySelectionReason, isNull);
  });

  test('RCA normal range reports explicit range reason', () async {
    final result = await extractor.extractFromText(
      ocrText: const OcrTextResult.success(
        'RCA asigurare\n'
        'Valabilitate: 05.08.2026 - 05.08.2027\n'
        'PH85GLD',
      ),
      typeHint: DocumentType.rca,
      referenceDate: DateTime(2026, 5, 29),
    );

    expect(result.expiryDate, DateTime(2027, 8, 5));
    expect(result.expirySelectionReason, isNot(ExtractionReasons.greenCardToYearWithFromDayMonth));
  });
}

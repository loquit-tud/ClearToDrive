import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/platform/ocr/romanian_document_field_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = RomanianDocumentFieldExtractor();
  final referenceDate = DateTime(2026, 5, 28);

  group('RCA_GREEN_CARD', () {
    test('official-like table FROM/TO extracts expiry', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CARTE INTERNATIONALA DE ASIGURARE\n'
          'INTERNATIONAL MOTOR INSURANCE CARD\n'
          '3. VALABILITATE - VALID\n'
          'DE LA - FROM PANA LA - TO\n'
          'Ziua Luna Anul Ziua Luna Anul\n'
          '05 08 2026 05 08 2027\n'
          'PH85GLD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.rcaGreenCard);
      expect(result.expiryDate, DateTime(2027, 8, 5));
      expect(result.licensePlate, 'PH 85 GLD');
      expect(result.suggestedType, DocumentType.rca);
    });

    test('fragmented OCR infers expiry from TO year', () async {
      const text =
          'DE LA- FROM\n'
          '2026 08\n'
          '05\n'
          'PH85GLD\n'
          'RCA\n'
          'PANA LA -TO\n'
          '05\n'
          'ITP\n'
          '2027\n'
          '05.08.2026';

      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(text),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.rcaGreenCard);
      expect(result.expiryDate, DateTime(2027, 8, 5));
      expect(
        result.expirySelectionReason,
        ExtractionReasons.inferredFromGreenCardToYear,
      );
      expect(result.typeHintPreserved, isTrue);
    });

    test('noisy ITP in OCR keeps selected RCA type', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'ITP zgomot OCR\n'
          'DE LA - FROM 05 08 2026 PANA LA - TO 05 08 2027\n'
          'PH85GLD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.suggestedType, DocumentType.rca);
      expect(result.typeHintPreserved, isTrue);
      expect(result.expiryDate, DateTime(2027, 8, 5));
    });
  });

  group('RCA_POLICY', () {
    test('valabilitate range end date', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'RCA polita asigurare\n'
          'Valabilitate: 05.08.2026 - 05.08.2027\n'
          'PH85GLD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.rcaPolicy);
      expect(result.expiryDate, DateTime(2027, 8, 5));
    });

    test('de la pana la range', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Asigurare RCA de la 05/08/2026 pana la 05/08/2027 PH85GLD',
        ),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.expiryDate, DateTime(2027, 8, 5));
    });

    test('multiple dates prefers validity end', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Polita RCA\n'
          'Data emiterii 01.01.2025\n'
          'Valabilitate: 05.08.2026 - 05.08.2027\n',
        ),
        typeHint: DocumentType.rca,
        referenceDate: referenceDate,
      );

      expect(result.expiryDate, DateTime(2027, 8, 5));
    });
  });

  group('ITP_CERTIFICATE', () {
    test('annex-only RAR certificate yields no expiry and helper', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CERTIFICAT DE INSPECȚIE TEHNICĂ PERIODICĂ\n'
          'ROADWORTHINESS CERTIFICATE\n'
          'Registrul Auto Român RAR\n'
          '(8) data următoarei inspecții tehnice periodice:\n'
          'conform anexei la certificatul de înmatriculare\n',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.itpCertificate);
      expect(result.expiryDate, isNull);
      expect(result.helperKey, ExtractionHelperKeys.itpCertificateAnnex);
    });

    test('concrete next ITP date is extracted', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'CERTIFICAT DE INSPECȚIE TEHNICĂ PERIODICĂ\n'
          'RAR\n'
          'data următoarei inspecții tehnice periodice: 29.08.2026\n',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(result.expiryDate, DateTime(2026, 8, 29));
    });
  });

  group('ITP_REGISTRATION_ANNEX', () {
    test('valabil pana la on annex', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Certificat de inmatriculare anexa\n'
          'ITP valabil pana la 29.08.2026\n'
          'B 123 ABC',
        ),
        typeHint: DocumentType.itp,
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.itpRegistrationAnnex);
      expect(result.expiryDate, DateTime(2026, 8, 29));
    });
  });

  group('CIV_RAR', () {
    test('CIV text yields no expiry and civ helper', () async {
      final result = await extractor.extractFromText(
        ocrText: const OcrTextResult.success(
          'Cartea de Identitate a Vehiculului\n'
          'Registrul Auto Român\n'
          'VIN WVWZZZ1KZAW123456\n'
          'Seria caroseriei WVWZZZ1KZAW123456',
        ),
        referenceDate: referenceDate,
      );

      expect(result.detectedTemplate, DocumentTemplate.civRar);
      expect(result.expiryDate, isNull);
      expect(result.helperKey, ExtractionHelperKeys.civNoExpiry);
    });
  });
}

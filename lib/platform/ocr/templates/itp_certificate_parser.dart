import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/date_parser.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';

/// RAR Roadworthiness Certificate — may reference registration annex for next ITP date.
abstract final class ItpCertificateParser {
  static const _annexOnlyPhrase =
      'conform anexei la certificatul de inmatriculare';

  static const _concreteDateKeywords = [
    'data urmatoarei inspectii tehnice periodice',
    'data următoarei inspecții tehnice periodice',
    'data urmatoarei inspectii tehnice',
    'data urmatoarei inspecții tehnice',
    'urmatoarea inspectie tehnica',
    'următoarea inspecție tehnică',
  ];

  static TemplateParseResult parse(OcrExtractionContext ctx) {
    final hasAnnexReference = ctx.normalizedText.contains(_annexOnlyPhrase);
    final candidates = DateParser.collectDateCandidates(
      ctx.rawText,
      ctx.normalizedText,
    );

    final choice = DateParser.bestScoredCandidate(
      candidates: candidates,
      normalizedText: ctx.normalizedText,
      reference: ctx.referenceDate,
      positiveKeywords: [
        ..._concreteDateKeywords,
        'valabil pana la',
        'valabil până la',
        'valabilitate',
      ],
      negativeKeywords: [
        'data inspectiei',
        'data inspecției',
        'data emiterii',
      ],
      reason: ExtractionReasons.itpConcreteDate,
    );

    if (choice == null && hasAnnexReference) {
      return TemplateParseResult(
        licensePlate: PlateExtractor.extract(ctx.rawText),
        helperKey: ExtractionHelperKeys.itpCertificateAnnex,
        expirySelectionReason: ExtractionReasons.noExpiryByTemplate,
        candidateFullDates: DateParser.allDatesInText(ctx.rawText),
        needsManualReview: true,
      );
    }

    return TemplateParseResult(
      expiryDate: choice?.date,
      licensePlate: PlateExtractor.extract(ctx.rawText),
      confidence: choice?.confidence,
      expirySelectionReason: choice?.reason,
      candidateFullDates: DateParser.allDatesInText(ctx.rawText),
      needsManualReview: choice == null || choice.confidence < 0.7,
    );
  }
}

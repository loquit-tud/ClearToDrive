import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/date_parser.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';

/// ITP date on registration certificate annex / talon.
abstract final class ItpRegistrationAnnexParser {
  static const _positiveKeywords = [
    'itp',
    'inspectie tehnica periodica',
    'inspecție tehnică periodică',
    'urmatoarea inspectie',
    'următoarea inspecție',
    'valabil pana la',
    'valabil până la',
    'data urmatoarei itp',
    'anexa',
    'anexă',
    'certificat de inmatriculare',
  ];

  static TemplateParseResult parse(OcrExtractionContext ctx) {
    final candidates = DateParser.collectDateCandidates(
      ctx.rawText,
      ctx.normalizedText,
    );
    final choice = DateParser.bestScoredCandidate(
      candidates: candidates,
      normalizedText: ctx.normalizedText,
      reference: ctx.referenceDate,
      positiveKeywords: _positiveKeywords,
      negativeKeywords: ['data emiterii', 'data eliberarii'],
      reason: ExtractionReasons.itpAnnexDate,
    );

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

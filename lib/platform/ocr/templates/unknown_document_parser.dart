import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/date_parser.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';

/// Generic fallback when no template matches confidently.
abstract final class UnknownDocumentParser {
  static const _expiryKeywords = [
    'valabil',
    'valabilitate',
    'pana la',
    'expira',
    'expirare',
    'itp',
    'rca',
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
      positiveKeywords: _expiryKeywords,
      negativeKeywords: const [],
      reason: ExtractionReasons.keywordScoredDate,
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

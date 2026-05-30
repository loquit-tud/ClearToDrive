import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/date_parser.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';

/// Insurer-issued RCA policy with free-form validity text.
abstract final class RcaPolicyParser {
  static const _validityKeywords = [
    'valabilitate',
    'valabil',
    'valabil de la',
    'perioada de valabilitate',
    'pana la',
    'până la',
    'sfarsit valabilitate',
    'sfârșit valabilitate',
    'data expirarii',
    'data expirării',
    'expira',
    'expirare',
  ];

  static const _avoidKeywords = [
    'data emiterii',
    'data emiterii polita',
    'data platii',
    'data plății',
    'data nasterii',
    'data nașterii',
    'de la',
    'inceput valabilitate',
    'început valabilitate',
  ];

  static TemplateParseResult parse(OcrExtractionContext ctx) {
    final rangeEnd = _extractRangeEnd(ctx);
    if (rangeEnd != null) {
      return TemplateParseResult(
        expiryDate: rangeEnd.date,
        licensePlate: PlateExtractor.extract(ctx.rawText),
        confidence: rangeEnd.confidence,
        expirySelectionReason: rangeEnd.reason,
        candidateFullDates: DateParser.allDatesInText(ctx.rawText),
        needsManualReview: rangeEnd.confidence < 0.7,
      );
    }

    final candidates = DateParser.collectDateCandidates(
      ctx.rawText,
      ctx.normalizedText,
    );
    final choice = DateParser.bestScoredCandidate(
      candidates: candidates,
      normalizedText: ctx.normalizedText,
      reference: ctx.referenceDate,
      positiveKeywords: _validityKeywords,
      negativeKeywords: _avoidKeywords,
      reason: ExtractionReasons.rcaPolicyValidityEnd,
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

  static DateChoice? _extractRangeEnd(OcrExtractionContext ctx) {
    final text = ctx.normalizedText;
    final dateSource = r'(\d{1,2}\s*[./-]\s*\d{1,2}\s*[./-]\s*\d{2,4})';
    final patterns = <RegExp>[
      RegExp(
        '(?:de\\s+la|valabil\\s+de\\s+la|from)\\D{0,50}$dateSource'
        '\\D{0,80}(?:pana\\s+la|până\\s+la|to)\\D{0,50}$dateSource',
      ),
      RegExp('$dateSource\\s*(?:-|–|—|pana\\s+la|până\\s+la|to)\\s*$dateSource'),
      RegExp(
        'valabilitate\\D{0,20}$dateSource\\s*(?:-|–|—)\\s*$dateSource',
      ),
    ];

    DateChoice? best;
    for (final pattern in patterns) {
      for (final match in pattern.allMatches(text)) {
        final end = DateParser.dateFromLooseDateText(match.group(2));
        if (end == null || end.isBefore(ctx.referenceDate)) continue;
        final choice = DateChoice(
          date: end,
          score: 340,
          confidence: 0.95,
          reason: ExtractionReasons.explicitRcaRange,
        );
        if (best == null || choice.date.isAfter(best.date)) best = choice;
      }
    }
    return best;
  }
}

import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';

class RomanianDocumentFieldExtractor implements DocumentFieldExtractor {
  const RomanianDocumentFieldExtractor();

  static final _datePatterns = <RegExp>[
    RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{4})\b'),
    RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b'),
  ];

  static final _expiryKeywords = <String>[
    'valabil',
    'valabil pana',
    'expira',
    'data expirarii',
  ];

  static final _itpKeywords = <String>['itp', 'inspectie tehnica'];

  @override
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) async {
    final rawText = ocrText.text;
    if (!ocrText.succeeded || rawText.trim().isEmpty) {
      return ExtractionResult(
        rawText: rawText,
        confidence: 0,
        needsManualReview: true,
      );
    }

    final normalizedText = _normalizeText(rawText);
    final suggestedType = _detectType(normalizedText);
    final plate = _extractPlate(rawText);
    final dateChoice = _extractExpiryDate(
      rawText,
      normalizedText,
      referenceDate: referenceDate,
    );

    return ExtractionResult(
      licensePlate: plate,
      expiryDate: dateChoice?.date,
      suggestedType: suggestedType,
      confidence: dateChoice?.confidence ?? (plate == null ? 0.35 : 0.55),
      rawText: rawText,
      needsManualReview:
          dateChoice == null || dateChoice.confidence < 0.7 || plate == null,
    );
  }

  DocumentType? _detectType(String normalizedText) {
    if (_itpKeywords.any(normalizedText.contains)) {
      return DocumentType.itp;
    }
    if (normalizedText.contains('rovinieta')) {
      return DocumentType.rovinieta;
    }
    if (normalizedText.contains('rca') ||
        normalizedText.contains('asigurare')) {
      return DocumentType.rca;
    }
    return null;
  }

  String? _extractPlate(String rawText) {
    final matches = RegExp(
      r'\b([A-Z]{1,2})[\s-]*(\d{2,3})[\s-]*([A-Z]{3})\b',
      caseSensitive: false,
    ).allMatches(rawText);

    for (final match in matches) {
      final normalized = LicensePlateValidator.normalize(
        '${match.group(1)} ${match.group(2)} ${match.group(3)}',
      );
      if (LicensePlateValidator.looksLikeRomanianPlate(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  _DateChoice? _extractExpiryDate(
    String rawText,
    String normalizedText, {
    DateTime? referenceDate,
  }) {
    final candidates = <_DateCandidate>[];
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(rawText)) {
        final date = _dateFromMatch(match);
        if (date == null) continue;
        candidates.add(_DateCandidate(date: date, index: match.start));
      }
    }

    if (candidates.isEmpty) return null;

    final reference = _dateOnly(referenceDate ?? DateTime.now());
    final hasFuture = candidates.any((c) => !c.date.isBefore(reference));
    final usable = hasFuture
        ? candidates.where((c) => !c.date.isBefore(reference)).toList()
        : candidates;

    _DateChoice? best;
    for (final candidate in usable) {
      final score = _scoreDateCandidate(candidate, normalizedText, reference);
      final choice = _DateChoice(
        date: candidate.date,
        score: score,
        confidence: _confidenceForScore(score),
      );
      if (best == null ||
          choice.score > best.score ||
          (choice.score == best.score && choice.date.isAfter(best.date))) {
        best = choice;
      }
    }
    return best;
  }

  DateTime? _dateFromMatch(RegExpMatch match) {
    final first = int.tryParse(match.group(1) ?? '');
    final second = int.tryParse(match.group(2) ?? '');
    final third = int.tryParse(match.group(3) ?? '');
    if (first == null || second == null || third == null) return null;

    final isYearFirst = (match.group(1) ?? '').length == 4;
    final year = isYearFirst ? first : third;
    final month = second;
    final day = isYearFirst ? third : first;

    if (year < 2000 || year > 2100 || month < 1 || month > 12) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  int _scoreDateCandidate(
    _DateCandidate candidate,
    String normalizedText,
    DateTime reference,
  ) {
    var score = candidate.date.isBefore(reference) ? -20 : 30;

    final windowStart = (candidate.index - 90)
        .clamp(0, normalizedText.length)
        .toInt();
    final windowEnd = (candidate.index + 90)
        .clamp(0, normalizedText.length)
        .toInt();
    final window = normalizedText.substring(windowStart, windowEnd);

    if (_expiryKeywords.any(window.contains)) {
      score += 100;
    }
    if (_itpKeywords.any(window.contains)) {
      score += 30;
    }
    if (_expiryKeywords.any(normalizedText.contains)) {
      score += 10;
    }
    return score;
  }

  double _confidenceForScore(int score) {
    if (score >= 130) return 0.9;
    if (score >= 70) return 0.7;
    if (score >= 30) return 0.55;
    return 0.35;
  }

  String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ş', 's')
        .replaceAll('ț', 't')
        .replaceAll('ţ', 't');
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _DateCandidate {
  const _DateCandidate({required this.date, required this.index});

  final DateTime date;
  final int index;
}

class _DateChoice {
  const _DateChoice({
    required this.date,
    required this.score,
    required this.confidence,
  });

  final DateTime date;
  final int score;
  final double confidence;
}

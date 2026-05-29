import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';

class RomanianDocumentFieldExtractor implements DocumentFieldExtractor {
  const RomanianDocumentFieldExtractor();

  static final _datePatterns = <RegExp>[
    RegExp(r'\b(\d{1,2})\s*[./,-]\s*(\d{1,2})\s*[./,-]\s*(\d{2,4})\b'),
    RegExp(r'\b(\d{4})\s*[./,-]\s*(\d{1,2})\s*[./,-]\s*(\d{1,2})\b'),
    RegExp(r'\b(\d{1,2})\s+(\d{1,2})\s+(\d{2,4})\b'),
    RegExp(r'\b(\d{4})\s+(\d{1,2})\s+(\d{1,2})\b'),
  ];

  static final _monthNamePattern = RegExp(
    r'\b(\d{1,2})\s+'
    r'(ianuarie|ian|februarie|feb|martie|mar|aprilie|apr|mai|iunie|iun|'
    r'iulie|iul|august|aug|septembrie|sep|octombrie|oct|noiembrie|noi|'
    r'decembrie|dec)'
    r'\s+(\d{2,4})\b',
  );

  static final _expiryKeywords = <String>[
    'valabil',
    'valabilitate',
    'valabil pana',
    'valabil pana la',
    'valid',
    'validitate',
    'pana la',
    'pana la to',
    'expira',
    'expirare',
    'data expirarii',
    'data limita',
    'termen',
    'scadenta',
    'urmatoarea inspectie',
    'urmatoarei inspectii',
    'urmatoarea inspectie tehnica',
    'urmatoarei inspectii tehnice',
    'urmatorul itp',
    'urmatoarea itp',
  ];

  static final _rcaKeywords = <String>[
    'rca',
    'carte internationala de asigurare',
    'asigurare',
    'insurance card',
    'autovehicul',
    'autovehicle',
  ];

  static final _itpKeywords = <String>[
    'itp',
    'i.t.p',
    'inspectie tehnica',
    'inspectie tehnica periodica',
    'inspectiei tehnice',
  ];

  static final _monthNumbers = <String, int>{
    'ianuarie': 1,
    'ian': 1,
    'februarie': 2,
    'feb': 2,
    'martie': 3,
    'mar': 3,
    'aprilie': 4,
    'apr': 4,
    'mai': 5,
    'iunie': 6,
    'iun': 6,
    'iulie': 7,
    'iul': 7,
    'august': 8,
    'aug': 8,
    'septembrie': 9,
    'sep': 9,
    'octombrie': 10,
    'oct': 10,
    'noiembrie': 11,
    'noi': 11,
    'decembrie': 12,
    'dec': 12,
  };

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
      typeHint: typeHint,
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
    if (_rcaKeywords.any(normalizedText.contains)) {
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
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) {
    final reference = _dateOnly(referenceDate ?? DateTime.now());
    final rcaGreenCardChoice = _extractRcaGreenCardExpiryDate(
      rawText,
      normalizedText,
      reference: reference,
      typeHint: typeHint,
    );
    if (rcaGreenCardChoice != null) return rcaGreenCardChoice;

    final candidates = <_DateCandidate>[];
    final dateScanText = _normalizeDateScanText(rawText);
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(dateScanText)) {
        final date = _dateFromMatch(match);
        if (date == null) continue;
        candidates.add(_DateCandidate(date: date, index: match.start));
      }
    }
    for (final match in _monthNamePattern.allMatches(normalizedText)) {
      final date = _dateFromMonthNameMatch(match);
      if (date == null) continue;
      candidates.add(_DateCandidate(date: date, index: match.start));
    }

    if (candidates.isEmpty) return null;

    final hasFuture = candidates.any((c) => !c.date.isBefore(reference));
    final usable = hasFuture
        ? candidates.where((c) => !c.date.isBefore(reference)).toList()
        : candidates;

    _DateChoice? best;
    for (final candidate in usable) {
      final score = _scoreDateCandidate(
        candidate,
        normalizedText,
        reference,
        typeHint: typeHint,
      );
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

  _DateChoice? _extractRcaGreenCardExpiryDate(
    String rawText,
    String normalizedText, {
    required DateTime reference,
    DocumentType? typeHint,
  }) {
    final looksLikeRca =
        typeHint == DocumentType.rca ||
        _rcaKeywords.any(normalizedText.contains) ||
        normalizedText.contains('de la') && normalizedText.contains('pana la');
    if (!looksLikeRca) return null;

    final scanText = _normalizeDateScanText(rawText);

    final rowMajorMatch = RegExp(
      r'\b(\d{1,2})\s+(\d{1,2})\s+(\d{4})\s+'
      r'(\d{1,2})\s+(\d{1,2})\s+(\d{4})\b',
    ).firstMatch(scanText);
    final rowMajorExpiry = _dateFromParts(
      day: rowMajorMatch?.group(4),
      month: rowMajorMatch?.group(5),
      year: rowMajorMatch?.group(6),
    );
    if (rowMajorExpiry != null && !rowMajorExpiry.isBefore(reference)) {
      return _DateChoice(date: rowMajorExpiry, score: 180, confidence: 0.9);
    }

    final columnMajorMatch = RegExp(
      r'\b(\d{1,2})\s+(\d{1,2})\s+'
      r'(\d{1,2})\s+(\d{1,2})\s+'
      r'(\d{4})\s+(\d{4})\b',
    ).firstMatch(scanText);
    final columnMajorExpiry = _dateFromParts(
      day: columnMajorMatch?.group(2),
      month: columnMajorMatch?.group(4),
      year: columnMajorMatch?.group(6),
    );
    if (columnMajorExpiry != null && !columnMajorExpiry.isBefore(reference)) {
      return _DateChoice(date: columnMajorExpiry, score: 180, confidence: 0.9);
    }

    final keywordMatch = RegExp(
      r'pana\s+la\D{0,40}(\d{1,2})\D+(\d{1,2})\D+(\d{4})',
    ).firstMatch(scanText);
    final keywordExpiry = _dateFromParts(
      day: keywordMatch?.group(1),
      month: keywordMatch?.group(2),
      year: keywordMatch?.group(3),
    );
    if (keywordExpiry != null && !keywordExpiry.isBefore(reference)) {
      return _DateChoice(date: keywordExpiry, score: 170, confidence: 0.85);
    }

    return null;
  }

  DateTime? _dateFromMatch(RegExpMatch match) {
    final first = int.tryParse(match.group(1) ?? '');
    final second = int.tryParse(match.group(2) ?? '');
    final third = int.tryParse(match.group(3) ?? '');
    if (first == null || second == null || third == null) return null;

    final isYearFirst = (match.group(1) ?? '').length == 4;
    var year = isYearFirst ? first : third;
    final rawYear = isYearFirst ? match.group(1) ?? '' : match.group(3) ?? '';
    if (!isYearFirst && rawYear.length == 2) {
      year += 2000;
    }
    final month = second;
    final day = isYearFirst ? third : first;

    if (year < 2000 || year > 2100 || month < 1 || month > 12) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  DateTime? _dateFromMonthNameMatch(RegExpMatch match) {
    final day = int.tryParse(match.group(1) ?? '');
    final month = _monthNumbers[match.group(2) ?? ''];
    var year = int.tryParse(match.group(3) ?? '');
    if (day == null || month == null || year == null) return null;
    if ((match.group(3) ?? '').length == 2) {
      year += 2000;
    }

    if (year < 2000 || year > 2100 || day < 1) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  DateTime? _dateFromParts({
    required String? day,
    required String? month,
    required String? year,
  }) {
    final parsedDay = int.tryParse(day ?? '');
    final parsedMonth = int.tryParse(month ?? '');
    final parsedYear = int.tryParse(year ?? '');
    if (parsedDay == null || parsedMonth == null || parsedYear == null) {
      return null;
    }
    if (parsedYear < 2000 ||
        parsedYear > 2100 ||
        parsedMonth < 1 ||
        parsedMonth > 12 ||
        parsedDay < 1) {
      return null;
    }

    final date = DateTime(parsedYear, parsedMonth, parsedDay);
    if (date.year != parsedYear ||
        date.month != parsedMonth ||
        date.day != parsedDay) {
      return null;
    }
    return date;
  }

  int _scoreDateCandidate(
    _DateCandidate candidate,
    String normalizedText,
    DateTime reference, {
    DocumentType? typeHint,
  }) {
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
    if (_rcaKeywords.any(window.contains)) {
      score += 30;
    }
    if (typeHint == DocumentType.rca &&
        _rcaKeywords.any(normalizedText.contains)) {
      score += 20;
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

  String _normalizeDateScanText(String input) {
    return _normalizeText(
      input,
    ).replaceAll('o', '0').replaceAll('i', '1').replaceAll('l', '1');
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

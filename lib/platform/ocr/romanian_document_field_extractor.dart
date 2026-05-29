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
    final suggestedType = _detectType(normalizedText, typeHint: typeHint);
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

  DocumentType? _detectType(String normalizedText, {DocumentType? typeHint}) {
    if (typeHint != null) return typeHint;
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
    final looksLikeRcaGreenCard = _looksLikeRcaGreenCard(
      normalizedText,
      typeHint: typeHint,
    );
    if (looksLikeRcaGreenCard) {
      return _extractRcaGreenCardExpiryDate(
        rawText,
        normalizedText,
        reference: reference,
      );
    }

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

  bool _looksLikeRcaGreenCard(String normalizedText, {DocumentType? typeHint}) {
    final looksLikeRca =
        typeHint == DocumentType.rca ||
        _rcaKeywords.any(normalizedText.contains);
    final hasValidityTable =
        normalizedText.contains('de la') &&
            normalizedText.contains('pana la') ||
        normalizedText.contains('from') && normalizedText.contains('to') ||
        normalizedText.contains('ziua') &&
            normalizedText.contains('luna') &&
            normalizedText.contains('anul');
    return looksLikeRca && hasValidityTable;
  }

  _DateChoice? _extractRcaGreenCardExpiryDate(
    String rawText,
    String normalizedText, {
    required DateTime reference,
  }) {
    final explicitRangeChoice = _extractExplicitRcaRangeExpiryDate(
      rawText,
      normalizedText,
      reference: reference,
    );
    if (explicitRangeChoice != null) return explicitRangeChoice;

    final scanText = _rcaValidityScanText(rawText, normalizedText);
    final tokens = _numericTokens(scanText);
    final years = tokens
        .where((token) => token.isYear)
        .map((token) => token.value!)
        .toList();
    final latestYear = years.isEmpty
        ? null
        : years.reduce((value, element) => value > element ? value : element);
    final choices = <_DateChoice>[];

    void addChoice(
      DateTime? date,
      int score,
      double confidence, {
      bool requireLatestYear = false,
    }) {
      if (date == null || date.isBefore(reference)) return;
      if (requireLatestYear &&
          (years.length < 2 || latestYear != null && date.year != latestYear)) {
        return;
      }
      choices.add(
        _DateChoice(date: date, score: score, confidence: confidence),
      );
    }

    for (var i = 0; i <= tokens.length - 6; i++) {
      final rowMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isYear &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isDayOrMonth &&
          tokens[i + 5].isYear;
      if (rowMajor) {
        addChoice(
          _dateFromParts(
            day: tokens[i + 3].text,
            month: tokens[i + 4].text,
            year: tokens[i + 5].text,
          ),
          230,
          0.95,
        );
      }

      final columnMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isDayOrMonth &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isYear &&
          tokens[i + 5].isYear;
      if (columnMajor) {
        addChoice(
          _dateFromParts(
            day: tokens[i + 1].text,
            month: tokens[i + 3].text,
            year: tokens[i + 5].text,
          ),
          230,
          0.95,
        );
      }
    }

    final keywordMatch = RegExp(
      r'pana\s+la\D{0,40}(\d{1,2})\D+(\d{1,2})\D+(\d{4})',
    ).firstMatch(scanText);
    addChoice(
      _dateFromParts(
        day: keywordMatch?.group(1),
        month: keywordMatch?.group(2),
        year: keywordMatch?.group(3),
      ),
      210,
      0.9,
      requireLatestYear: true,
    );

    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear) continue;
      addChoice(
        _dateFromParts(
          day: tokens[i - 2].text,
          month: tokens[i - 1].text,
          year: tokens[i].text,
        ),
        170,
        0.75,
        requireLatestYear: true,
      );
    }

    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear) continue;
      final singleDate = _dateFromParts(
        day: tokens[i - 2].text,
        month: tokens[i - 1].text,
        year: tokens[i].text,
      );
      if (singleDate == null || singleDate.year <= reference.year) continue;
      addChoice(singleDate, 150, 0.7);
    }

    if (choices.isEmpty) return null;
    choices.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.date.compareTo(a.date);
    });
    return choices.first;
  }

  _DateChoice? _extractExplicitRcaRangeExpiryDate(
    String rawText,
    String normalizedText, {
    required DateTime reference,
  }) {
    final validityRawText = _rcaValidityRawText(rawText, normalizedText);
    final validityNormalizedText = _normalizeText(validityRawText);
    final allDates = _allDatesInText(validityRawText);
    final hasIncompleteTwoColumnHeader =
        allDates.length < 2 && _hasRcaStartAndEndLabels(validityNormalizedText);
    final choices = <_DateChoice>[];

    void addChoice(DateTime? date, int score, double confidence) {
      if (date == null || date.isBefore(reference)) return;
      choices.add(
        _DateChoice(date: date, score: score, confidence: confidence),
      );
    }

    final dateSource = r'(\d{1,2}\s*[./-]\s*\d{1,2}\s*[./-]\s*\d{2,4})';
    final rangePatterns = <RegExp>[
      RegExp(
        '(?:de\\s+la|from)\\D{0,50}$dateSource'
        '\\D{0,80}(?:pana\\s+la|to)\\D{0,50}$dateSource',
      ),
      RegExp('$dateSource\\s*(?:-|–|—|pana\\s+la|to)\\s*$dateSource'),
    ];

    for (final pattern in rangePatterns) {
      for (final match in pattern.allMatches(validityNormalizedText)) {
        addChoice(_dateFromLooseDateText(match.group(2)), 340, 0.95);
      }
    }

    for (final match in RegExp(
      r'\b(?:pana\s+la|to)\b',
    ).allMatches(validityNormalizedText)) {
      if (match.group(0) == 'to' &&
          !_isRcaToKeyword(validityNormalizedText, match.start)) {
        continue;
      }
      if (hasIncompleteTwoColumnHeader) continue;

      final safeEnd = (match.start + 220)
          .clamp(0, validityRawText.length)
          .toInt();
      final window = validityRawText.substring(match.start, safeEnd);
      final tokens = _numericTokens(_normalizeDateScanText(window));
      addChoice(_greenCardExpiryFromTokens(tokens), 320, 0.93);
      addChoice(_firstDateInText(window), 300, 0.9);
    }

    if (allDates.length >= 2) {
      final futureDates = allDates
          .where((date) => !date.isBefore(reference))
          .toList();
      final usableDates = futureDates.isEmpty ? allDates : futureDates;
      usableDates.sort((a, b) => b.compareTo(a));
      addChoice(usableDates.first, 240, 0.82);
    }

    if (choices.isEmpty) return null;
    choices.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.date.compareTo(a.date);
    });
    return choices.first;
  }

  bool _hasRcaStartAndEndLabels(String text) {
    final hasStart = text.contains('de la') || text.contains('from');
    final hasEnd = text.contains('pana la') || RegExp(r'\bto\b').hasMatch(text);
    return hasStart && hasEnd;
  }

  bool _isRcaToKeyword(String text, int index) {
    final start = (index - 80).clamp(0, text.length).toInt();
    final end = (index + 80).clamp(0, text.length).toInt();
    final window = text.substring(start, end);
    return window.contains('pana') ||
        window.contains('from') ||
        window.contains('de la') ||
        window.contains('valid') ||
        window.contains('ziua') ||
        window.contains('luna') ||
        window.contains('anul');
  }

  DateTime? _greenCardExpiryFromTokens(List<_NumericToken> tokens) {
    for (var i = 0; i <= tokens.length - 6; i++) {
      final rowMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isYear &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isDayOrMonth &&
          tokens[i + 5].isYear;
      if (rowMajor) {
        return _dateFromParts(
          day: tokens[i + 3].text,
          month: tokens[i + 4].text,
          year: tokens[i + 5].text,
        );
      }

      final columnMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isDayOrMonth &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isYear &&
          tokens[i + 5].isYear;
      if (columnMajor) {
        return _dateFromParts(
          day: tokens[i + 1].text,
          month: tokens[i + 3].text,
          year: tokens[i + 5].text,
        );
      }
    }

    return _firstDateFromNumericTokens(tokens);
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

  DateTime? _dateFromLooseDateText(String? text) {
    if (text == null) return null;
    final scanText = _normalizeDateScanText(text);
    for (final pattern in _datePatterns) {
      final match = pattern.firstMatch(scanText);
      if (match == null) continue;
      final date = _dateFromMatch(match);
      if (date != null) return date;
    }
    return null;
  }

  DateTime? _firstDateInText(String text) {
    final scanText = _normalizeDateScanText(text);
    for (final pattern in _datePatterns) {
      final match = pattern.firstMatch(scanText);
      if (match == null) continue;
      final date = _dateFromMatch(match);
      if (date != null) return date;
    }
    return _firstDateFromNumericTokens(_numericTokens(scanText));
  }

  DateTime? _firstDateFromNumericTokens(List<_NumericToken> tokens) {
    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear ||
          !tokens[i - 2].isDayOrMonth ||
          !tokens[i - 1].isDayOrMonth) {
        continue;
      }
      final date = _dateFromParts(
        day: tokens[i - 2].text,
        month: tokens[i - 1].text,
        year: tokens[i].text,
      );
      if (date != null) return date;
    }
    return null;
  }

  List<DateTime> _allDatesInText(String text) {
    final dates = <DateTime>[];
    final seen = <String>{};

    void add(DateTime? date) {
      if (date == null) return;
      final key = '${date.year}-${date.month}-${date.day}';
      if (seen.add(key)) dates.add(date);
    }

    final scanText = _normalizeDateScanText(text);
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(scanText)) {
        add(_dateFromMatch(match));
      }
    }

    final tokens = _numericTokens(scanText);
    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear ||
          !tokens[i - 2].isDayOrMonth ||
          !tokens[i - 1].isDayOrMonth) {
        continue;
      }
      add(
        _dateFromParts(
          day: tokens[i - 2].text,
          month: tokens[i - 1].text,
          year: tokens[i].text,
        ),
      );
    }
    return dates;
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
    return _normalizeText(input)
        .replaceAll('o', '0')
        .replaceAll('i', '1')
        .replaceAll('l', '1')
        .replaceAll('s', '5');
  }

  String _rcaValidityScanText(String rawText, String normalizedText) {
    return _normalizeDateScanText(_rcaValidityRawText(rawText, normalizedText));
  }

  String _rcaValidityRawText(String rawText, String normalizedText) {
    final start = _firstKeywordIndex(normalizedText, [
      'valabil',
      'valid',
      'de la',
      'from',
      'ziua',
    ]);
    if (start < 0) return rawText;

    final safeStart = start.clamp(0, rawText.length).toInt();
    final safeEnd = (safeStart + 600).clamp(0, rawText.length).toInt();
    return rawText.substring(safeStart, safeEnd);
  }

  int _firstKeywordIndex(String text, List<String> keywords) {
    final indexes =
        keywords.map(text.indexOf).where((index) => index >= 0).toList()
          ..sort();
    if (indexes.isEmpty) return -1;
    return indexes.first;
  }

  List<_NumericToken> _numericTokens(String text) {
    return RegExp(r'\b\d{1,4}\b')
        .allMatches(text)
        .map((match) => _NumericToken(match.group(0)!, match.start))
        .toList();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _NumericToken {
  const _NumericToken(this.text, this.index);

  final String text;
  final int index;

  int? get value => int.tryParse(text);

  bool get isYear {
    final parsed = value;
    return text.length == 4 &&
        parsed != null &&
        parsed >= 2000 &&
        parsed <= 2100;
  }

  bool get isDayOrMonth {
    final parsed = value;
    return text.length <= 2 && parsed != null && parsed >= 1 && parsed <= 31;
  }
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

/// Pure Dart parsing of Romanian vehicle document OCR text.
library;

/// A date token found in OCR text with its source span.
class ParsedDateCandidate {
  const ParsedDateCandidate({
    required this.date,
    required this.start,
    required this.end,
    required this.raw,
    required this.format,
  });

  final DateTime date;
  final int start;
  final int end;
  final String raw;
  final String format;
}

/// Result of RCA expiry extraction from OCR text.
class RcaExpiryParseResult {
  const RcaExpiryParseResult({
    this.expiryDate,
    this.confidence = 0,
    this.selectionReason = 'none',
    this.allDates = const [],
    this.lowConfidence = true,
  });

  final DateTime? expiryDate;
  final double confidence;
  final String selectionReason;
  final List<ParsedDateCandidate> allDates;
  final bool lowConfidence;

  bool get detected => expiryDate != null;
}

/// Parses Romanian RCA / insurance OCR text for expiry (end of validity).
class RomanianDocumentParser {
  RomanianDocumentParser({DateTime? referenceNow})
      : _referenceNow = _dateOnly(referenceNow ?? DateTime.now());

  final DateTime _referenceNow;

  static final _datePatterns = <_DatePattern>[
    _DatePattern(
      name: 'dd.MM.yyyy',
      regex: RegExp(r'\b(\d{2})\.(\d{2})\.(\d{4})\b'),
      parse: (m) => _safeDate(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!)),
    ),
    _DatePattern(
      name: 'dd/MM/yyyy',
      regex: RegExp(r'\b(\d{2})/(\d{2})/(\d{4})\b'),
      parse: (m) => _safeDate(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!)),
    ),
    _DatePattern(
      name: 'dd-MM-yyyy',
      regex: RegExp(r'\b(\d{2})-(\d{2})-(\d{4})\b'),
      parse: (m) => _safeDate(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!)),
    ),
    _DatePattern(
      name: 'yyyy-MM-dd',
      regex: RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b'),
      parse: (m) => _safeDate(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!)),
    ),
  ];

  static final _validityRangePatterns = <_RangeRule>[
    _RangeRule(
      name: 'valabilitate_colon_dash',
      regex: RegExp(
        r'valabilitate\s*:?\s*'
        r'(\d{2}[./-]\d{2}[./-]\d{4})\s*[-–]\s*'
        r'(\d{2}[./-]\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ),
    _RangeRule(
      name: 'perioada_valabilitate_de_la',
      regex: RegExp(
        r'perioada\s+de\s+valabilitate\s*:?\s*'
        r'de\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})\s+'
        r'(?:pana|pană|până)\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ),
    _RangeRule(
      name: 'de_la_pana_la',
      regex: RegExp(
        r'de\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})\s+'
        r'(?:pana|pană|până)\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ),
    _RangeRule(
      name: 'valabil_de_la',
      regex: RegExp(
        r'valabil(?:a)?\s+de\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})\s+'
        r'(?:pana|pană|până)\s+la\s+(\d{2}[./-]\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ),
    _RangeRule(
      name: 'generic_dash_near_valabilitate',
      regex: RegExp(
        r'valabilitat\w{0,6}[^0-9]{0,40}'
        r'(\d{2}[./-]\d{2}[./-]\d{4})\s*[-–]\s*'
        r'(\d{2}[./-]\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ),
  ];

  static const _rcaKeywords = [
    'rca',
    'asigurare',
    'asigurarea',
    'polita',
    'poliță',
    'polita',
    'valabilitate',
    'valabil',
    'valabil de la',
    'pana la',
    'până la',
    'perioada de valabilitate',
    'inceput valabilitate',
    'început valabilitate',
    'sfarsit valabilitate',
    'sfârșit valabilitate',
    'data expirarii',
    'data expirării',
  ];

  static const _excludeKeywords = [
    'emitere',
    'emis',
    'emisa',
    'data emiterii',
    'data nasterii',
    'data nașterii',
    'nastere',
    'naștere',
    'inceput valabilitate',
    'început valabilitate',
    'start valabilitate',
    'de la ',
  ];

  static const _endKeywords = [
    'sfarsit valabilitate',
    'sfârșit valabilitate',
    'pana la',
    'până la',
    'data expirarii',
    'data expirării',
    'expira',
    'expirare',
  ];

  /// Extracts RCA expiry (end of validity) from [rawText].
  RcaExpiryParseResult parseRcaExpiry(String rawText) {
    if (rawText.trim().isEmpty) {
      return const RcaExpiryParseResult(
        selectionReason: 'empty_text',
        lowConfidence: true,
      );
    }

    final normalized = _normalize(rawText);
    final allDates = _findAllDates(normalized);

    for (final rule in _validityRangePatterns) {
      final match = rule.regex.firstMatch(normalized);
      if (match == null) continue;
      final endRaw = match.group(2)!;
      final endDate = _parseFlexibleDate(endRaw);
      if (endDate != null) {
        return RcaExpiryParseResult(
          expiryDate: endDate,
          confidence: 0.92,
          selectionReason: '${rule.name}:end_of_range',
          allDates: allDates,
          lowConfidence: false,
        );
      }
    }

    final inceputSfarsit = _parseInceputSfarsit(normalized, allDates);
    if (inceputSfarsit != null) {
      return inceputSfarsit;
    }

    final keywordPick = _pickByKeywordProximity(normalized, allDates);
    if (keywordPick != null) {
      return keywordPick;
    }

    final singleFuture = _pickSingleFutureExpiryLike(normalized, allDates);
    if (singleFuture != null) {
      return singleFuture;
    }

    return RcaExpiryParseResult(
      allDates: allDates,
      selectionReason: 'no_match',
      lowConfidence: true,
    );
  }

  RcaExpiryParseResult? _parseInceputSfarsit(
    String normalized,
    List<ParsedDateCandidate> allDates,
  ) {
    final startIdx = normalized.indexOf('inceput valabilitate');
    final endIdx = normalized.indexOf('sfarsit valabilitate');
    if (startIdx < 0 && endIdx < 0) return null;

    final searchFrom = endIdx >= 0 ? endIdx : startIdx;
    final window = normalized.substring(
      searchFrom,
      (searchFrom + 120).clamp(0, normalized.length),
    );
    final datesInWindow = _findAllDates(window);
    if (datesInWindow.isEmpty && allDates.length >= 2) {
      final sorted = List<ParsedDateCandidate>.from(allDates)
        ..sort((a, b) => a.start.compareTo(b.start));
      final endDate = sorted.last.date;
      return RcaExpiryParseResult(
        expiryDate: endDate,
        confidence: 0.75,
        selectionReason: 'inceput_sfarsit:last_date',
        allDates: allDates,
        lowConfidence: true,
      );
    }
    if (datesInWindow.isNotEmpty) {
      final endDate = datesInWindow.last.date;
      return RcaExpiryParseResult(
        expiryDate: endDate,
        confidence: 0.8,
        selectionReason: 'inceput_sfarsit:window_end',
        allDates: allDates,
        lowConfidence: false,
      );
    }
    return null;
  }

  RcaExpiryParseResult? _pickByKeywordProximity(
    String normalized,
    List<ParsedDateCandidate> allDates,
  ) {
    if (allDates.isEmpty) return null;

    final futureDates = allDates
        .where((d) => !_isBeforeReference(d.date))
        .where((d) => !_isExcludedContext(normalized, d))
        .toList();
    if (futureDates.isEmpty) return null;

    var best = futureDates.first;
    var bestScore = -1.0;

    for (final candidate in futureDates) {
      final score = _keywordScore(normalized, candidate);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    if (bestScore <= 0) return null;

    return RcaExpiryParseResult(
      expiryDate: best.date,
      confidence: bestScore >= 2 ? 0.78 : 0.55,
      selectionReason: 'keyword_proximity:score=$bestScore',
      allDates: allDates,
      lowConfidence: bestScore < 2,
    );
  }

  RcaExpiryParseResult? _pickSingleFutureExpiryLike(
    String normalized,
    List<ParsedDateCandidate> allDates,
  ) {
    final candidates = allDates
        .where((d) => !_isBeforeReference(d.date))
        .where((d) => !_isExcludedContext(normalized, d))
        .toList();

    if (candidates.length != 1) return null;

    final only = candidates.first;
    final nearValidity = _hasNearbyKeyword(normalized, only.start, _rcaKeywords);
    if (!nearValidity && !_textMentionsRca(normalized)) {
      return null;
    }

    return RcaExpiryParseResult(
      expiryDate: only.date,
      confidence: nearValidity ? 0.65 : 0.45,
      selectionReason: 'single_future_date',
      allDates: allDates,
      lowConfidence: true,
    );
  }

  List<ParsedDateCandidate> _findAllDates(String text) {
    final found = <ParsedDateCandidate>[];
    for (final pattern in _datePatterns) {
      for (final match in pattern.regex.allMatches(text)) {
        final date = pattern.parse(match);
        if (date == null) continue;
        found.add(
          ParsedDateCandidate(
            date: date,
            start: match.start,
            end: match.end,
            raw: match.group(0)!,
            format: pattern.name,
          ),
        );
      }
    }
    found.sort((a, b) => a.start.compareTo(b.start));
    return _dedupeDates(found);
  }

  List<ParsedDateCandidate> _dedupeDates(List<ParsedDateCandidate> input) {
    final seen = <String>{};
    final out = <ParsedDateCandidate>[];
    for (final d in input) {
      final key = '${d.date.year}-${d.date.month}-${d.date.day}@${d.start}';
      if (seen.add(key)) out.add(d);
    }
    return out;
  }

  double _keywordScore(String text, ParsedDateCandidate candidate) {
    var score = 0.0;
    const window = 80;
    final start = (candidate.start - window).clamp(0, text.length);
    final end = (candidate.end + window).clamp(0, text.length);
    final slice = text.substring(start, end);

    for (final kw in _rcaKeywords) {
      if (slice.contains(kw)) score += 1;
    }
    for (final kw in _endKeywords) {
      if (slice.contains(kw)) score += 1.5;
    }
    if (_textMentionsRca(text)) score += 0.5;
    return score;
  }

  bool _textMentionsRca(String text) =>
      text.contains('rca') ||
      text.contains('asigurare') ||
      text.contains('polita') ||
      text.contains('poliță');

  bool _hasNearbyKeyword(String text, int index, List<String> keywords) {
    const window = 60;
    final start = (index - window).clamp(0, text.length);
    final end = (index + window).clamp(0, text.length);
    final slice = text.substring(start, end);
    return keywords.any(slice.contains);
  }

  bool _isExcludedContext(String text, ParsedDateCandidate candidate) {
    const window = 50;
    final start = (candidate.start - window).clamp(0, text.length);
    final end = (candidate.end + window).clamp(0, text.length);
    final slice = text.substring(start, end);

    for (final kw in _excludeKeywords) {
      if (!slice.contains(kw)) continue;
      // "de la" alone is only excluded when paired with start-of-validity context.
      if (kw == 'de la ' && !_isStartValidityContext(slice)) continue;
      return true;
    }
    return false;
  }

  bool _isStartValidityContext(String slice) =>
      slice.contains('inceput valabilitate') ||
      slice.contains('început valabilitate') ||
      slice.contains('valabil de la');

  bool _isBeforeReference(DateTime date) =>
      date.isBefore(_referenceNow.subtract(const Duration(days: 1)));

  static String _normalize(String text) {
    var s = text.toLowerCase();
    const replacements = {
      'ă': 'a',
      'â': 'a',
      'î': 'i',
      'ș': 's',
      'ş': 's',
      'ț': 't',
      'ţ': 't',
      'á': 'a',
      'é': 'e',
    };
    for (final e in replacements.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  static DateTime? _parseFlexibleDate(String raw) {
    final cleaned = raw.trim();
    for (final pattern in _datePatterns) {
      final m = pattern.regex.firstMatch(cleaned);
      if (m != null) return pattern.parse(m);
    }
    return null;
  }

  static DateTime? _safeDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    try {
      return DateTime(year, month, day);
    } on Object {
      return null;
    }
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class _DatePattern {
  const _DatePattern({
    required this.name,
    required this.regex,
    required this.parse,
  });

  final String name;
  final RegExp regex;
  final DateTime? Function(RegExpMatch match) parse;
}

class _RangeRule {
  const _RangeRule({required this.name, required this.regex});

  final String name;
  final RegExp regex;
}

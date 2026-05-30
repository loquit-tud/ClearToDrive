import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/text_normalizer.dart';

class NumericToken {
  const NumericToken(this.text, this.index);

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

class DateCandidate {
  const DateCandidate({required this.date, required this.index});

  final DateTime date;
  final int index;
}

/// Shared date tokenization and parsing for all document templates.
abstract final class DateParser {
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

  static const _monthNumbers = <String, int>{
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

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static List<NumericToken> numericTokens(String text) {
    return RegExp(r'\b\d{1,4}\b')
        .allMatches(text)
        .map((match) => NumericToken(match.group(0)!, match.start))
        .toList();
  }

  static DateTime? dateFromParts({
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

  static DateTime? dateFromMatch(RegExpMatch match) {
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

  static DateTime? dateFromMonthNameMatch(RegExpMatch match) {
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

  static DateTime? dateFromLooseDateText(String? text) {
    if (text == null) return null;
    final scanText = TextNormalizer.normalizeForDateScan(text);
    for (final pattern in _datePatterns) {
      final match = pattern.firstMatch(scanText);
      if (match == null) continue;
      final date = dateFromMatch(match);
      if (date != null) return date;
    }
    return null;
  }

  static List<DateTime> allDatesInText(String text) {
    final dates = <DateTime>[];
    final seen = <String>{};

    void add(DateTime? date) {
      if (date == null) return;
      final key = '${date.year}-${date.month}-${date.day}';
      if (seen.add(key)) dates.add(date);
    }

    final scanText = TextNormalizer.normalizeForDateScan(text);
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(scanText)) {
        add(dateFromMatch(match));
      }
    }

    final tokens = numericTokens(scanText);
    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear ||
          !tokens[i - 2].isDayOrMonth ||
          !tokens[i - 1].isDayOrMonth) {
        continue;
      }
      add(
        dateFromParts(
          day: tokens[i - 2].text,
          month: tokens[i - 1].text,
          year: tokens[i].text,
        ),
      );
    }
    return dates;
  }

  static List<DateCandidate> collectDateCandidates(
    String rawText,
    String normalizedText,
  ) {
    final candidates = <DateCandidate>[];
    final dateScanText = TextNormalizer.normalizeForDateScan(rawText);
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(dateScanText)) {
        final date = dateFromMatch(match);
        if (date == null) continue;
        candidates.add(DateCandidate(date: date, index: match.start));
      }
    }
    for (final match in _monthNamePattern.allMatches(normalizedText)) {
      final date = dateFromMonthNameMatch(match);
      if (date == null) continue;
      candidates.add(DateCandidate(date: date, index: match.start));
    }
    return candidates;
  }

  static DateTime? fragmentedDateNearKeyword(String window) {
    final tokens = numericTokens(TextNormalizer.normalizeForDateScan(window));
    for (var i = 0; i <= tokens.length - 3; i++) {
      if (tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isYear) {
        final date = dateFromParts(
          day: tokens[i].text,
          month: tokens[i + 1].text,
          year: tokens[i + 2].text,
        );
        if (date != null) return date;
      }
      if (tokens[i].isYear &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isDayOrMonth) {
        final date = dateFromParts(
          day: tokens[i + 2].text,
          month: tokens[i + 1].text,
          year: tokens[i].text,
        );
        if (date != null) return date;
      }
    }
    return null;
  }

  static double confidenceForScore(int score) {
    if (score >= 130) return 0.9;
    if (score >= 70) return 0.7;
    if (score >= 30) return 0.55;
    return 0.35;
  }

  static DateChoice? bestScoredCandidate({
    required List<DateCandidate> candidates,
    required String normalizedText,
    required DateTime reference,
    required List<String> positiveKeywords,
    required List<String> negativeKeywords,
    required String reason,
  }) {
    if (candidates.isEmpty) return null;

    final hasFuture = candidates.any((c) => !c.date.isBefore(reference));
    final usable = hasFuture
        ? candidates.where((c) => !c.date.isBefore(reference)).toList()
        : candidates;

    DateChoice? best;
    for (final candidate in usable) {
      var score = candidate.date.isBefore(reference) ? -20 : 30;
      final windowStart = (candidate.index - 90)
          .clamp(0, normalizedText.length)
          .toInt();
      final windowEnd = (candidate.index + 90)
          .clamp(0, normalizedText.length)
          .toInt();
      final window = normalizedText.substring(windowStart, windowEnd);

      if (positiveKeywords.any(window.contains)) score += 100;
      if (negativeKeywords.any(window.contains)) score -= 80;
      if (positiveKeywords.any(normalizedText.contains)) score += 10;

      final choice = DateChoice(
        date: candidate.date,
        score: score,
        confidence: confidenceForScore(score),
        reason: reason,
      );
      if (best == null ||
          choice.score > best.score ||
          (choice.score == best.score && choice.date.isAfter(best.date))) {
        best = choice;
      }
    }
    return best;
  }
}

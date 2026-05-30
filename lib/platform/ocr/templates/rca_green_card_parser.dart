import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/date_parser.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';
import 'package:cleartodrive/platform/ocr/parsing/text_normalizer.dart';

/// BAAR Carte Verde / International Motor Insurance Card field 3 validity parser.
abstract final class RcaGreenCardParser {
  static TemplateParseResult parse(OcrExtractionContext ctx) {
    final tableDates = _findExplicitGreenCardTableDates(
      ctx.correctedText,
      ctx.normalizedText,
    );
    final startDate =
        tableDates?.from ??
        _findFullStartDateNearDeLa(ctx.correctedText, ctx.normalizedText);
    final toYears = _findYearsNearPanaLa(ctx.correctedText, ctx.normalizedText);
    final choice = _extractExpiry(ctx);

    return TemplateParseResult(
      expiryDate: choice?.date,
      licensePlate: PlateExtractor.extract(ctx.correctedText),
      confidence: choice?.confidence,
      expirySelectionReason: choice?.reason,
      candidateFullDates: DateParser.allDatesInText(
        ctx.correctedText,
      ).where((d) => !_isMisalignedGreenCardTokenDate(d, startDate)).toList(),
      candidateToYears: toYears,
      detectedFromDate: startDate,
      detectedToYear: _selectToYearForInference(startDate, toYears),
      needsManualReview: choice == null || (choice.confidence < 0.7),
    );
  }

  static int? _selectToYearForInference(
    DateTime? startDate,
    List<int> toYears,
  ) {
    if (startDate == null || toYears.isEmpty) return null;
    final valid = toYears
        .where(
          (y) =>
              y >= startDate.year &&
              y <= startDate.year + 2 &&
              y > startDate.year,
        )
        .toList();
    if (valid.isEmpty) return null;
    // Years are collected in reading order from the PANA LA / TO area onward.
    // Prefer the nearest valid TO year instead of the maximum year, because
    // real OCR often includes unrelated footer/batch years after the validity
    // area.
    return valid.first;
  }

  static DateChoice? _extractExpiry(OcrExtractionContext ctx) {
    final reference = ctx.referenceDate;
    final tableDates = _findExplicitGreenCardTableDates(
      ctx.correctedText,
      ctx.normalizedText,
    );
    if (tableDates?.to != null && !tableDates!.to.isBefore(reference)) {
      return DateChoice(
        date: tableDates.to,
        score: 360,
        confidence: 0.96,
        reason: 'green_card_to_day_month_year',
      );
    }

    final explicit = _extractExplicitRange(ctx, reference);
    if (explicit != null) return explicit;

    final startDate =
        tableDates?.from ??
        _findFullStartDateNearDeLa(ctx.correctedText, ctx.normalizedText);
    final lacksFullTo =
        startDate != null &&
        _hasStartAndEndLabels(ctx.normalizedText) &&
        !_hasFullToExpiryDate(ctx.correctedText, ctx.normalizedText, startDate);

    if (lacksFullTo) {
      return _inferFromToYear(ctx, reference, startDate);
    }

    final scanText = _rcaValidityScanText(
      ctx.correctedText,
      ctx.normalizedText,
    );
    final tokens = DateParser.numericTokens(scanText);
    final years = tokens.where((t) => t.isYear).map((t) => t.value!).toList();
    final latestYear = years.isEmpty
        ? null
        : years.reduce((a, b) => a > b ? a : b);
    final choices = <DateChoice>[];
    final hasValidityLabels = _hasStartAndEndLabels(ctx.normalizedText);

    void addChoice(
      DateTime? date,
      int score,
      double confidence, {
      bool requireLatestYear = false,
      String? reason,
    }) {
      if (date == null || date.isBefore(reference)) return;
      if (requireLatestYear &&
          years.length >= 2 &&
          latestYear != null &&
          date.year != latestYear) {
        return;
      }
      choices.add(
        DateChoice(
          date: date,
          score: score,
          confidence: confidence,
          reason: reason,
        ),
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
          DateParser.dateFromParts(
            day: tokens[i + 3].text,
            month: tokens[i + 4].text,
            year: tokens[i + 5].text,
          ),
          230,
          0.95,
          reason: ExtractionReasons.rcaToTable,
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
          DateParser.dateFromParts(
            day: tokens[i + 1].text,
            month: tokens[i + 3].text,
            year: tokens[i + 5].text,
          ),
          230,
          0.95,
          reason: ExtractionReasons.rcaToTable,
        );
      }
    }

    final keywordMatch = RegExp(
      r'pana\s+la\D{0,40}(\d{1,2})\D+(\d{1,2})\D+(\d{4})',
    ).firstMatch(scanText);
    addChoice(
      DateParser.dateFromParts(
        day: keywordMatch?.group(1),
        month: keywordMatch?.group(2),
        year: keywordMatch?.group(3),
      ),
      210,
      0.9,
      requireLatestYear: true,
      reason: ExtractionReasons.rcaPanaLaFullDate,
    );

    for (var i = 2; i < tokens.length; i++) {
      if (!tokens[i].isYear) continue;
      addChoice(
        DateParser.dateFromParts(
          day: tokens[i - 2].text,
          month: tokens[i - 1].text,
          year: tokens[i].text,
        ),
        170,
        0.75,
        requireLatestYear: true,
        reason: ExtractionReasons.rcaToYearTriplet,
      );
    }

    if (choices.isNotEmpty) {
      choices.sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return b.date.compareTo(a.date);
      });
      final best = choices.first;
      final startDate = _findFullStartDateNearDeLa(
        ctx.correctedText,
        ctx.normalizedText,
      );
      if (startDate != null &&
          hasValidityLabels &&
          DateParser.dateOnly(best.date) == DateParser.dateOnly(startDate)) {
        // Fall through to inference.
      } else {
        return best;
      }
    }

    return _inferFromToYear(ctx, reference, startDate);
  }

  static DateChoice? _inferFromToYear(
    OcrExtractionContext ctx,
    DateTime reference,
    DateTime? startDate,
  ) {
    if (ctx.typeHint != DocumentType.rca) return null;
    if (!_hasStartAndEndLabels(ctx.normalizedText)) return null;

    startDate ??= _findFullStartDateNearDeLa(
      ctx.correctedText,
      ctx.normalizedText,
    );
    if (startDate == null) return null;
    if (_hasFullToExpiryDate(
      ctx.correctedText,
      ctx.normalizedText,
      startDate,
    )) {
      return null;
    }

    final toYears = _findYearsNearPanaLa(ctx.correctedText, ctx.normalizedText);
    final toYear = _selectToYearForInference(startDate, toYears);
    if (toYear == null) return null;

    final inferred = DateTime(toYear, startDate.month, startDate.day);
    if (inferred.isBefore(reference)) return null;

    return DateChoice(
      date: inferred,
      score: 180,
      confidence: 0.65,
      reason: ExtractionReasons.greenCardToYearWithFromDayMonth,
    );
  }

  static DateChoice? _extractExplicitRange(
    OcrExtractionContext ctx,
    DateTime reference,
  ) {
    final validityRaw = _rcaValidityRawText(
      ctx.correctedText,
      ctx.normalizedText,
    );
    final validityNorm = TextNormalizer.normalize(validityRaw);
    final startDate = _findFullStartDateNearDeLa(
      ctx.correctedText,
      ctx.normalizedText,
    );
    final lacksFullTo =
        startDate != null &&
        _hasStartAndEndLabels(validityNorm) &&
        !_hasFullToExpiryDate(ctx.correctedText, ctx.normalizedText, startDate);
    final allDates = DateParser.allDatesInText(
      validityRaw,
    ).where((d) => !_isMisalignedGreenCardTokenDate(d, startDate)).toList();
    final choices = <DateChoice>[];

    void add(DateTime? date, int score, double confidence, {String? reason}) {
      if (date == null || date.isBefore(reference)) return;
      choices.add(
        DateChoice(
          date: date,
          score: score,
          confidence: confidence,
          reason: reason ?? ExtractionReasons.explicitRcaRange,
        ),
      );
    }

    final dateSource = r'(\d{1,2}\s*[./-]\s*\d{1,2}\s*[./-]\s*\d{2,4})';
    final rangePatterns = <RegExp>[
      RegExp(
        '(?:de\\s+la|from)\\D{0,50}$dateSource'
        '\\D{0,80}(?:pana\\s*la|to)\\D{0,50}$dateSource',
      ),
      RegExp('$dateSource\\s*(?:-|–|—|pana\\s*la|to)\\s*$dateSource'),
    ];

    for (final pattern in rangePatterns) {
      for (final match in pattern.allMatches(validityNorm)) {
        add(DateParser.dateFromLooseDateText(match.group(2)), 340, 0.95);
      }
    }

    if (!lacksFullTo) {
      for (final match in RegExp(
        r'\b(?:pana\s*la|to)\b',
      ).allMatches(validityNorm)) {
        if (match.group(0) == 'to' &&
            !_isRcaToKeyword(validityNorm, match.start)) {
          continue;
        }
        final safeEnd = (match.start + 220)
            .clamp(0, validityRaw.length)
            .toInt();
        final window = validityRaw.substring(match.start, safeEnd);
        final tokens = DateParser.numericTokens(
          TextNormalizer.normalizeForDateScan(window),
        );
        add(_structuredDateFromTokens(tokens), 320, 0.93);
      }
    }

    if (allDates.length >= 2 && !lacksFullTo) {
      final future = allDates.where((d) => !d.isBefore(reference)).toList();
      final usable = future.isEmpty ? allDates : future;
      usable.sort((a, b) => b.compareTo(a));
      add(usable.first, 240, 0.82);
    }

    if (choices.isEmpty) return null;
    choices.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      return b.date.compareTo(a.date);
    });
    final best = choices.first;
    if (startDate != null &&
        DateParser.dateOnly(best.date) == DateParser.dateOnly(startDate)) {
      return null;
    }
    return best;
  }

  static _GreenCardTableDates? _findExplicitGreenCardTableDates(
    String rawText,
    String normalizedText,
  ) {
    if (!_hasStartAndEndLabels(normalizedText)) return null;

    final tokens = DateParser.numericTokens(
      _rcaValidityScanText(rawText, normalizedText),
    );
    for (var i = 0; i <= tokens.length - 6; i++) {
      final rowMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isYear &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isDayOrMonth &&
          tokens[i + 5].isYear;
      if (rowMajor) {
        final from = DateParser.dateFromParts(
          day: tokens[i].text,
          month: tokens[i + 1].text,
          year: tokens[i + 2].text,
        );
        final to = DateParser.dateFromParts(
          day: tokens[i + 3].text,
          month: tokens[i + 4].text,
          year: tokens[i + 5].text,
        );
        if (from != null && to != null && to.isAfter(from)) {
          return _GreenCardTableDates(from: from, to: to);
        }
      }

      final columnMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isDayOrMonth &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isYear &&
          tokens[i + 5].isYear;
      if (columnMajor) {
        final from = DateParser.dateFromParts(
          day: tokens[i].text,
          month: tokens[i + 2].text,
          year: tokens[i + 4].text,
        );
        final to = DateParser.dateFromParts(
          day: tokens[i + 1].text,
          month: tokens[i + 3].text,
          year: tokens[i + 5].text,
        );
        if (from != null && to != null && to.isAfter(from)) {
          return _GreenCardTableDates(from: from, to: to);
        }
      }
    }
    return null;
  }

  static DateTime? _structuredDateFromTokens(List<NumericToken> tokens) {
    for (var i = 0; i <= tokens.length - 6; i++) {
      final rowMajor =
          tokens[i].isDayOrMonth &&
          tokens[i + 1].isDayOrMonth &&
          tokens[i + 2].isYear &&
          tokens[i + 3].isDayOrMonth &&
          tokens[i + 4].isDayOrMonth &&
          tokens[i + 5].isYear;
      if (rowMajor) {
        return DateParser.dateFromParts(
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
        return DateParser.dateFromParts(
          day: tokens[i + 1].text,
          month: tokens[i + 3].text,
          year: tokens[i + 5].text,
        );
      }
    }
    return null;
  }

  static bool _hasStartAndEndLabels(String text) {
    final hasStart = text.contains('de la') || text.contains('from');
    final hasEnd = text.contains('pana la') || RegExp(r'\bto\b').hasMatch(text);
    return hasStart && hasEnd;
  }

  static bool _isRcaToKeyword(String text, int index) {
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

  static bool _isMisalignedGreenCardTokenDate(
    DateTime date,
    DateTime? startDate,
  ) {
    if (startDate == null) return false;
    return date.day == date.month &&
        date.day == startDate.day &&
        date.year > startDate.year;
  }

  static String _rcaValidityRawText(String rawText, String normalizedText) {
    final start = TextNormalizer.firstKeywordIndex(normalizedText, [
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

  static String _rcaValidityScanText(String rawText, String normalizedText) {
    return TextNormalizer.normalizeForDateScan(
      _rcaValidityRawText(rawText, normalizedText),
    );
  }

  static DateTime? _findYearFirstDateInWindow(String window) {
    final tokens = DateParser.numericTokens(
      TextNormalizer.normalizeForDateScan(window),
    );
    for (var i = 0; i <= tokens.length - 3; i++) {
      if (!tokens[i].isYear ||
          !tokens[i + 1].isDayOrMonth ||
          !tokens[i + 2].isDayOrMonth) {
        continue;
      }
      final month = tokens[i + 1].value!;
      if (month < 1 || month > 12) continue;
      final date = DateParser.dateFromParts(
        day: tokens[i + 2].text,
        month: tokens[i + 1].text,
        year: tokens[i].text,
      );
      if (date != null) return date;
    }
    return null;
  }

  static DateTime? _findFullStartDateNearDeLa(
    String text,
    String normalizedText,
  ) {
    for (final keyword in ['de la', 'from']) {
      var searchFrom = 0;
      while (true) {
        final index = normalizedText.indexOf(keyword, searchFrom);
        if (index < 0) break;
        searchFrom = index + keyword.length;
        final windowStart = index.clamp(0, text.length).toInt();
        final windowEnd = (index + 350).clamp(0, text.length).toInt();
        final window = text.substring(windowStart, windowEnd);

        final yearFirst = _findYearFirstDateInWindow(window);
        if (yearFirst != null) return yearFirst;

        final fullDates = DateParser.allDatesInText(window);
        if (fullDates.isNotEmpty) return fullDates.first;

        final fragmented = DateParser.fragmentedDateNearKeyword(window);
        if (fragmented != null) return fragmented;
      }
    }
    return null;
  }

  static List<int> _findYearsNearPanaLa(String text, String normalizedText) {
    final years = <int>{};
    // Real OCR scatters the TO year far below the PANA LA / TO label (often
    // separated by a full validity paragraph), so scan from the earliest
    // PANA LA / TO label to the end of the document. Safety is enforced later
    // by restricting the inferred TO year to FROM..FROM+2 (strictly later).
    var earliest = -1;
    for (final match in RegExp(
      r'\b(?:pana\s*la|to)\b',
    ).allMatches(normalizedText)) {
      if (match.group(0) == 'to' &&
          !_isRcaToKeyword(normalizedText, match.start)) {
        continue;
      }
      if (earliest < 0 || match.start < earliest) earliest = match.start;
    }
    if (earliest < 0) return years.toList()..sort();

    final windowStart = earliest.clamp(0, text.length).toInt();
    final window = TextNormalizer.normalizeForDateScan(
      text.substring(windowStart),
    );
    for (final token in DateParser.numericTokens(window)) {
      if (token.isYear && token.value != null) years.add(token.value!);
    }
    return years.toList()..sort();
  }

  static bool _hasFullToExpiryDate(
    String text,
    String normalizedText,
    DateTime startDate,
  ) {
    for (final match in RegExp(
      r'\b(?:pana\s*la|to)\b',
    ).allMatches(normalizedText)) {
      if (match.group(0) == 'to' &&
          !_isRcaToKeyword(normalizedText, match.start)) {
        continue;
      }
      final windowStart = match.start.clamp(0, text.length).toInt();
      final windowEnd = (match.start + 220).clamp(0, text.length).toInt();
      final window = text.substring(windowStart, windowEnd);

      for (final date in DateParser.allDatesInText(window)) {
        if (DateParser.dateOnly(date) == DateParser.dateOnly(startDate)) {
          continue;
        }
        if (_isMisalignedGreenCardTokenDate(date, startDate)) continue;
        return true;
      }

      final fromTokens = _structuredDateFromTokens(
        DateParser.numericTokens(TextNormalizer.normalizeForDateScan(window)),
      );
      if (fromTokens != null &&
          DateParser.dateOnly(fromTokens) != DateParser.dateOnly(startDate) &&
          !_isMisalignedGreenCardTokenDate(fromTokens, startDate)) {
        return true;
      }
    }
    return false;
  }
}

class _GreenCardTableDates {
  const _GreenCardTableDates({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

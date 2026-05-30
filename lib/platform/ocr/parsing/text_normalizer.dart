/// Romanian diacritics-insensitive text normalization for OCR keyword matching.
abstract final class TextNormalizer {
  /// Fixes common OCR typos before keyword/date parsing.
  static String correctForParsing(String input) {
    var s = input.replaceAll(RegExp(r'[ \t]+'), ' ').trim();

    const earlyAscii = {
      'ä': 'a',
      'Ä': 'A',
      'ö': 'o',
      'Ö': 'O',
      'ü': 'u',
      'Ü': 'U',
      'â': 'a',
      'Â': 'A',
      'ă': 'a',
      'Ă': 'A',
      'î': 'i',
      'Î': 'I',
      'ș': 's',
      'Ş': 'S',
      'ş': 's',
      'ț': 't',
      'Ţ': 'T',
      'ţ': 't',
    };
    for (final entry in earlyAscii.entries) {
      s = s.replaceAll(entry.key, entry.value);
    }

    s = s.replaceAllMapped(
      RegExp(r'\bgarte\b', caseSensitive: false),
      (_) => 'CARTE',
    );
    s = s.replaceAllMapped(
      RegExp(r'internat:onal', caseSensitive: false),
      (_) => 'INTERNATIONAL',
    );
    s = s.replaceAllMapped(
      RegExp(r'internat\s*onal', caseSensitive: false),
      (_) => 'INTERNATIONAL',
    );
    s = s.replaceAllMapped(
      RegExp(r'valabiltate', caseSensitive: false),
      (_) => 'VALABILITATE',
    );
    s = s.replaceAllMapped(
      RegExp(r'\banil\b', caseSensitive: false),
      (_) => 'Anul',
    );
    s = s.replaceAllMapped(
      RegExp(r'\bani-year\b', caseSensitive: false),
      (_) => 'Anul-Year',
    );
    s = s.replaceAllMapped(
      RegExp(r'\byaar\b', caseSensitive: false),
      (_) => 'Year',
    );
    s = s.replaceAllMapped(
      RegExp(r'asigurätor', caseSensitive: false),
      (_) => 'ASIGURATOR',
    );

    return s.replaceAll(RegExp(r' {2,}'), ' ');
  }

  static String normalize(String input) {
    return correctForParsing(input)
        .toLowerCase()
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ş', 's')
        .replaceAll('ț', 't')
        .replaceAll('ţ', 't');
  }

  static String normalizeForDateScan(String input) {
    return normalize(input)
        .replaceAll('o', '0')
        .replaceAll('i', '1')
        .replaceAll('l', '1')
        .replaceAll('s', '5');
  }

  static bool containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  static int scoreKeywords(String text, List<String> keywords) {
    var score = 0;
    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }
    return score;
  }

  static int firstKeywordIndex(String text, List<String> keywords) {
    final indexes =
        keywords.map(text.indexOf).where((index) => index >= 0).toList()
          ..sort();
    if (indexes.isEmpty) return -1;
    return indexes.first;
  }
}

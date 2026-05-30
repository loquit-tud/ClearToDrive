/// Romanian diacritics-insensitive text normalization for OCR keyword matching.
abstract final class TextNormalizer {
  static String normalize(String input) {
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

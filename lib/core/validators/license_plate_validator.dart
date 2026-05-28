class LicensePlateValidator {
  const LicensePlateValidator._();

  /// Normalizes Romanian plates: uppercase, single spaces between parts.
  static String normalize(String input) {
    final collapsed = input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toUpperCase();
    final compact = collapsed.replaceAll(RegExp(r'[\s-]+'), '');
    final match = RegExp(
      r'^([A-Z]{1,2})(\d{2,3})([A-Z]{3})$',
    ).firstMatch(compact);
    if (match != null) {
      return '${match.group(1)} ${match.group(2)} ${match.group(3)}';
    }
    return collapsed;
  }

  /// Soft validation — warns on unusual formats but does not block save.
  static bool looksLikeRomanianPlate(String normalized) {
    if (normalized.length < 4) return false;
    return RegExp(r'^[A-Z]{1,2}\s?\d{2,3}\s?[A-Z]{3}$').hasMatch(normalized) ||
        RegExp(
          r'^[A-Z]{1,2}\d{2,3}[A-Z]{3}$',
        ).hasMatch(normalized.replaceAll(' ', ''));
  }
}

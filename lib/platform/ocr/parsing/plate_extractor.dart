import 'package:cleartodrive/core/validators/license_plate_validator.dart';

abstract final class PlateExtractor {
  static String? extract(String rawText) {
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
}

abstract final class VinExtractor {
  static String? extract(String rawText, String normalizedText) {
    final vinMatch = RegExp(
      r'\b([A-HJ-NPR-Z0-9]{17})\b',
      caseSensitive: false,
    ).firstMatch(rawText.toUpperCase());
    if (vinMatch != null) return vinMatch.group(1);

    if (normalizedText.contains('vin') ||
        normalizedText.contains('seria caroseriei')) {
      final loose = RegExp(
        r'(?:vin|seria caroseriei)\D{0,20}([A-HJ-NPR-Z0-9]{11,17})',
        caseSensitive: false,
      ).firstMatch(rawText.toUpperCase());
      if (loose != null) return loose.group(1);
    }
    return null;
  }
}

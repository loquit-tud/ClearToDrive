import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/platform/ocr/parsing/text_normalizer.dart';

/// Shared input for all template parsers.
class OcrExtractionContext {
  OcrExtractionContext({
    required this.rawText,
    required this.correctedText,
    required this.normalizedText,
    required this.ocrText,
    this.typeHint,
    DateTime? referenceDate,
  }) : referenceDate = _dateOnly(referenceDate ?? DateTime.now());

  factory OcrExtractionContext.from({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) {
    final raw = ocrText.text;
    final corrected = TextNormalizer.correctForParsing(raw);
    return OcrExtractionContext(
      rawText: raw,
      correctedText: corrected,
      normalizedText: TextNormalizer.normalize(corrected),
      ocrText: ocrText,
      typeHint: typeHint,
      referenceDate: referenceDate,
    );
  }

  final String rawText;
  final String correctedText;
  final String normalizedText;
  final OcrTextResult ocrText;
  final DocumentType? typeHint;
  final DateTime referenceDate;

  bool get hasText => rawText.trim().isNotEmpty;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class DateChoice {
  const DateChoice({
    required this.date,
    required this.score,
    required this.confidence,
    this.reason,
  });

  final DateTime date;
  final int score;
  final double confidence;
  final String? reason;
}

class TemplateParseResult {
  const TemplateParseResult({
    this.expiryDate,
    this.licensePlate,
    this.vin,
    this.confidence,
    this.expirySelectionReason,
    this.helperKey,
    this.candidateFullDates = const [],
    this.candidateToYears = const [],
    this.detectedFromDate,
    this.detectedToYear,
    this.needsManualReview = true,
  });

  final DateTime? expiryDate;
  final String? licensePlate;
  final String? vin;
  final double? confidence;
  final String? expirySelectionReason;
  final String? helperKey;
  final List<DateTime> candidateFullDates;
  final List<int> candidateToYears;
  final DateTime? detectedFromDate;
  final int? detectedToYear;
  final bool needsManualReview;
}

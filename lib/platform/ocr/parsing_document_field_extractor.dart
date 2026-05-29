import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/parsers/romanian_document_parser.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/ocr_text_recognition_service.dart';
import 'package:cleartodrive/platform/ocr/ocr_extraction_debug_logger.dart';

/// Runs text recognition then pure-Dart parsing — suggestions only.
class ParsingDocumentFieldExtractor implements DocumentFieldExtractor {
  ParsingDocumentFieldExtractor(
    this._recognition, {
    RomanianDocumentParser? parser,
    OcrExtractionDebugLogger? debugLogger,
  })  : _parser = parser ?? RomanianDocumentParser(),
        _debugLogger = debugLogger ?? OcrExtractionDebugLogger();

  final OcrTextRecognitionService _recognition;
  final RomanianDocumentParser _parser;
  final OcrExtractionDebugLogger _debugLogger;

  static final _plateRegex = RegExp(
    r'\b([A-Z]{1,2})\s*(\d{1,3})\s*([A-Z]{3})\b',
    caseSensitive: false,
  );

  @override
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  }) async {
    final rawText = await _recognition.recognizeText(imagePath: imagePath);

    final ocrReturnedText = rawText.trim().isNotEmpty;
    final effectiveType = typeHint ?? _guessType(rawText);

    RcaExpiryParseResult? rcaResult;
    DateTime? expiryDate;
    var expiryDetected = false;
    var lowConfidence = true;
    String? expirySelectionReason;
    double confidence = 0;

    if (effectiveType == DocumentType.rca ||
        (typeHint == null && _looksLikeRcaText(rawText))) {
      rcaResult = _parser.parseRcaExpiry(rawText);
      expiryDate = rcaResult.expiryDate;
      expiryDetected = rcaResult.detected;
      lowConfidence = rcaResult.lowConfidence;
      expirySelectionReason = rcaResult.selectionReason;
      confidence = rcaResult.confidence;
    } else if (effectiveType == DocumentType.itp) {
      final itp = _parser.parseRcaExpiry(rawText);
      expiryDate = itp.expiryDate;
      expiryDetected = itp.detected;
      lowConfidence = itp.lowConfidence;
      expirySelectionReason = itp.selectionReason;
      confidence = itp.confidence;
    }

    _debugLogger.logExtraction(
      imagePath: imagePath,
      rawText: rawText,
      typeHint: typeHint,
      ocrReturnedText: ocrReturnedText,
      rcaResult: rcaResult,
    );

    return ExtractionResult(
      licensePlate: _extractPlate(rawText),
      expiryDate: expiryDate,
      suggestedType: effectiveType,
      confidence: confidence,
      rawText: rawText,
      expiryDetected: expiryDetected,
      lowConfidence: lowConfidence,
      expirySelectionReason: expirySelectionReason,
      ocrReturnedText: ocrReturnedText,
    );
  }

  String? _extractPlate(String text) {
    final match = _plateRegex.firstMatch(text.toUpperCase());
    if (match == null) return null;
    final raw = '${match.group(1)} ${match.group(2)} ${match.group(3)}';
    final normalized = LicensePlateValidator.normalize(raw);
    return normalized.isEmpty ? null : normalized;
  }

  DocumentType? _guessType(String text) {
    final n = text.toLowerCase();
    if (n.contains('itp') || n.contains('inspectie')) return DocumentType.itp;
    if (n.contains('rovinieta')) return DocumentType.rovinieta;
    if (_looksLikeRcaText(text)) return DocumentType.rca;
    return null;
  }

  bool _looksLikeRcaText(String text) {
    final n = text.toLowerCase();
    return n.contains('rca') ||
        n.contains('asigurare') ||
        n.contains('valabilitate');
  }
}

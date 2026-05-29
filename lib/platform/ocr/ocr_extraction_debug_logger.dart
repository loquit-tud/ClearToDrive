import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/parsers/romanian_document_parser.dart';
import 'package:flutter/foundation.dart';

/// Debug-only OCR logging — never shown in production UI.
class OcrExtractionDebugLogger {
  void logExtraction({
    required String imagePath,
    required String rawText,
    required DocumentType? typeHint,
    required bool ocrReturnedText,
    required RcaExpiryParseResult? rcaResult,
  }) {
    if (!kDebugMode) return;

    final hasText = rawText.trim().isNotEmpty;
    debugPrint('[OCR] image=$imagePath typeHint=$typeHint returnedText=$hasText');
    debugPrint('[OCR] ocrReturnedText=$ocrReturnedText length=${rawText.length}');

    if (typeHint == DocumentType.rca || _looksLikeRca(rawText)) {
      if (rcaResult != null) {
        final dates = rcaResult.allDates
            .map((d) => '${d.raw}@${d.start}')
            .join(', ');
        debugPrint('[OCR] rca_dates_found=[$dates]');
        debugPrint(
          '[OCR] rca_selected=${rcaResult.expiryDate} '
          'reason=${rcaResult.selectionReason} '
          'confidence=${rcaResult.confidence} '
          'lowConfidence=${rcaResult.lowConfidence}',
        );
      } else {
        debugPrint('[OCR] rca_parse=skipped');
      }
    }

    // Raw text only in debug console — not persisted or shown in UI.
    if (hasText) {
      debugPrint('[OCR] rawText_preview=${_redactForLog(rawText)}');
    }
  }

  bool _looksLikeRca(String text) {
    final n = text.toLowerCase();
    return n.contains('rca') ||
        n.contains('asigurare') ||
        n.contains('valabilitate');
  }

  String _redactForLog(String text) {
    if (text.length <= 200) return text;
    return '${text.substring(0, 200)}…(${text.length} chars)';
  }
}

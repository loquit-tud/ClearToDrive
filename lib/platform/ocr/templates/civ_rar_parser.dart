import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/plate_extractor.dart';

/// CIV / RAR Vehicle Identity Card — VIN only, no expiry.
abstract final class CivRarParser {
  static TemplateParseResult parse(OcrExtractionContext ctx) {
    return TemplateParseResult(
      licensePlate: PlateExtractor.extract(ctx.rawText),
      vin: VinExtractor.extract(ctx.rawText, ctx.normalizedText),
      helperKey: ExtractionHelperKeys.civNoExpiry,
      expirySelectionReason: ExtractionReasons.noExpiryByTemplate,
      needsManualReview: true,
    );
  }
}

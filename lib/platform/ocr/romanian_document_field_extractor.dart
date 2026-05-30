import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/text_normalizer.dart';
import 'package:cleartodrive/platform/ocr/template_detector.dart';
import 'package:cleartodrive/platform/ocr/templates/civ_rar_parser.dart';
import 'package:cleartodrive/platform/ocr/templates/itp_certificate_parser.dart';
import 'package:cleartodrive/platform/ocr/templates/itp_registration_annex_parser.dart';
import 'package:cleartodrive/platform/ocr/templates/rca_green_card_parser.dart';
import 'package:cleartodrive/platform/ocr/templates/rca_policy_parser.dart';
import 'package:cleartodrive/platform/ocr/templates/unknown_document_parser.dart';

import 'package:flutter/foundation.dart';

/// Orchestrates template detection and delegates to format-specific parsers.
class RomanianDocumentFieldExtractor implements DocumentFieldExtractor {
  const RomanianDocumentFieldExtractor();

  @override
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) async {
    final ctx = OcrExtractionContext.from(
      ocrText: ocrText,
      typeHint: typeHint,
      referenceDate: referenceDate,
    );

    if (!ocrText.succeeded || !ctx.hasText) {
      return ExtractionResult(
        rawText: ctx.rawText,
        confidence: 0,
        needsManualReview: true,
      );
    }

    final template = DocumentTemplateDetector.detect(ctx);
    final parseResult = _parseTemplate(template, ctx);
    final suggestedType = _resolveSuggestedType(ctx, template);
    final typeHintPreserved = typeHint == null || suggestedType == typeHint;
    final helperKey = _resolveHelperKey(parseResult, template);

    final preview = ctx.rawText.trim();
    final normalizedPreview = ctx.normalizedText;
    final diagnostics = OcrExtractionDiagnostics(
      detectedTemplate: template,
      selectedDocumentType: typeHint ?? suggestedType,
      typeHintPreserved: typeHintPreserved,
      candidateFullDates: parseResult.candidateFullDates,
      candidateToYears: parseResult.candidateToYears,
      selectedExpiryDate: parseResult.expiryDate,
      selectionReason: parseResult.expirySelectionReason,
      rawTextPreview: preview.length <= 500 ? preview : '${preview.substring(0, 500)}…',
      normalizedOcrPreview: normalizedPreview.length <= 500
          ? normalizedPreview
          : '${normalizedPreview.substring(0, 500)}…',
      detectedFromDate: parseResult.detectedFromDate,
      detectedToYear: parseResult.detectedToYear,
      vin: parseResult.vin,
    );

    if (kDebugMode) {
      debugPrint(
        'OCR extract template=${template.id} '
        'typeHint=${typeHint?.name} '
        'from=${parseResult.detectedFromDate} '
        'toYear=${parseResult.detectedToYear} '
        'expiry=${parseResult.expiryDate} '
        'reason=${parseResult.expirySelectionReason}',
      );
    }

    final confidence =
        parseResult.confidence ??
        (parseResult.licensePlate == null ? 0.35 : 0.55);

    return ExtractionResult(
      licensePlate: parseResult.licensePlate,
      expiryDate: parseResult.expiryDate,
      suggestedType: suggestedType,
      confidence: confidence,
      rawText: ctx.rawText,
      needsManualReview:
          parseResult.needsManualReview || parseResult.licensePlate == null,
      expirySelectionReason: parseResult.expirySelectionReason,
      diagnostics: diagnostics,
      detectedTemplate: template,
      helperKey: helperKey,
      vin: parseResult.vin,
      typeHintPreserved: typeHintPreserved,
    );
  }

  static TemplateParseResult _parseTemplate(
    DocumentTemplate template,
    OcrExtractionContext ctx,
  ) {
    return switch (template) {
      DocumentTemplate.rcaGreenCard => RcaGreenCardParser.parse(ctx),
      DocumentTemplate.rcaPolicy => RcaPolicyParser.parse(ctx),
      DocumentTemplate.itpCertificate => ItpCertificateParser.parse(ctx),
      DocumentTemplate.itpRegistrationAnnex =>
        ItpRegistrationAnnexParser.parse(ctx),
      DocumentTemplate.civRar => CivRarParser.parse(ctx),
      DocumentTemplate.unknown => UnknownDocumentParser.parse(ctx),
    };
  }

  static DocumentType? _resolveSuggestedType(
    OcrExtractionContext ctx,
    DocumentTemplate template,
  ) {
    if (ctx.typeHint != null) return ctx.typeHint;

    return switch (template) {
      DocumentTemplate.rcaGreenCard ||
      DocumentTemplate.rcaPolicy => DocumentType.rca,
      DocumentTemplate.itpCertificate ||
      DocumentTemplate.itpRegistrationAnnex => DocumentType.itp,
      DocumentTemplate.civRar => null,
      DocumentTemplate.unknown => _detectTypeFromKeywords(ctx.normalizedText),
    };
  }

  static DocumentType? _detectTypeFromKeywords(String text) {
    if (TextNormalizer.containsAny(text, [
      'itp',
      'inspectie tehnica',
    ])) {
      return DocumentType.itp;
    }
    if (text.contains('rovinieta')) return DocumentType.rovinieta;
    if (TextNormalizer.containsAny(text, ['rca', 'asigurare'])) {
      return DocumentType.rca;
    }
    return null;
  }

  static String? _resolveHelperKey(
    TemplateParseResult parseResult,
    DocumentTemplate template,
  ) {
    if (parseResult.helperKey != null) return parseResult.helperKey;
    if (ExtractionReasons.isGreenCardInferredExpiry(
      parseResult.expirySelectionReason,
    )) {
      return ExtractionHelperKeys.rcaInferredExpiry;
    }
    if (parseResult.expiryDate != null) {
      return ExtractionHelperKeys.ocrSuccess;
    }
    if (template == DocumentTemplate.civRar) {
      return ExtractionHelperKeys.civNoExpiry;
    }
    return null;
  }
}

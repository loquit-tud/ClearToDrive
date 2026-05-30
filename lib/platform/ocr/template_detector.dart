import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/ocr/document_template.dart';
import 'package:cleartodrive/platform/ocr/extraction_context.dart';
import 'package:cleartodrive/platform/ocr/parsing/text_normalizer.dart';

/// Detects the most likely Romanian document layout from OCR text.
abstract final class DocumentTemplateDetector {
  static const _policyKeywords = [
    'rca',
    'polita',
    'asigurare',
    'valabilitate',
    'perioada de valabilitate',
    'valabil de la',
    'pana la',
    'inceput valabilitate',
    'sfarsit valabilitate',
    'data expirarii',
  ];

  static const _itpCertificateKeywords = [
    'certificat de inspectie tehnica periodica',
    'roadworthiness certificate',
    'rar',
    'data urmatoarei inspectii tehnice periodice',
    'conform anexei la certificatul de inmatriculare',
  ];

  static const _itpAnnexKeywords = [
    'itp',
    'inspectie tehnica periodica',
    'urmatoarea inspectie',
    'valabil pana la',
    'data urmatoarei itp',
    'certificat de inmatriculare',
    'anexa',
  ];

  static const _civKeywords = [
    'cartea de identitate a vehiculului',
    'civ',
    'registrul auto roman',
    'vin',
    'seria caroseriei',
  ];

  static DocumentTemplate detect(OcrExtractionContext ctx) {
    final text = ctx.normalizedText;

    if (_isCivLayout(text)) return DocumentTemplate.civRar;

    if (ctx.typeHint == DocumentType.rca) {
      if (_isGreenCardLayout(text)) return DocumentTemplate.rcaGreenCard;
      return DocumentTemplate.rcaPolicy;
    }

    if (ctx.typeHint == DocumentType.itp) {
      if (_isItpCertificateLayout(text) && !_isItpAnnexLayout(text)) {
        return DocumentTemplate.itpCertificate;
      }
      if (_isItpAnnexLayout(text)) return DocumentTemplate.itpRegistrationAnnex;
      if (_isItpCertificateLayout(text)) return DocumentTemplate.itpCertificate;
      return DocumentTemplate.itpRegistrationAnnex;
    }

    if (_isGreenCardLayout(text)) return DocumentTemplate.rcaGreenCard;

    final scores = <DocumentTemplate, int>{
      DocumentTemplate.rcaPolicy: TextNormalizer.scoreKeywords(
        text,
        _policyKeywords,
      ),
      DocumentTemplate.itpRegistrationAnnex: TextNormalizer.scoreKeywords(
        text,
        _itpAnnexKeywords,
      ),
      DocumentTemplate.itpCertificate: TextNormalizer.scoreKeywords(
        text,
        _itpCertificateKeywords,
      ),
      DocumentTemplate.civRar: TextNormalizer.scoreKeywords(text, _civKeywords),
    };

    final ranked = scores.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final scoreCompare = b.value.compareTo(a.value);
        if (scoreCompare != 0) return scoreCompare;
        return _priority(a.key).compareTo(_priority(b.key));
      });

    if (ranked.isEmpty) return DocumentTemplate.unknown;
    return ranked.first.key;
  }

  static bool _isCivLayout(String text) {
    return TextNormalizer.containsAny(text, [
      'cartea de identitate a vehiculului',
      'civ',
    ]) &&
        !text.contains('itp') &&
        !text.contains('rca');
  }

  static bool _isGreenCardLayout(String text) {
    if (TextNormalizer.containsAny(text, [
      'carte internationala de asigurare',
      'international motor insurance card',
      'carte internationale d\'assurance',
      'carte internationale d assurance',
      'carte verde',
      'valabilitate valid',
      'biroul asiguratorilor',
      'baar',
    ])) {
      return true;
    }
    return (text.contains('de la') && text.contains('pana la')) ||
        (text.contains('from') && RegExp(r'\bto\b').hasMatch(text)) ||
        (text.contains('ziua') &&
            text.contains('luna') &&
            text.contains('anul'));
  }

  static bool _isItpAnnexLayout(String text) {
    return TextNormalizer.containsAny(text, [
      'certificat de inmatriculare',
      'anexa',
      'valabil pana la',
    ]) ||
        (text.contains('itp') && text.contains('valabil'));
  }

  static bool _isItpCertificateLayout(String text) {
    return TextNormalizer.containsAny(text, [
      'certificat de inspectie tehnica periodica',
      'roadworthiness certificate',
      'conform anexei la certificatul de inmatriculare',
    ]) ||
        (text.contains('rar') &&
            text.contains('data urmatoarei inspectii tehnice periodice'));
  }

  static int _priority(DocumentTemplate template) {
    return switch (template) {
      DocumentTemplate.rcaGreenCard => 0,
      DocumentTemplate.rcaPolicy => 1,
      DocumentTemplate.itpRegistrationAnnex => 2,
      DocumentTemplate.itpCertificate => 3,
      DocumentTemplate.civRar => 4,
      DocumentTemplate.unknown => 5,
    };
  }
}

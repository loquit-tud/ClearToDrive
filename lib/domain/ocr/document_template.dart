/// Romanian document layout templates detected from OCR text.
enum DocumentTemplate {
  rcaPolicy('RCA_POLICY'),
  rcaGreenCard('RCA_GREEN_CARD'),
  itpCertificate('ITP_CERTIFICATE'),
  itpRegistrationAnnex('ITP_REGISTRATION_ANNEX'),
  civRar('CIV_RAR'),
  unknown('UNKNOWN');

  const DocumentTemplate(this.id);

  final String id;
}

/// Stable reason codes consumed by confirm UI and diagnostics.
abstract final class ExtractionReasons {
  static const inferredFromGreenCardToYear = 'inferred_from_green_card_to_year';
  static const greenCardToYearWithFromDayMonth =
      'green_card_to_year_with_from_day_month';

  static bool isGreenCardInferredExpiry(String? reason) =>
      reason == inferredFromGreenCardToYear ||
      reason == greenCardToYearWithFromDayMonth;
  static const explicitRcaRange = 'explicit_rca_range';
  static const rcaToTable = 'rca_to_table';
  static const rcaPanaLaFullDate = 'rca_pana_la_full_date';
  static const rcaToYearTriplet = 'rca_to_year_triplet';
  static const rcaPolicyValidityEnd = 'rca_policy_validity_end';
  static const itpConcreteDate = 'itp_concrete_date';
  static const itpAnnexDate = 'itp_annex_date';
  static const keywordScoredDate = 'keyword_scored_date';
  static const noExpiryByTemplate = 'no_expiry_by_template';
}

/// L10n keys for template-specific confirm helpers.
abstract final class ExtractionHelperKeys {
  static const ocrSuccess = 'ocr_success';
  static const ocrFailure = 'ocr_failure';
  static const rcaInferredExpiry = 'rca_inferred_expiry';
  static const itpCertificateAnnex = 'itp_certificate_annex';
  static const civNoExpiry = 'civ_no_expiry';
}

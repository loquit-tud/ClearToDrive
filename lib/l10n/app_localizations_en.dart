// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ClearToDrive';

  @override
  String get homeTitle => 'Home';

  @override
  String get onboardingTitle1 => 'Don\'t forget RCA, ITP, and Rovinietă';

  @override
  String get onboardingBody1 =>
      'All your vehicle documents in one place with local reminders.';

  @override
  String get onboardingTitle2 => 'Scan or import proof';

  @override
  String get onboardingBody2 =>
      'OCR suggests dates — you always verify before saving.';

  @override
  String get onboardingTitle3 => 'Electronic Rovinietă';

  @override
  String get onboardingBody3 =>
      'No windshield sticker. Manual entry or proof screenshot works.';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipButton => 'Skip';

  @override
  String get addDocument => 'Add document';

  @override
  String get noDocuments => 'No documents saved';

  @override
  String get noDocumentsHint => 'Add your first RCA, ITP, or Rovinietă.';

  @override
  String get documentTypeRca => 'RCA';

  @override
  String get documentTypeItp => 'ITP';

  @override
  String get documentTypeRovinieta => 'Rovinietă';

  @override
  String get whatDocument => 'What document are you adding?';

  @override
  String get rovinietaHint =>
      'Enter manually if you don\'t have a confirmation photo.';

  @override
  String get scanDocument => 'Scan document';

  @override
  String get importGallery => 'Import from gallery';

  @override
  String get galleryImportTestInfo =>
      'Real gallery import will be added in a later version. This is a test flow.';

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get analyzingDocument => 'Analyzing document…';

  @override
  String get confirmDisclaimer =>
      'Verify the data. The app does not replace official documents. OCR is only a suggestion.';

  @override
  String get licensePlate => 'License plate';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get documentType => 'Document type';

  @override
  String get save => 'Save';

  @override
  String get rescan => 'Scan again';

  @override
  String get documentSaved => 'Document saved';

  @override
  String get completeManually => 'Fill in manually';

  @override
  String expiresIn(int days) {
    return 'Expires in $days days';
  }

  @override
  String get expired => 'Expired';

  @override
  String get expiringSoon => 'Expiring soon';

  @override
  String get valid => 'Valid';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Delete this document?';

  @override
  String get cancel => 'Cancel';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get noVehicles => 'No vehicles yet';

  @override
  String get displayName => 'Display name (optional)';

  @override
  String get settings => 'Settings';

  @override
  String get reminderDefaults => 'Reminder defaults';

  @override
  String get reminderDefaultsHint =>
      'Applies to new documents by default. You can also apply immediately to existing documents.';

  @override
  String get daysBefore30 => '30 days before';

  @override
  String get daysBefore14 => '14 days before';

  @override
  String get daysBefore7 => '7 days before';

  @override
  String get daysBefore1 => '1 day before';

  @override
  String get dayOfExpiry => 'On expiry day';

  @override
  String get selectOneReminder => 'Select at least one reminder';

  @override
  String get reminderPreview => 'Reminder preview';

  @override
  String get dataStaysOnDevice => 'Data stays on your phone';

  @override
  String get sourceScan => 'Scan';

  @override
  String get sourceImport => 'Import';

  @override
  String get sourceManual => 'Manual';

  @override
  String get settingsReminders => 'Expiry reminders';

  @override
  String get notificationPermissionsTitle => 'Notifications';

  @override
  String get notificationPermissionsEnabled => 'Notifications enabled';

  @override
  String get notificationPermissionsDisabled => 'Notifications disabled';

  @override
  String get notificationPermissionsUnknown => 'Unknown status';

  @override
  String get checking => 'Checking…';

  @override
  String get requestPermission => 'Enable notifications';

  @override
  String get notificationDeniedExplanation =>
      'Reminders are saved in the app, but phone notifications won\'t appear until you enable permission.';

  @override
  String get howToEnableNotificationsTitle => 'How to enable notifications';

  @override
  String get howToEnableNotificationsBody =>
      'Android: Settings → Apps → ClearToDrive → Notifications → Enable notifications.';

  @override
  String get help => 'Help';

  @override
  String get ok => 'OK';

  @override
  String get sendTestNotification => 'Send test notification';

  @override
  String get sendTestNotificationHint =>
      'For QA. Helps verify permission and delivery.';

  @override
  String get testNotificationScheduled => 'Test notification scheduled';

  @override
  String get testNotificationFailed => 'Couldn\'t send test notification';

  @override
  String get actionFailedTryAgain => 'Something went wrong. Please try again.';

  @override
  String get onboardingComplete => 'Get started';

  @override
  String get documentNotFound => 'Document not found';

  @override
  String daysBeforeOffset(int days) {
    return '$days days before';
  }

  @override
  String get applyToExistingTitle => 'Apply changes?';

  @override
  String get applyToExistingBody =>
      'Apply these settings to existing saved documents too? If you agree, existing reminders will be cancelled and rescheduled.';

  @override
  String get applyNow => 'Apply';

  @override
  String appliedToExistingCount(int count) {
    return 'Rescheduled for $count documents';
  }
}

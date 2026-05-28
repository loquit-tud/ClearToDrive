import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ClearToDrive'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget RCA, ITP, and Rovinietă'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'All your vehicle documents in one place with local reminders.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Scan or import proof'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'OCR suggests dates — you always verify before saving.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Electronic Rovinietă'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'No windshield sticker. Manual entry or proof screenshot works.'**
  String get onboardingBody3;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocument;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents saved'**
  String get noDocuments;

  /// No description provided for @noDocumentsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first RCA, ITP, or Rovinietă.'**
  String get noDocumentsHint;

  /// No description provided for @documentTypeRca.
  ///
  /// In en, this message translates to:
  /// **'RCA'**
  String get documentTypeRca;

  /// No description provided for @documentTypeItp.
  ///
  /// In en, this message translates to:
  /// **'ITP'**
  String get documentTypeItp;

  /// No description provided for @documentTypeRovinieta.
  ///
  /// In en, this message translates to:
  /// **'Rovinietă'**
  String get documentTypeRovinieta;

  /// No description provided for @whatDocument.
  ///
  /// In en, this message translates to:
  /// **'What document are you adding?'**
  String get whatDocument;

  /// No description provided for @rovinietaHint.
  ///
  /// In en, this message translates to:
  /// **'Enter manually if you don\'t have a confirmation photo.'**
  String get rovinietaHint;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @importGallery.
  ///
  /// In en, this message translates to:
  /// **'Import from gallery'**
  String get importGallery;

  /// No description provided for @galleryImportHelper.
  ///
  /// In en, this message translates to:
  /// **'Image imported. Verify the document and enter the expiry date.'**
  String get galleryImportHelper;

  /// No description provided for @galleryImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import the image. Please try again.'**
  String get galleryImportFailed;

  /// No description provided for @documentImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The document image cannot be displayed.'**
  String get documentImageUnavailable;

  /// No description provided for @importingImage.
  ///
  /// In en, this message translates to:
  /// **'Importing image…'**
  String get importingImage;

  /// No description provided for @confirmMissingDraft.
  ///
  /// In en, this message translates to:
  /// **'Could not open confirmation. Please try again.'**
  String get confirmMissingDraft;

  /// No description provided for @buildInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'QA build'**
  String get buildInfoTitle;

  /// No description provided for @buildInfoValue.
  ///
  /// In en, this message translates to:
  /// **'Build: {label} / v{version} / {date}'**
  String buildInfoValue(String label, String version, String date);

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

  /// No description provided for @analyzingDocument.
  ///
  /// In en, this message translates to:
  /// **'Analyzing document…'**
  String get analyzingDocument;

  /// No description provided for @confirmDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Verify the data. The app does not replace official documents. OCR is only a suggestion.'**
  String get confirmDisclaimer;

  /// No description provided for @licensePlate.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get licensePlate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get documentType;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get rescan;

  /// No description provided for @documentSaved.
  ///
  /// In en, this message translates to:
  /// **'Document saved'**
  String get documentSaved;

  /// No description provided for @completeManually.
  ///
  /// In en, this message translates to:
  /// **'Fill in manually'**
  String get completeManually;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresIn(int days);

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this document?'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// No description provided for @noVehicles.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get noVehicles;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get displayName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @reminderDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reminder defaults'**
  String get reminderDefaults;

  /// No description provided for @reminderDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Applies to new documents by default. You can also apply immediately to existing documents.'**
  String get reminderDefaultsHint;

  /// No description provided for @daysBefore30.
  ///
  /// In en, this message translates to:
  /// **'30 days before'**
  String get daysBefore30;

  /// No description provided for @daysBefore14.
  ///
  /// In en, this message translates to:
  /// **'14 days before'**
  String get daysBefore14;

  /// No description provided for @daysBefore7.
  ///
  /// In en, this message translates to:
  /// **'7 days before'**
  String get daysBefore7;

  /// No description provided for @daysBefore1.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get daysBefore1;

  /// No description provided for @dayOfExpiry.
  ///
  /// In en, this message translates to:
  /// **'On expiry day'**
  String get dayOfExpiry;

  /// No description provided for @selectOneReminder.
  ///
  /// In en, this message translates to:
  /// **'Select at least one reminder'**
  String get selectOneReminder;

  /// No description provided for @reminderPreview.
  ///
  /// In en, this message translates to:
  /// **'Reminder preview'**
  String get reminderPreview;

  /// No description provided for @dataStaysOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Data stays on your phone'**
  String get dataStaysOnDevice;

  /// No description provided for @sourceScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get sourceScan;

  /// No description provided for @sourceImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get sourceImport;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sourceManual;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Expiry reminders'**
  String get settingsReminders;

  /// No description provided for @notificationPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermissionsTitle;

  /// No description provided for @notificationPermissionsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationPermissionsEnabled;

  /// No description provided for @notificationPermissionsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationPermissionsDisabled;

  /// No description provided for @notificationPermissionsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get notificationPermissionsUnknown;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get requestPermission;

  /// No description provided for @notificationDeniedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Reminders are saved in the app, but phone notifications won\'t appear until you enable permission.'**
  String get notificationDeniedExplanation;

  /// No description provided for @howToEnableNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to enable notifications'**
  String get howToEnableNotificationsTitle;

  /// No description provided for @howToEnableNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Android: Settings → Apps → ClearToDrive → Notifications → Enable notifications.'**
  String get howToEnableNotificationsBody;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNotification;

  /// No description provided for @sendTestNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'For QA. Helps verify permission and delivery.'**
  String get sendTestNotificationHint;

  /// No description provided for @testNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test notification scheduled'**
  String get testNotificationScheduled;

  /// No description provided for @testNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send test notification'**
  String get testNotificationFailed;

  /// No description provided for @actionFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get actionFailedTryAgain;

  /// No description provided for @onboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingComplete;

  /// No description provided for @documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get documentNotFound;

  /// No description provided for @daysBeforeOffset.
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String daysBeforeOffset(int days);

  /// No description provided for @applyToExistingTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply changes?'**
  String get applyToExistingTitle;

  /// No description provided for @applyToExistingBody.
  ///
  /// In en, this message translates to:
  /// **'Apply these settings to existing saved documents too? If you agree, existing reminders will be cancelled and rescheduled.'**
  String get applyToExistingBody;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyNow;

  /// No description provided for @appliedToExistingCount.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled for {count} documents'**
  String appliedToExistingCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'ClearToDrive';

  @override
  String get homeTitle => 'Acasă';

  @override
  String get onboardingTitle1 => 'Nu uita de RCA, ITP și Rovinietă';

  @override
  String get onboardingBody1 =>
      'Toate documentele mașinii într-un singur loc, cu memento locale.';

  @override
  String get onboardingTitle2 => 'Scanezi sau imporți dovada';

  @override
  String get onboardingBody2 =>
      'OCR sugerează datele — tu le verifici mereu înainte de salvare.';

  @override
  String get onboardingTitle3 => 'Rovinietă electronică';

  @override
  String get onboardingBody3 =>
      'Fără autocolant pe parbriz. Introducere manuală sau poză cu confirmarea.';

  @override
  String get continueButton => 'Continuă';

  @override
  String get skipButton => 'Sari peste';

  @override
  String get addDocument => 'Adaugă document';

  @override
  String get noDocuments => 'Niciun document salvat';

  @override
  String get noDocumentsHint => 'Adaugă primul RCA, ITP sau Rovinietă.';

  @override
  String get documentTypeRca => 'RCA';

  @override
  String get documentTypeItp => 'ITP';

  @override
  String get documentTypeRovinieta => 'Rovinietă';

  @override
  String get whatDocument => 'Ce document adaugi?';

  @override
  String get rovinietaHint =>
      'Introdu manual dacă nu ai o poză cu confirmarea.';

  @override
  String get scanDocument => 'Scanează document';

  @override
  String get importGallery => 'Importă din galerie';

  @override
  String get captureMissingType =>
      'Nu am putut deschide scanarea. Alege documentul din nou.';

  @override
  String get galleryImportHelper =>
      'Am importat imaginea. Verifică documentul și completează data expirării.';

  @override
  String get ocrImportSuccessHelper =>
      'Am găsit câteva date automat. Verifică-le înainte de salvare.';

  @override
  String get ocrImportFailureHelper =>
      'Nu am putut citi automat datele. Completează manual data expirării.';

  @override
  String get ocrWarning =>
      'OCR-ul poate greși. Datele trebuie verificate de tine.';

  @override
  String get ocrVerifyManually => 'verifică manual';

  @override
  String get ocrRawTextTitle => 'Text OCR detectat';

  @override
  String get ocrRawTextHint =>
      'Pentru QA: trimite acest text dacă data nu este recunoscută.';

  @override
  String get ocrRawTextEmpty => 'Nu există text OCR detectat.';

  @override
  String get galleryImportFailed =>
      'Nu am putut importa imaginea. Încearcă din nou.';

  @override
  String get documentImageUnavailable =>
      'Imaginea documentului nu poate fi afișată.';

  @override
  String get importingImage => 'Se importă imaginea…';

  @override
  String get confirmMissingDraft =>
      'Nu am putut deschide confirmarea. Încearcă din nou.';

  @override
  String get buildInfoTitle => 'Build QA';

  @override
  String buildInfoValue(String label, String version, String date) {
    return 'Build: $label / v$version / $date';
  }

  @override
  String get manualEntry => 'Introducere manuală';

  @override
  String get analyzingDocument => 'Se analizează documentul…';

  @override
  String get confirmDisclaimer =>
      'Verifică datele. Aplicația nu înlocuiește documentele oficiale. OCR-ul este doar o sugestie.';

  @override
  String get licensePlate => 'Număr înmatriculare';

  @override
  String get expiryDate => 'Data expirării';

  @override
  String get expiryDateRequired => 'Completează data expirării.';

  @override
  String get documentType => 'Tip document';

  @override
  String get save => 'Salvează';

  @override
  String get rescan => 'Scanează din nou';

  @override
  String get documentSaved => 'Document salvat';

  @override
  String get completeManually => 'Completează manual';

  @override
  String expiresIn(int days) {
    return 'Expiră în $days zile';
  }

  @override
  String get expired => 'Expirat';

  @override
  String get expiringSoon => 'Expiră curând';

  @override
  String get valid => 'Valabil';

  @override
  String get edit => 'Editează';

  @override
  String get delete => 'Șterge';

  @override
  String get deleteConfirm => 'Ștergi acest document?';

  @override
  String get cancel => 'Anulează';

  @override
  String get vehicles => 'Mașini';

  @override
  String get addVehicle => 'Adaugă mașină';

  @override
  String get noVehicles => 'Nicio mașină încă';

  @override
  String get displayName => 'Nume afișat (opțional)';

  @override
  String get settings => 'Setări';

  @override
  String get reminderDefaults => 'Memento expirare';

  @override
  String get reminderDefaultsHint =>
      'Se aplică implicit documentelor noi. Poți aplica imediat și documentelor existente.';

  @override
  String get daysBefore30 => '30 zile înainte';

  @override
  String get daysBefore14 => '14 zile înainte';

  @override
  String get daysBefore7 => '7 zile înainte';

  @override
  String get daysBefore1 => '1 zi înainte';

  @override
  String get dayOfExpiry => 'În ziua expirării';

  @override
  String get selectOneReminder => 'Selectează cel puțin un memento';

  @override
  String get reminderPreview => 'Previzualizare memento';

  @override
  String get dataStaysOnDevice => 'Datele rămân pe telefon';

  @override
  String get sourceScan => 'Scanare';

  @override
  String get sourceImport => 'Import';

  @override
  String get sourceManual => 'Manual';

  @override
  String get settingsReminders => 'Memento expirare';

  @override
  String get notificationPermissionsTitle => 'Notificări';

  @override
  String get notificationPermissionsEnabled => 'Notificări active';

  @override
  String get notificationPermissionsDisabled => 'Notificări dezactivate';

  @override
  String get notificationPermissionsUnknown => 'Stare necunoscută';

  @override
  String get checking => 'Verific…';

  @override
  String get requestPermission => 'Activează notificări';

  @override
  String get notificationDeniedExplanation =>
      'Memento-urile sunt salvate în aplicație, dar notificările nu vor apărea pe telefon până nu activezi permisiunea.';

  @override
  String get howToEnableNotificationsTitle => 'Cum activezi notificările';

  @override
  String get howToEnableNotificationsBody =>
      'Android: Setări → Aplicații → ClearToDrive → Notificări → Activează notificările.';

  @override
  String get help => 'Ajutor';

  @override
  String get ok => 'OK';

  @override
  String get sendTestNotification => 'Trimite notificare de test';

  @override
  String get sendTestNotificationHint =>
      'Pentru QA. Te ajută să verifici permisiunea și livrarea.';

  @override
  String get testNotificationScheduled => 'Notificare de test programată';

  @override
  String get testNotificationFailed =>
      'Nu am putut trimite notificarea de test';

  @override
  String get actionFailedTryAgain => 'Nu a mers. Încearcă din nou.';

  @override
  String get onboardingComplete => 'Începe';

  @override
  String get documentNotFound => 'Documentul nu a fost găsit';

  @override
  String daysBeforeOffset(int days) {
    return '$days zile înainte';
  }

  @override
  String get applyToExistingTitle => 'Aplici modificările?';

  @override
  String get applyToExistingBody =>
      'Vrei să aplici aceste setări și documentelor deja salvate? Dacă accepți, memento-urile existente vor fi anulate și reprogramate.';

  @override
  String get applyNow => 'Aplică';

  @override
  String appliedToExistingCount(int count) {
    return 'Reprogramat pentru $count documente';
  }
}

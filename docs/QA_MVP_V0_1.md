# ClearToDrive — Manual QA Checklist (MVP v0.1)

Use this checklist to validate the **local functional MVP v0.1** on an Android device/emulator.

## Preconditions

- Device: Android 13+ recommended (to test notification permission prompt)
- App build: debug build is OK
- Network: optional (core flows must work offline)

## Install APK (real device)

**Option A (recommended): adb**

1. Enable **Developer options** on the phone.
2. Enable **USB debugging**.
3. Connect the device via USB.
4. Install:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

**Option B: copy APK to phone**

1. Copy `app-debug.apk` to the phone (USB / Drive).
2. Open it in a file manager and approve “Install unknown apps” if prompted.

## 1) Fresh install

1. Uninstall ClearToDrive (if installed).
2. Install and launch.
3. Verify **Onboarding** shows Romanian-first copy.
4. Tap **Începe**.

**Pass criteria**
- Onboarding appears only on first launch.
- Home loads without crashing.

## 2) Add document with fake scan

1. From Home tap **Adaugă document**.
2. Choose **RCA**.
3. Tap **Scanează document**.
4. Wait for “Se analizează documentul…”.
5. Confirm screen appears with prefilled values (fake OCR):
   - Plate: `B 123 ABC`
   - Type: `RCA`
   - Expiry: future date
6. Edit one field (e.g. expiry date).
7. Tap **Salvează**.

**Pass criteria**
- Confirm screen is mandatory (no auto-save).
- After save, document appears on Home.

## 3) Add document manually (Rovinietă reality)

1. Tap **Adaugă document**.
2. Choose **Rovinietă**.
3. Tap **Introducere manuală**.
4. Enter plate and expiry date.
5. Tap **Salvează**.

**Pass criteria**
- UI does **not** suggest scanning a windshield sticker.
- Manual entry works.
- Document shows on Home with label **Rovinietă** and correct plate.

## 4) Restart app and verify persistence

1. Force-close the app.
2. Re-open.

**Pass criteria**
- Previously saved vehicles/documents still appear.
- Onboarding does not reappear.

## 5) Edit expiry date and verify reminders update

1. Open a document from Home.
2. Tap **Edit** (pencil).
3. Change expiry date.
4. Tap **Salvează**.
5. Return to detail screen.

**Pass criteria**
- Reminder preview list updates to new dates.
- Old reminder preview entries are not duplicated.

## 6) Delete document and verify reminders cancelled

1. Open a document detail screen.
2. Tap **Șterge** and confirm.

**Pass criteria**
- Document removed from Home list.
- If you reopen the app, the deleted document stays deleted.

## 7) Notification permission denied (Android 13+)

1. Fresh install again (or clear app storage).
2. When prompted for notifications, tap **Deny**.
3. Add a document.

**Pass criteria**
- Document is still saved.
- Home shows a clear banner that notifications are disabled.
- Settings explains that reminders are saved but notifications won't appear, and provides a clear action to request/enable notifications.

**How to enable notifications (Android)**

- Settings → Apps → **ClearToDrive** → Notifications → Enable

## 8) Test notification flow (QA / debug)

1. Open **Setări**.
2. In section **Notificări**, tap **Trimite notificare de test**.
3. Wait ~3–10 seconds.

**Pass criteria**
- A local notification appears.
- If no notification appears, verify Android system notifications are enabled for ClearToDrive.

**Known Android notification risks**

- Battery optimization / Doze / OEM restrictions can delay or suppress scheduled notifications.
- Exact timing is not guaranteed (debug build uses inexact scheduling mode).

## 8) Notification permission allowed (Android 13+)

1. Fresh install again (or clear app storage).
2. Allow notifications when prompted (or enable in system settings).
3. Add a document.

**Pass criteria**
- No “notifications disabled” banner.
- A scheduled notification exists (manual verification: wait with a short-offset test, or inspect via Android settings if possible).

## 9) Settings-change reschedule (apply to existing)

1. Save at least one document.
2. Go to **Setări → Memento expirare**.
3. Change offsets (e.g. disable 30 days, enable day-of).
4. When asked, choose **Aplică**.
5. Open an existing document detail screen.

**Pass criteria**
- Reminder preview reflects the new offsets.
- No duplicate preview entries appear.

## 10) Restart and verify reminder schedules are reconstructable

1. Save at least one document.
2. Force-close the app.
3. Re-open.
4. Open document detail.

**Pass criteria**
- Reminder preview still appears (loaded from local schedules).

**Risk note**
- Timezone is currently assumed as **Europe/Bucharest**. If the device timezone differs, scheduled fire times may be off.

## 11) Expired document state

1. Add a document.
2. Edit expiry date to a past date.

**Pass criteria**
- Card shows “Expirat” state and red/urgent styling.
- App still allows save (with user responsibility).

## 12) Expiring soon state

1. Add a document.
2. Edit expiry date to within 7 days.

**Pass criteria**
- Card shows “Expiră curând” state and amber styling.


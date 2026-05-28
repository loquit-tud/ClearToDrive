# ClearToDrive — Manual QA Checklist (MVP v0.2)

v0.2 adds **real gallery image import** (no OCR yet). Use a physical Android device with a real ITP photo in the gallery.

## Preconditions

- Install the latest **ClearToDrive-debug-apk** from GitHub Actions.
- In **Setări**, confirm **Build QA** shows `ci-debug` or `local-debug` and version **0.2.0**.
- Have at least one photo of an ITP document in the phone gallery.

## 1) Import real ITP photo from gallery

1. Open app → **Acasă**.
2. Tap **Adaugă document** → **ITP**.
3. Tap **Importă din galerie**.
4. Android photo picker opens → select your ITP photo.
5. **Confirmare** screen appears with:
   - Image preview of the selected photo
   - Helper text: *Am importat imaginea. Verifică documentul și completează data expirării.*
   - Document type **ITP** (prefilled)
   - Empty plate field (you enter it)
   - Expiry date editable
6. Enter plate (e.g. your real plate) and correct **data expirării**.
7. Tap **Salvează**.

**Pass criteria**

- App does **not** return to Home until after save.
- Home shows the new ITP with correct expiry.
- Open document detail → image preview matches the imported photo.

## 2) Cancel gallery picker

1. **Adaugă document** → any type → **Importă din galerie**.
2. Close/cancel the system picker without selecting a photo.

**Pass criteria**

- Stay on capture screen.
- No error snackbar.
- No navigation to Home.

## 3) Save and verify persistence

1. After saving an imported document, force-close the app.
2. Reopen → open the same document from Home.

**Pass criteria**

- Image preview still loads in document detail.
- Expiry and plate unchanged.

## 4) Image missing placeholder (optional)

If you delete the image file from app storage via adb (advanced), opening document detail should show:

*Imaginea documentului nu poate fi afișată.*

## 5) Fake scan still works (regression)

1. **Adaugă document** → **RCA** → **Scanează document**.
2. Confirm shows fake OCR suggestion (plate `B 123 ABC`) — still a **test** flow, not real camera OCR.

**Pass criteria**

- Scan flow unchanged from v0.1 for QA comparison.

## Install APK

See [QA_MVP_V0_1.md](QA_MVP_V0_1.md) — same adb / artifact steps; artifact name: **ClearToDrive-debug-apk**.

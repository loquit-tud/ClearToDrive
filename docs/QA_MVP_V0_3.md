# ClearToDrive v0.3 QA - OCR import

## Build check

Open Settings and verify the QA label contains:

`Build: v0.3-ocr-import`

## Real ITP photo import

1. Install the latest Android debug APK.
2. Open ClearToDrive.
3. Tap `Adaugă document`.
4. Select `ITP`.
5. Tap `Importă din galerie`.
6. Select a real ITP photo from the Android gallery/photo picker.
7. Confirm that the app opens the Confirm screen, not Home.
8. Confirm that the imported image preview is visible.
9. Review the suggested fields before saving.

## Expected OCR success behavior

When local OCR can read useful text, Confirm should show:

`Am găsit câteva date automat. Verifică-le înainte de salvare.`

The document type should remain the selected type (`ITP`). Expiry date and plate may be prefilled as editable suggestions. The screen must also show:

`OCR-ul poate greși. Datele trebuie verificate de tine.`

Save only after manually checking the values against the image.

## Expected OCR failure behavior

If OCR fails or finds no useful data, Confirm should still open and show the imported image preview. Fields remain editable/manual. The message should be:

`Nu am putut citi automat datele. Completează manual data expirării.`

This is not a fatal error and should not return to Home.

## Mandatory confirmation

OCR data is not legal truth. ClearToDrive must never save OCR output automatically. The user must review, edit if needed, and tap `Salvează`.

## Known limitations

- OCR is best effort and may fail on blur, glare, rotation, low resolution, folded paper, or cropped expiry fields.
- Plate detection is conservative; unsure plates are left empty.
- Date extraction prioritizes Romanian expiry-related keywords, but unusual layouts may still need manual correction.
- iOS native scanning/VisionKit is not implemented in this MVP.
- No official registry check or legal validation is performed.

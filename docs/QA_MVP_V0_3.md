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

## RCA / Carte Verde OCR

For RCA / Carte Verde / Green Card documents, the validity range can appear as split OCR text:

```text
DE LA - FROM
Ziua-Day / Luna-Month / Anul-Year
05 / 08 / 2026

PANA LA - TO
Ziua-Day / Luna-Month / Anul-Year
05 / 08 / 2027
```

`DE LA / FROM` is the start date. `PANA LA / PÂNĂ LA / TO` is the expiry date. In the example above, Confirm should suggest `05.08.2027`, not `05.08.2026`.

Normal ranges should behave the same way:

```text
Valabilitate: 05.08.2026 - 05.08.2027
de la 05/08/2026 pana la 05/08/2027
```

If the user selected `RCA` before import, the document type should remain `RCA` even if OCR text contains noisy words like `ITP`. Plate text such as `PH85GLD` should normalize to `PH 85 GLD`.

The user must still confirm manually. OCR is only a suggestion and must never be saved automatically.

## Mandatory confirmation

OCR data is not legal truth. ClearToDrive must never save OCR output automatically. The user must review, edit if needed, and tap `Salvează`.

## Known limitations

- OCR is best effort and may fail on blur, glare, rotation, low resolution, folded paper, or cropped expiry fields.
- Plate detection is conservative; unsure plates are left empty.
- Date extraction prioritizes Romanian expiry-related keywords, but unusual layouts may still need manual correction.
- iOS native scanning/VisionKit is not implemented in this MVP.
- No official registry check or legal validation is performed.

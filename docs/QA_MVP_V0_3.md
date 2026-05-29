# ClearToDrive — QA MVP v0.3 (RCA OCR expiry)

**Build label:** `v0.3-rca-ocr-expiry` (override via `--dart-define=BUILD_LABEL=...`)

## Scope

This release improves **RCA / insurance** expiry extraction from OCR text. OCR is **not legal truth** — every field stays editable and must be confirmed before save.

## How to test RCA OCR with a real insurance photo

1. Install a debug APK from CI (`ClearToDrive-debug-apk` artifact).
2. Open **Adaugă document** → **RCA** → **Importă din galerie**.
3. Pick a photo of your RCA policy (good lighting, full validity block visible).
4. On **Confirmare**:
   - If text was recognized and parsed, you should see: *"Am găsit o posibilă dată de expirare. Verific-o înainte de salvare."* and a **prefilled expiry** (end of validity range).
   - If recognition failed (common on real devices until ML Kit is wired), you should see: *"Nu am putut citi automat data expirării. Completează manual."* and an **empty** expiry field.
5. **Change** the expiry if needed, enter plate, tap **Salvează**.
6. Verify the saved document uses **your confirmed** date (not a hidden OCR value).

### Debug logging (QA only)

In **debug builds**, connect `adb logcat` and filter `[OCR]`:

- Whether OCR returned text (length only in preview; no production UI dump).
- Dates found and which date was selected, with `reason=...`.

Do not share logcat containing personal data in public channels.

## Supported RCA date formats (parser)

| Pattern | Example |
|--------|---------|
| `dd.MM.yyyy` range after Valabilitate | `Valabilitate: 29.05.2025 - 28.05.2026` → **28.05.2026** |
| `dd/MM/yyyy` de la … până la | `de la 29/05/2025 pana la 28/05/2026` → **28/05/2026** |
| Perioada de valabilitate | `Perioada de valabilitate: de la … până la …` |
| `dd-MM-yyyy` | `01-06-2025 - 31-05-2026` |
| `yyyy-MM-dd` | `2025-05-29 - 2026-05-28` |

**Selection rules:** end/second date of a validity range; prefer future dates; avoid emission/birth/start-of-validity contexts when possible; prefer dates near RCA keywords (`valabilitate`, `asigurare`, `poliță`, etc.).

## Fake scan (prototype)

**Scanează document** still uses a fake image URI (`fake://`) with embedded sample RCA text — useful for demos without a camera.

## Known limitations

- **No on-device ML Kit yet** for real gallery photos: empty OCR text → manual expiry (by design until platform OCR ships).
- Parser is heuristic; skewed photos, stamps, or poor OCR quality may misread digits.
- ITP / Rovinietă gallery import: expiry not auto-filled unless OCR text is available (ITP uses similar date rules when text exists).
- No backend, registry checks, or automatic legal verification.

## Mandatory user confirmation

- Nothing from OCR is saved automatically.
- Confirm screen always requires explicit **Salvează** after user review.
- Disclaimer remains: OCR is only a suggestion.

## Regression checks

- [ ] ITP gallery import still saves with manual plate/expiry + image path
- [ ] Rovinietă manual entry unchanged
- [ ] Fake scan flow opens confirm with suggestions
- [ ] Reminders still schedule from **saved** expiry date

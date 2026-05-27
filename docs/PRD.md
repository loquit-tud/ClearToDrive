# ClearToDrive — Product Requirements Document (MVP)

**Product:** ClearToDrive  
**Version:** MVP (Android first)  
**Document language:** English  
**UI language (MVP):** Romanian-first  
**Last updated:** 2026-05-27

---

## Problem and vision

Romanian drivers must keep **RCA** (mandatory third-party liability insurance), **ITP** (periodic technical inspection), and **rovinieta** (road vignette, electronic since ~2020) valid to drive legally. Missing an expiry date leads to fines (e.g. ITP expired: 1,305–2,900 RON), suspended registration, and—in an accident—RCA may not cover damages if ITP is expired.

Drivers track these dates across paper PDFs, insurer emails, talon (registration certificate), and memory. Existing reminder services exist per insurer or document type, but there is no simple, privacy-first app that consolidates all three in one place.

**Vision:** ClearToDrive lets a driver scan or import proof of a document, review OCR-suggested fields (or enter them manually), confirm once, and receive local reminders before expiry—without an account or server.

---

## Target users

| Segment | Description |
|---------|-------------|
| **Primary** | Individual car owners in Romania with 1–3 personal vehicles |
| **Secondary** | Drivers who receive RCA/ITP as PDF or screenshot rather than paper |

**Not in MVP:** Fleet operators, dealerships, insurers, commercial fleets, multi-user households (family sharing).

---

## Value proposition

| Pillar | What we offer |
|--------|---------------|
| **Multi-document** | RCA, ITP, and rovinieta in one dashboard |
| **Simple flow** | Scan or import → OCR extract → user confirms → save → local reminders |
| **Local-first privacy** | No account, no cloud; data stays on the phone |
| **Honest OCR** | Extraction is a suggestion; user always confirms |

We do **not** claim to be the only app that sends expiry reminders. Insurer portals (e.g. RCA.ro) and other services offer free alerts. Our differentiation is consolidation, on-device privacy, and a fast capture-to-reminder UX—not exclusive access to reminder data.

---

## MVP scope

### In scope

- Scan or import document image/PDF (gallery import)
- OCR extraction of document type (`rca` | `itp` | `rovinieta`), license plate, expiry date
- **Mandatory** confirmation screen before save
- Manual entry and edit when OCR fails or user prefers typing
- Local storage of vehicles and documents
- Local push reminders at configurable offsets (defaults below)
- Dashboard sorted by upcoming expiry urgency
- Basic settings (reminder offsets, notification permission guidance)
- Romanian-first UI copy; English code identifiers and localization keys
- Architecture ready for iOS and future English/Spanish UI (no full translations in MVP)

**Default reminder offsets:**

- 30 days before expiry
- 14 days before expiry
- 7 days before expiry
- 1 day before expiry
- Optional day-of reminder (user toggle in settings)

**Document types (code enum):** `rca`, `itp`, `rovinieta`  
**UI labels (Romanian):** RCA, ITP, Rovinietă

### Out of scope

- Payments or in-app purchase of RCA, rovinieta, or ITP
- Marketplace or partner integrations
- GPS tracking or location features
- Fleet management (multiple drivers, roles, admin)
- AI chat or conversational assistant
- Backend, user accounts, cloud sync, cloud storage
- Official registry API integration (RAR, AIDA, CNAIR live lookup)
- iOS App Store shipping in MVP
- Family sharing
- Home-screen widgets
- Full English/Spanish UI (architecture only)

---

## User stories (Given / When / Then)

### US-01 — Scan and confirm a document

**Given** the user has granted camera and notification permissions  
**When** they choose document type RCA, scan an insurer PDF screenshot, and OCR suggests plate `B 123 ABC` and expiry `15.03.2027`  
**Then** they see a confirmation screen with editable fields, tap Save, and the document appears on the dashboard with reminders scheduled.

### US-02 — OCR failure → manual entry

**Given** the user scans a blurry photo  
**When** OCR returns no expiry date or low confidence  
**Then** the confirmation screen shows empty or partial fields, the user enters the date and plate manually, and save succeeds.

### US-03 — Import from gallery

**Given** the user has an RCA PDF saved as an image in the gallery  
**When** they choose Import from gallery on the add-document flow  
**Then** the same OCR → confirm → save flow runs without opening the native document scanner.

### US-04 — Rovinieta via manual entry

**Given** rovinieta is electronic and the user has no scannable proof image  
**When** they choose Manual entry, select Rovinietă, enter plate and expiry from e-rovinieta.ro  
**Then** the document is saved and reminders are scheduled like any other type.

### US-05 — Edit a saved document

**Given** a saved ITP with a wrong expiry after user typo  
**When** they open document detail and tap Edit, change the date, and save  
**Then** old reminders are cancelled and new ones are scheduled for the corrected date.

### US-06 — Dashboard urgency

**Given** two documents: RCA expiring in 5 days, ITP expiring in 40 days  
**When** the user opens Home  
**Then** RCA appears above ITP with clear days-remaining indicator.

### US-07 — Receive a reminder

**Given** a document with expiry in 7 days and 7-day reminder enabled  
**When** the scheduled local notification fires  
**Then** the user sees a Romanian notification with document type, plate, and expiry date; tapping opens document detail.

### US-08 — Notification permission denied

**Given** the user denied notification permission  
**When** they save a document  
**Then** the document is saved, the app shows that reminders will not fire until permission is granted, and Settings offers a link to system notification settings.

### US-09 — Multiple vehicles

**Given** the user owns two cars with different plates  
**When** they add documents for each plate under Vehicles  
**Then** the dashboard can show all documents or filter by vehicle.

### US-10 — Configure reminder offsets

**Given** the user opens Reminder defaults in Settings  
**When** they disable the 30-day reminder and enable day-of reminder  
**Then** newly saved documents use the updated policy; existing documents rescheduled on next edit (MVP: apply to new saves only—see open questions).

---

## Document reality / challenged assumptions

| Assumption | Reality | MVP response |
|------------|---------|--------------|
| Users scan a physical rovinieta sticker | Rovinieta is **electronic** (plate-linked); no windshield vignette since ~2020 | Never market “scan your vignette.” Support proof images (CNAIR confirmation, email screenshot) or **manual entry** |
| Users scan paper RCA/ITP | Many policies are **e-policies** (PDF, email attachment, screenshot) | Scanner + gallery import; OCR on first page / cropped image |
| OCR reliably extracts all fields | Layouts vary: 2024+ talon format, insurer PDFs, ITP station certificates, photos at angles | **Confirmation is mandatory.** OCR is suggestion only, not legal truth |
| One photo = one document type | Talon may show multiple dates; user may photograph wrong document | User selects type before or on confirm screen; allow correction |
| App replaces official verification | RAR/CNAIR/AIDA are authoritative | No live registry lookup in MVP; disclaimer that user is responsible for accuracy |
| We are the only reminder product | RCA.ro and others offer free expiry alerts | Differentiate on multi-doc + local privacy + UX, not exclusivity |
| Scanning proves legal validity | Reminder app ≠ legal compliance tool | Clear disclaimer in onboarding and confirm screen |

---

## Success metrics (MVP)

| Metric | Definition | Target (initial) |
|--------|------------|------------------|
| **Activation** | User saves first document with confirmed expiry | > 60% of installs that complete onboarding |
| **OCR assist rate** | Saves where user changed ≤ 1 field after OCR | Track baseline; no hard target until beta |
| **Manual-only rate** | Saves via manual entry without scan | Acceptable if < 40%; signals OCR UX issues if higher |
| **D7 retention** | User opens app 7 days after first save | > 25% (hypothesis) |
| **Reminder engagement** | User opens app from notification tap | Track baseline |

No analytics backend in MVP—metrics collected via optional local debug logging or manual beta feedback until instrumentation is decided.

---

## Non-goals (MVP)

- Selling or renewing insurance or rovinieta
- Competing with official government or insurer portals on verification
- Becoming a document vault with unlimited cloud backup
- Supporting non-Romanian document types or plates in MVP
- Perfect OCR accuracy without human confirmation

---

## Future roadmap (post-MVP, not designed now)

| Phase | Items |
|-------|-------|
| **v1.1** | iOS App Store with VisionKit scanner |
| **v1.2** | English and Spanish UI (ARB/ l10n files already structured) |
| **v1.3** | Widget showing next expiry |
| **v2** | Optional export/backup (local file, no account) |
| **Evaluated later** | Registry lookup APIs (legal/ToS review required), family sharing |

---

## How to verify (once app exists)

1. Install the Android APK on a device or emulator (API 24+).
2. Complete onboarding; grant camera and notifications when prompted.
3. Tap Add document → RCA → Scan or import a sample RCA PDF screenshot from test fixtures.
4. On Confirm screen, verify plate, type, and expiry are editable; tap Save.
5. Open Home; confirm the document appears with correct days remaining.
6. Open Settings → Reminder defaults; confirm 30/14/7/1-day toggles and day-of toggle exist.
7. Set device date or use a fixture document expiring in 7 days; confirm a local notification fires (or inspect scheduled alarms in debug build).
8. Add a rovinieta via Manual entry only; confirm save and reminders without scan.
9. Deny notifications on a fresh install; confirm document still saves with degraded-mode messaging.
10. Confirm no network calls for core flows (airplane mode test).

---

## Risks (product)

1. **OCR disappointment** — Users expect magic; mandatory confirm mitigates but onboarding must set expectations.
2. **Rovinieta confusion** — Users search for “scan vignette”; copy must explain electronic rovinieta clearly.
3. **Notification OEM kills** — Samsung/Xiaomi battery optimization may block reminders; Settings must guide users.
4. **Weak moat** — Free insurer alerts; retention depends on UX and multi-doc convenience.
5. **Legal perception** — Users may treat reminders as legal proof; disclaimers required.

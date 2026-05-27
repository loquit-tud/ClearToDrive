# ClearToDrive — Technical Decisions

**Product:** ClearToDrive  
**Format:** Architecture Decision Records (ADR-style)  
**Last updated:** 2026-05-27

---

## Summary table

| ID | Decision | Status |
|----|----------|--------|
| TD-01 | Flutter for shared UI and domain | Accepted |
| TD-02 | Android MVP first, iOS later | Accepted |
| TD-03 | Abstract `DocumentScannerService` | Accepted |
| TD-04 | Separate OCR layer from scanner | Accepted |
| TD-05 | Drift for local database | Accepted |
| TD-06 | `flutter_local_notifications` + `timezone` | Accepted |
| TD-07 | Riverpod for state management | Accepted |
| TD-08 | No backend in MVP | Accepted |
| TD-09 | get_it for dependency injection | Accepted |
| TD-10 | Romanian locale default; EN/ES-ready l10n | Accepted |
| TD-11 | Image storage in app documents directory | Accepted |
| TD-12 | Testing: unit + fakes + widget; integration later | Accepted |

---

## TD-01 — Flutter for shared UI and domain

**Context:** Need one codebase for Android MVP and future iOS without rewrite.

**Decision:** Use Flutter 3.x stable for presentation, application, domain, and data layers.

**Rationale:**
- Single Dart codebase for business logic and UI
- Mature plugin ecosystem for local DB and notifications
- Platform channels for thin native scanner adapters

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Native Kotlin + Swift | Two codebases; duplicate domain and UI logic |
| React Native | Weaker typing for domain layer; team direction is Flutter |
| KMM + native UI | Still two UIs; more setup than Flutter for this MVP size |

**Consequences:** Team needs Flutter + small Android/iOS platform slices for scanners.

---

## TD-02 — Android MVP first, iOS later

**Context:** ML Kit Document Scanner is Android-only today; iOS requires VisionKit.

**Decision:** Ship Google Play MVP on Android. iOS App Store is post-MVP. Architecture must not assume Android-only types in domain/UI.

**Rationale:** Faster validation with Romanian Android market share; iOS added via platform layer swap.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Wait for cross-platform scanner plugin | Blocks launch; couples us to third-party maintenance |
| iOS simultaneous launch | Doubles native scanner work before validation |

**Consequences:** iOS users not supported at launch; `ScannerUnavailable` path must be polished (gallery/manual).

---

## TD-03 — Abstract DocumentScannerService

**Context:** Android uses ML Kit Document Scanner; iOS will use VisionKit `VNDocumentCameraViewController`.

**Decision:** Domain interface `DocumentScannerService` with platform implementations registered at startup. UI and use cases depend only on the interface.

**Rationale:**
- Verified: `google_mlkit_document_scanner` is Android-only (beta) on pub.dev
- VisionKit requires custom platform channel on iOS
- Community cross-platform plugins (e.g. doc_scanner_kit) couple two natives opaquely—acceptable as reference, not as domain dependency

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Call ML Kit plugin from widgets | Untestable; blocks iOS |
| Single cross-platform plugin in domain | Hidden native coupling; upgrade risk |

**Consequences:** We own two thin native adapters long-term.

---

## TD-04 — Separate OCR layer from scanner

**Context:** Document scanner returns images/PDFs; field extraction is a different concern.

**Decision:** `DocumentFieldExtractor` interface + pure Dart `RomanianDocumentParser` for regex/keyword parsing after platform text recognition.

**Rationale:**
- Unit-test parsing without camera or ML Kit
- Swap text recognition engine per platform without changing parser
- Scanner can be replaced (gallery-only path) without touching OCR rules

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Scanner plugin performs OCR inline | Not composable; hard to test |
| Cloud OCR API | Violates local-only MVP; privacy positioning |

**Consequences:** Two-step pipeline (scan → extract); UI shows loading between steps.

---

## TD-05 — Drift for local database

**Context:** Need structured storage for vehicles, documents, reminder schedules with expiry queries.

**Decision:** Use **Drift** (SQLite, code-generated) for MVP persistence.

**Rationale:**
| Criterion | Drift | Isar |
|-----------|-------|------|
| Expiry-sorted queries | SQL `ORDER BY expiry_date` natural | Possible via indexes |
| Relational FK (vehicle ↔ documents) | Native SQL FK | Links/embeddings |
| Schema migrations | Built-in migration API | Supported |
| Flutter team familiarity | Common in Flutter apps | Growing; NoSQL model |
| Pure Dart queries in tests | In-memory SQLite | Requires Isar test init |

Drift fits relational model (Vehicle 1—N VehicleDocument 1—N ReminderSchedule) and dashboard "order by expiry" queries cleanly.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Isar | Viable; chosen Drift for SQL expiry queries and explicit relations |
| shared_preferences | No querying; wrong tool |
| Hive | Weak relational queries |

**Consequences:** `build_runner` for code gen; migration discipline required.

---

## TD-06 — Local notifications via flutter_local_notifications + timezone

**Context:** MVP reminders are offline, scheduled ahead of expiry dates.

**Decision:** Use `flutter_local_notifications` with `timezone` package for TZ-aware scheduling.

**Rationale:**
- De facto standard for Flutter local notifications
- Supports Android notification channels and iOS when added later
- Works without FCM/backend

**Android notes:**
- Request `POST_NOTIFICATIONS` (Android 13+)
- Evaluate `SCHEDULE_EXACT_ALARM` for day-of accuracy; fall back to inexact if denied (document in UX)

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| FCM push | Requires backend |
| android_alarm_manager only | Android-only; not iOS-ready |
| Workmanager alone | Better for background work than timed reminders |

**Consequences:** OEM battery optimization may delay delivery—mitigate in Settings UX.

---

## TD-07 — Riverpod for state management

**Context:** Need testable state for async use cases (scan, OCR, save, schedule).

**Decision:** Use **Riverpod** (`flutter_riverpod`) for presentation state and DI of use cases.

**Rationale:**
| Criterion | Riverpod | Bloc |
|-----------|----------|------|
| Boilerplate for MVP | Lower | Higher (events/states per screen) |
| Provider override in tests | Native `ProviderScope` overrides | `bloc_test` + mocks |
| Compile-safe providers | Yes | N/A |
| Learning curve for small team | Moderate | Moderate |

For ~10 screens and clear use-case boundaries, Riverpod keeps presentation thin without ceremony.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Bloc | Excellent but heavier for MVP scope |
| setState only | Poor testability at scale |

**Consequences:** Providers mirror use cases; avoid business logic in widgets.

**Note:** get_it (TD-09) registers platform singletons; Riverpod exposes use cases to UI—hybrid is intentional.

---

## TD-08 — No backend in MVP

**Context:** Product positioning is local-first privacy.

**Decision:** No Firebase, no REST API, no auth, no cloud sync in MVP.

**Rationale:** Faster ship, GDPR-simple story, no server cost.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Firebase Auth + Firestore | Scope creep; contradicts PRD |
| Supabase sync | Same |

**Consequences:** Data loss on uninstall; document in future roadmap as optional export.

---

## TD-09 — Dependency injection strategy

**Context:** Need test doubles for scanner, OCR, repos.

**Decision:** **get_it** service locator for platform singletons and repository implementations; **Riverpod** for exposing use cases and presentation-scoped state.

**Registration (conceptual):**
```dart
// At app startup
getIt.registerLazySingleton<DocumentScannerService>(...);
getIt.registerLazySingleton<DocumentFieldExtractor>(...);
getIt.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(getIt()));
// Riverpod providers read from getIt or construct use cases
```

**Rationale:** get_it keeps platform wiring in one file; Riverpod handles UI reactivity and test overrides.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Riverpod only for everything | Awkward for platform channel singletons |
| injectable code gen | Optional later; overkill for docs phase |

---

## TD-10 — Romanian locale default; EN/ES-ready localization

**Context:** MVP users are Romanian; brand/docs in English; future markets possible.

**Decision:**
- Default app locale: `ro`
- ARB keys: English snake_case (`home_title`, `document_type_rovinieta`)
- MVP: fully translate `app_ro.arb`
- Stub `app_en.arb` / `app_es.arb` with minimal entries (or copy keys) for pipeline validation
- Domain enums: English (`DocumentType.rca`); display via `AppLocalizations`

**Rationale:** Flutter gen-l10n standard; adding languages is file addition, not architecture change.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Hardcoded Romanian strings in widgets | Blocks EN/ES |
| Romanian enum values | Breaks code conventions |

---

## TD-11 — Image storage strategy

**Context:** Users may scan sensitive insurance documents.

**Decision:**
- Store optional image copies in app documents directory (`path_provider`)
- Filename: `{documentId}.jpg` (or original extension)
- No cloud upload
- Delete image when document deleted
- **Open question:** retain image after confirm vs delete immediately (see below)

**Rationale:** Supports confirm/detail preview; stays on-device.

**Alternatives rejected:**
| Alternative | Why rejected |
|-------------|--------------|
| Cache dir only | May be cleared by OS unpredictably |
| Store in DB blob | Large DB; harder migrations |

**Privacy:** Include in Privacy Policy (future): images never leave device in MVP.

---

## TD-12 — Testing strategy

**Context:** OCR and reminders must be testable without devices.

**Decision:**

| Layer | Approach |
|-------|----------|
| `RomanianDocumentParser` | Unit tests with fixture raw text strings |
| Validators | Unit tests |
| Use cases | Unit tests with fake repos + fake scanner/extractor |
| Reminder scheduling | Unit tests with fake clock / timezone |
| Widgets | `ProviderScope` overrides + pump Confirm/Home |
| Integration | Android emulator manual QA checklist post-scaffold |
| Golden tests | Defer until UI stable |

**Fixtures:** Sample OCR text files for RCA PDF, ITP certificate, talon snippet (no real PII).

**Not in MVP:** CI device farm; screenshot tests.

---

## Plugin reference (implementation phase—not added now)

| Purpose | Package (evaluate at scaffold) |
|---------|-------------------------------|
| Document scanner (Android) | `google_mlkit_document_scanner` |
| Text recognition (Android) | `google_mlkit_text_recognition` |
| Local DB | `drift`, `sqlite3_flutter_libs` |
| Notifications | `flutter_local_notifications`, `timezone` |
| Routing | `go_router` |
| DI | `get_it` |
| State | `flutter_riverpod` |
| Paths | `path_provider` |
| UUID | `uuid` |

**Do not add in documentation phase.**

---

## Open questions (founder decisions)

| # | Question | Options | Recommendation |
|---|----------|---------|----------------|
| OQ-1 | Retain scan image after save? | Always keep / delete after confirm / user toggle | **Keep** for detail preview; add "Delete image" in v1.1 |
| OQ-2 | Changing reminder defaults—reschedule existing docs? | New docs only (MVP) / reschedule all on change | **New docs only** in MVP; copy in SCREENS |
| OQ-3 | Max vehicles soft limit? | Unlimited / cap at 5 | **Unlimited** for MVP; revisit if UI clutters |
| OQ-4 | Exact vs inexact alarms on Android 14+? | Request exact permission / inexact only | **Request exact** with inexact fallback |
| OQ-5 | Default reminder time of day? | 09:00 local / 08:00 / user setting | **09:00 local** fixed in MVP |
| OQ-6 | Auto-create vehicle on confirm if plate new? | Yes / force Vehicles flow | **Yes**—reduce friction |
| OQ-7 | PDF import: rasterize or text-only path? | Rasterize page 1 / reject PDF | **Rasterize page 1** when implementing; else image-only MVP |
| OQ-8 | l10n fallback for stub EN/ES files | Fall back to RO / EN | **Romanian fallback** until translated |
| OQ-9 | Analytics in MVP? | None / anonymous local only | **None** in MVP (aligns with PRD) |
| OQ-10 | Legal disclaimer: lawyer review? | Template only / counsel before launch | **Counsel before Play Store** |

---

## Risks requiring technical follow-up

1. **PDF OCR pipeline** — Flutter PDF rasterization adds dependency (`pdfx` or native); may slip to image-only v1.
2. **ML Kit Document Scanner beta** — API changes possible; wrap behind our interface.
3. **iOS parity effort** — VisionKit + Vision text is non-trivial; budget ~2–3 weeks post-Android validation.
4. **Play Store policy** — Insurance-adjacent apps may need clear "not a broker" disclaimer.

---

## Consistency references

- Interfaces defined in [ARCHITECTURE.md](ARCHITECTURE.md)
- MVP scope in [PRD.md](PRD.md)
- Screen flows in [SCREENS.md](SCREENS.md)
- Reminder defaults: 30, 14, 7, 1 days + optional day-of (all docs aligned)

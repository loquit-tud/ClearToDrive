# ClearToDrive

ClearToDrive is a Flutter mobile app for Romanian car owners. Users scan or import vehicle documents (RCA, ITP, rovinieta); OCR suggests expiry date, license plate, and document type; the user confirms or corrects those fields; the app saves locally and schedules on-device reminders before expiration.

**Status:** MVP v0.1 — local functional (Drift persistence, local notifications). Fake scanner/OCR only. See [docs/](docs/) for product and architecture specs.

## Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

## Documentation

- [Product Requirements (PRD)](docs/PRD.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Screens](docs/SCREENS.md)
- [Technical Decisions](docs/TECH_DECISIONS.md)
- [Manual QA — MVP v0.1](docs/QA_MVP_V0_1.md)

## MVP v0.1 scope

- Fake `DocumentScannerService` and `DocumentFieldExtractor` (no ML Kit / VisionKit)
- Drift (SQLite) persistence for vehicles, documents, reminder schedules, settings
- Local notifications via `flutter_local_notifications` + `timezone`
- Reminder defaults: 30 / 14 / 7 / 1 days before expiry (+ optional day-of)
- Romanian-first UI via `app_ro.arb`

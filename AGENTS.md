\# ClearToDrive Agent Rules



This is a Flutter app for Romanian car document reminders.



Hard rules:

\- Do not add backend.

\- Do not add Firebase.

\- Do not add accounts.

\- Do not add cloud sync.

\- Do not add payments.

\- Do not add marketplace.

\- Do not add GPS.

\- Do not add fleet management.

\- Do not add AI chat.

\- Do not add official registry scraping.

\- OCR is not legal truth.

\- User must always confirm/edit OCR results before saving.

\- Keep the app local-only.

\- Do not rewrite architecture.

\- Do not remove existing tests.



Current focus:

Fix OCR/parser behavior for Romanian car documents:

\- RCA policy

\- RCA Green Card / Carte Verde

\- ITP certificate

\- ITP talon/annex

\- CIV/RAR



Before fixing a bug:

1\. Add a failing test with the real OCR text.

2\. Then fix the parser.

3\. Run flutter analyze.

4\. Run flutter test.



Always return:

\- files changed

\- root cause

\- tests added/updated

\- analyze/test result


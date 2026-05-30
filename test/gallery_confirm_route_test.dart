import 'dart:io';

import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('confirm route with missing args shows error instead of Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, state) => ConfirmScreen(
                  initialDraft: state.extra is ConfirmDraft
                      ? state.extra! as ConfirmDraft
                      : null,
                ),
              ),
              GoRoute(
                path: '/add',
                builder: (_, _) => const Scaffold(body: Text('add')),
              ),
              GoRoute(
                path: '/home',
                builder: (_, _) => const Scaffold(body: Text('home')),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nu am putut deschide confirmarea. Încearcă din nou.'),
      findsOneWidget,
    );
    expect(find.text('home'), findsNothing);
  });

  testWidgets('confirm route shows gallery import UI when draft is preset', (
    tester,
  ) async {
    final image = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('ctd_confirm');
      final image = File('${dir.path}/itp.jpg');
      await image.writeAsBytes([0xFF, 0xD8, 0xFF]);
      return image;
    }))!;

    final draft = ConfirmDraft(
      type: DocumentType.itp,
      licensePlate: '',
      source: DocumentSource.import,
      imagePath: image.path,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [confirmDraftProvider.overrideWith((ref) => draft)],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, state) => ConfirmScreen(
                  initialDraft: state.extra is ConfirmDraft
                      ? state.extra! as ConfirmDraft
                      : null,
                ),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.textContaining('Am importat imaginea'), findsOneWidget);
    expect(find.text('Completează manual'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets('confirm route exposes raw OCR text for QA', (tester) async {
    final image = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('ctd_confirm_ocr');
      final image = File('${dir.path}/rca.jpg');
      await image.writeAsBytes([0xFF, 0xD8, 0xFF]);
      return image;
    }))!;

    final draft = ConfirmDraft(
      type: DocumentType.rca,
      licensePlate: 'PH 85 GLD',
      source: DocumentSource.import,
      imagePath: image.path,
      assistStatus: DocumentAssistStatus.ocrNoData,
      needsManualReview: true,
      ocrRawText: 'VALABILITATE VALID\nPANA LA TO\n08 05 2027',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [confirmDraftProvider.overrideWith((ref) => draft)],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, state) => ConfirmScreen(
                  initialDraft: state.extra is ConfirmDraft
                      ? state.extra! as ConfirmDraft
                      : null,
                ),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Text OCR detectat'), findsOneWidget);
    await tester.tap(find.text('Text OCR detectat'));
    await tester.pumpAndSettle();

    expect(find.textContaining('08 05 2027'), findsOneWidget);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets('confirm route shows RCA-specific OCR expiry helper', (
    tester,
  ) async {
    final image = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('ctd_confirm_rca');
      final image = File('${dir.path}/rca.jpg');
      await image.writeAsBytes([0xFF, 0xD8, 0xFF]);
      return image;
    }))!;

    final draft = ConfirmDraft(
      type: DocumentType.rca,
      licensePlate: 'PH 85 GLD',
      expiryDate: DateTime(2027, 8, 5),
      source: DocumentSource.import,
      imagePath: image.path,
      assistStatus: DocumentAssistStatus.ocrSuccess,
      needsManualReview: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [confirmDraftProvider.overrideWith((ref) => draft)],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, state) => ConfirmScreen(
                  initialDraft: state.extra is ConfirmDraft
                      ? state.extra! as ConfirmDraft
                      : null,
                ),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.text(
        'Am găsit câteva date automat. Verifică-le înainte de salvare.',
      ),
      findsOneWidget,
    );
    expect(find.text('05.08.2027'), findsOneWidget);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets('confirm route shows inferred RCA expiry warning', (
    tester,
  ) async {
    final image = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('ctd_confirm_inferred');
      final image = File('${dir.path}/rca.jpg');
      await image.writeAsBytes([0xFF, 0xD8, 0xFF]);
      return image;
    }))!;

    final draft = ConfirmDraft(
      type: DocumentType.rca,
      licensePlate: 'PH 85 GLD',
      expiryDate: DateTime(2027, 8, 5),
      source: DocumentSource.import,
      imagePath: image.path,
      assistStatus: DocumentAssistStatus.ocrSuccess,
      needsManualReview: true,
      expirySelectionReason: ExtractionReasons.greenCardToYearWithFromDayMonth,
      ocrDiagnostics: OcrExtractionDiagnostics(
        detectedTemplate: DocumentTemplate.rcaGreenCard,
        selectedDocumentType: DocumentType.rca,
        typeHintPreserved: true,
        candidateFullDates: [DateTime(2026, 8, 5)],
        candidateToYears: [2027],
        selectedExpiryDate: DateTime(2027, 8, 5),
        selectionReason: ExtractionReasons.greenCardToYearWithFromDayMonth,
        rawTextPreview: 'PANA LA -TO\n2027',
      ),
      helperKey: ExtractionHelperKeys.rcaInferredExpiry,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [confirmDraftProvider.overrideWith((ref) => draft)],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, state) => ConfirmScreen(
                  initialDraft: state.extra is ConfirmDraft
                      ? state.extra! as ConfirmDraft
                      : null,
                ),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.text(
        'Am estimat data de expirare din document. Verific-o înainte de salvare.',
      ),
      findsWidgets,
    );
    expect(find.text('05.08.2027'), findsOneWidget);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });
}

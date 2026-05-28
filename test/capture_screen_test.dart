import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/add_document/capture_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _TestScanner implements DocumentScannerService {
  var scanCalls = 0;
  var galleryCalls = 0;

  @override
  Future<ScanResult> pickFromGallery() async {
    galleryCalls++;
    return const ScanResult(imagePaths: ['fake://gallery.jpg']);
  }

  @override
  Future<ScanResult> scan() async {
    scanCalls++;
    return const ScanResult(imagePaths: ['fake://scan.jpg']);
  }
}

class _TestExtractor implements DocumentFieldExtractor {
  var extractCalls = 0;

  @override
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  }) async {
    extractCalls++;
    return ExtractionResult(
      licensePlate: 'B 123 ABC',
      expiryDate: DateTime(2026, 12, 31),
      suggestedType: typeHint,
      confidence: 0.9,
      rawText: 'mock',
    );
  }
}

Widget _app({
  required Override scanOverride,
}) {
  final router = GoRouter(
    initialLocation: '/add/capture',
    routes: [
      GoRoute(path: '/add/capture', builder: (_, _) => const CaptureScreen()),
      GoRoute(
        path: '/confirm',
        builder: (_, _) => const Scaffold(body: Text('confirm-screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      scanOverride,
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ro'),
    ),
  );
}

void main() {
  testWidgets('scan button triggers fake flow and navigates to confirm', (tester) async {
    final scanner = _TestScanner();
    final extractor = _TestExtractor();
    final useCase = ScanAndExtractUseCase(scanner, extractor);

    await tester.pumpWidget(
      _app(
        scanOverride: scanAndExtractUseCaseProvider.overrideWithValue(useCase),
      ),
    );

    expect(find.text('confirm-screen'), findsNothing);

    await tester.tap(find.text('Scanează document'));
    await tester.pumpAndSettle();

    expect(scanner.scanCalls, 1);
    expect(extractor.extractCalls, 1);
    expect(find.text('confirm-screen'), findsOneWidget);
  });

  testWidgets('gallery button triggers fake flow and shows test info', (tester) async {
    final scanner = _TestScanner();
    final extractor = _TestExtractor();
    final useCase = ScanAndExtractUseCase(scanner, extractor);

    await tester.pumpWidget(
      _app(
        scanOverride: scanAndExtractUseCaseProvider.overrideWithValue(useCase),
      ),
    );

    await tester.tap(find.text('Importă din galerie'));
    await tester.pump(); // start snackbar animation

    expect(scanner.galleryCalls, 1);
    expect(extractor.extractCalls, 1);
    expect(
      find.text(
        'Importul real din galerie va fi adăugat într-o versiune următoare. Acesta este un flux de test.',
      ),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(find.text('confirm-screen'), findsOneWidget);
  });
}


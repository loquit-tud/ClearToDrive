import 'dart:io';

import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/add_document/capture_screen.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _TestScanner implements DocumentScannerService {
  var scanCalls = 0;
  var galleryCalls = 0;
  Future<ScanResult> Function()? galleryResult;

  @override
  Future<ScanResult> pickFromGallery() async {
    galleryCalls++;
    return galleryResult?.call() ??
        const ScanResult(imagePaths: ['/tmp/gallery.jpg']);
  }

  @override
  Future<ScanResult> scan() async {
    scanCalls++;
    return const ScanResult(imagePaths: ['fake://scan.jpg']);
  }
}

class _TestExtractor implements DocumentFieldExtractor {
  @override
  Future<ExtractionResult> extract({
    required String imagePath,
    DocumentType? typeHint,
  }) async {
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
  required List<Override> overrides,
  String initialLocation = '/add/capture',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/add/capture', builder: (_, _) => const CaptureScreen()),
      GoRoute(path: '/confirm', builder: (_, _) => const ConfirmScreen()),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ro'),
    ),
  );
}

Future<String> _tempImagePath() async {
  final dir = await Directory.systemTemp.createTemp('ctd_cap');
  final file = File('${dir.path}/gallery.jpg');
  await file.writeAsBytes([0xFF, 0xD8, 0xFF]);
  return file.path;
}

void main() {
  testWidgets('scan button triggers fake flow and navigates to confirm', (tester) async {
    final scanner = _TestScanner();
    final useCase = ScanAndExtractUseCase(scanner, _TestExtractor());

    await tester.pumpWidget(
      _app(
        overrides: [
          scanAndExtractUseCaseProvider.overrideWithValue(useCase),
          importFromGalleryUseCaseProvider.overrideWithValue(
            ImportFromGalleryUseCase(scanner),
          ),
          selectedDocumentTypeProvider.overrideWith((_) => DocumentType.rca),
        ],
      ),
    );

    await tester.tap(find.text('Scanează document'));
    await tester.pumpAndSettle();

    expect(scanner.scanCalls, 1);
    expect(find.text('Tip document'), findsOneWidget);
    expect(find.text('B 123 ABC'), findsWidgets);
  });

  testWidgets('gallery success navigates to confirm with helper text', (tester) async {
    final scanner = _TestScanner()
      ..galleryResult = () async => ScanResult(imagePaths: [await _tempImagePath()]);
    final importUseCase = ImportFromGalleryUseCase(scanner);

    await tester.pumpWidget(
      _app(
        overrides: [
          importFromGalleryUseCaseProvider.overrideWithValue(importUseCase),
          selectedDocumentTypeProvider.overrideWith((_) => DocumentType.itp),
        ],
      ),
    );

    await tester.tap(find.text('Importă din galerie'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(scanner.galleryCalls, 1);
    expect(find.text('Tip document'), findsOneWidget);
    expect(find.textContaining('Am importat imaginea'), findsOneWidget);
  });

  testWidgets('gallery cancel stays on capture screen', (tester) async {
    final scanner = _TestScanner()
      ..galleryResult = () async => throw const ScanCancelled();
    final importUseCase = ImportFromGalleryUseCase(scanner);

    await tester.pumpWidget(
      _app(
        overrides: [
          importFromGalleryUseCaseProvider.overrideWithValue(importUseCase),
          selectedDocumentTypeProvider.overrideWith((_) => DocumentType.itp),
        ],
      ),
    );

    await tester.tap(find.text('Importă din galerie'));
    await tester.pumpAndSettle();

    expect(find.text('Importă din galerie'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('gallery failure shows error and stays on capture', (tester) async {
    final scanner = _TestScanner()
      ..galleryResult = () async => throw const ScanFailed();
    final importUseCase = ImportFromGalleryUseCase(scanner);

    await tester.pumpWidget(
      _app(
        overrides: [
          importFromGalleryUseCaseProvider.overrideWithValue(importUseCase),
          selectedDocumentTypeProvider.overrideWith((_) => DocumentType.itp),
        ],
      ),
    );

    await tester.tap(find.text('Importă din galerie'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nu am putut importa imaginea. Încearcă din nou.'),
      findsOneWidget,
    );
    expect(find.text('Importă din galerie'), findsOneWidget);
  });
}

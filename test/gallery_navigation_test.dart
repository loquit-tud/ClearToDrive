import 'dart:io';

import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/add_document/add_document_chooser_screen.dart';
import 'package:cleartodrive/presentation/features/add_document/capture_screen.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Add → ITP → gallery → Confirm screen visible', (tester) async {
    final imagePath = await _tempImagePath();
    final importUseCase = ImportFromGalleryUseCase(_StubGalleryScanner(imagePath));

    final router = GoRouter(
      initialLocation: '/add',
      routes: [
        GoRoute(path: '/add', builder: (_, _) => const AddDocumentChooserScreen()),
        GoRoute(path: '/add/capture', builder: (_, _) => const CaptureScreen()),
        GoRoute(path: '/confirm', builder: (_, _) => const ConfirmScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          importFromGalleryUseCaseProvider.overrideWithValue(importUseCase),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ITP'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Importă din galerie'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text(
        'Am importat imaginea. Verifică documentul și completează data expirării.',
      ),
      findsOneWidget,
    );
  });
}

Future<String> _tempImagePath() async {
  final dir = await Directory.systemTemp.createTemp('ctd_nav');
  final file = File('${dir.path}/itp.jpg');
  await file.writeAsBytes([0xFF, 0xD8, 0xFF]);
  return file.path;
}

class _StubGalleryScanner implements DocumentScannerService {
  _StubGalleryScanner(this.path);

  final String path;

  @override
  Future<ScanResult> pickFromGallery() async => ScanResult(imagePaths: [path]);

  @override
  Future<ScanResult> scan() => throw UnimplementedError();
}

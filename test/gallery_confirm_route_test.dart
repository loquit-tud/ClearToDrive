import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('confirm route shows gallery import UI when draft is preset', (tester) async {
    final dir = await Directory.systemTemp.createTemp('ctd_confirm');
    final image = File('${dir.path}/itp.jpg');
    await image.writeAsBytes([0xFF, 0xD8, 0xFF]);

    final draft = ConfirmDraft(
      type: DocumentType.itp,
      licensePlate: '',
      expiryDate: DateTime(2027, 1, 1),
      source: DocumentSource.import,
      imagePath: image.path,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          confirmDraftProvider.overrideWithValue(draft),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, _) => const ConfirmScreen(),
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
    await tester.pump();

    expect(find.textContaining('Am importat imaginea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await dir.delete(recursive: true);
  });
}

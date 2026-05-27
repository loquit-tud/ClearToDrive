import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/router/app_router.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClearToDriveApp extends ConsumerWidget {
  const ClearToDriveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ClearToDrive',
      theme: AppTheme.light(),
      locale: const Locale('ro'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

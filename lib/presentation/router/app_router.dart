import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/presentation/features/add_document/add_document_chooser_screen.dart';
import 'package:cleartodrive/presentation/features/add_document/capture_screen.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/features/document_detail/document_detail_screen.dart';
import 'package:cleartodrive/presentation/features/home/home_screen.dart';
import 'package:cleartodrive/presentation/features/manual_entry/manual_entry_screen.dart';
import 'package:cleartodrive/presentation/features/onboarding/onboarding_screen.dart';
import 'package:cleartodrive/presentation/features/settings/reminder_defaults_screen.dart';
import 'package:cleartodrive/presentation/features/settings/settings_screen.dart';
import 'package:cleartodrive/presentation/features/splash/splash_screen.dart';
import 'package:cleartodrive/presentation/features/vehicles/vehicles_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddDocumentChooserScreen(),
      ),
      GoRoute(
        path: '/add/capture',
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: '/confirm',
        builder: (context, state) => ConfirmScreen(
          initialDraft: state.extra is ConfirmDraft
              ? state.extra! as ConfirmDraft
              : null,
        ),
      ),
      GoRoute(
        path: '/manual',
        builder: (context, state) => const ManualEntryScreen(),
      ),
      GoRoute(
        path: '/document/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DocumentDetailScreen(documentId: id);
        },
      ),
      GoRoute(
        path: '/document/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ConfirmScreen(editDocumentId: id);
        },
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const VehiclesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/reminders',
        builder: (context, state) => const ReminderDefaultsScreen(),
      ),
    ],
    redirect: (context, state) {
      final onboarding = ref.read(onboardingCompleteProvider);
      final location = state.matchedLocation;

      if (onboarding.isLoading) return null;
      final complete = onboarding.value ?? false;

      if (!complete &&
          location != '/' &&
          location != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
  );
});

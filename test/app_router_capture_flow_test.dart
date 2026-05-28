import 'dart:io';

import 'package:cleartodrive/application/use_cases/import_from_gallery_use_case.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:cleartodrive/domain/entities/vehicle.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/features/add_document/add_document_chooser_screen.dart';
import 'package:cleartodrive/presentation/features/add_document/capture_screen.dart';
import 'package:cleartodrive/presentation/features/confirm/confirm_screen.dart';
import 'package:cleartodrive/presentation/features/home/home_screen.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/widgets/document_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

class _TestScanner implements DocumentScannerService {
  _TestScanner({required this.galleryImagePath});

  final String galleryImagePath;
  Future<ScanResult> Function()? galleryResult;
  var scanCalls = 0;
  var galleryCalls = 0;

  @override
  Future<ScanResult> pickFromGallery() async {
    galleryCalls++;
    return galleryResult?.call() ?? ScanResult(imagePaths: [galleryImagePath]);
  }

  @override
  Future<ScanResult> scan() async {
    scanCalls++;
    return const ScanResult(imagePaths: ['fake://scan.jpg']);
  }
}

class _TestOcrService implements DocumentOcrService {
  _TestOcrService({this.result});

  final OcrTextResult? result;
  var calls = 0;

  @override
  Future<OcrTextResult> recognizeText(String imagePath) async {
    calls++;
    return result ??
        const OcrTextResult.success(
          'Certificat ITP B 123 ABC valabil pana 31.12.2026',
        );
  }
}

class _TestExtractor implements DocumentFieldExtractor {
  @override
  Future<ExtractionResult> extractFromText({
    required OcrTextResult ocrText,
    DocumentType? typeHint,
    DateTime? referenceDate,
  }) async {
    if (!ocrText.succeeded || !ocrText.hasText) {
      return ExtractionResult(
        suggestedType: typeHint,
        confidence: 0,
        rawText: ocrText.text,
        needsManualReview: true,
      );
    }
    return ExtractionResult(
      licensePlate: 'B 123 ABC',
      expiryDate: DateTime(2026, 12, 31),
      suggestedType: typeHint,
      confidence: 0.9,
      rawText: 'mock',
    );
  }
}

class _InMemoryVehicleRepository implements VehicleRepository {
  final _vehicles = <String, Vehicle>{};

  @override
  Future<void> delete(String id) async => _vehicles.remove(id);

  @override
  Future<Vehicle?> findByPlate(String normalizedPlate) async {
    for (final vehicle in _vehicles.values) {
      if (vehicle.licensePlate == normalizedPlate) return vehicle;
    }
    return null;
  }

  @override
  Future<List<Vehicle>> getAll() async => _vehicles.values.toList();

  @override
  Future<Vehicle?> getById(String id) async => _vehicles[id];

  @override
  Future<Vehicle> upsert(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
    return vehicle;
  }
}

class _InMemoryDocumentRepository implements DocumentRepository {
  final _documents = <String, VehicleDocument>{};

  @override
  Future<void> delete(String id) async => _documents.remove(id);

  @override
  Future<List<VehicleDocument>> getAll({String? vehicleId}) async {
    return _documents.values
        .where((doc) => vehicleId == null || doc.vehicleId == vehicleId)
        .toList();
  }

  @override
  Future<VehicleDocument?> getById(String id) async => _documents[id];

  @override
  Future<VehicleDocument> save(VehicleDocument document) async {
    _documents[document.id] = document;
    return document;
  }
}

class _TestNotificationScheduler implements NotificationScheduler {
  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissionIfNeeded() async => true;

  @override
  Future<void> scheduleZoned({
    required int notificationId,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required String payload,
  }) async {}
}

Widget _app({required _TestScanner scanner}) {
  return _appWithOcr(scanner: scanner, ocr: _TestOcrService());
}

Widget _appWithOcr({
  required _TestScanner scanner,
  required _TestOcrService ocr,
}) {
  final vehicleRepo = _InMemoryVehicleRepository();
  final documentRepo = _InMemoryDocumentRepository();
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/add',
        builder: (_, _) => const AddDocumentChooserScreen(),
      ),
      GoRoute(path: '/add/capture', builder: (_, _) => const CaptureScreen()),
      GoRoute(
        path: '/confirm',
        builder: (_, state) => ConfirmScreen(
          initialDraft: state.extra is ConfirmDraft
              ? state.extra! as ConfirmDraft
              : null,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('settings')),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (_, _) => const Scaffold(body: Text('vehicles')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      scanAndExtractUseCaseProvider.overrideWithValue(
        ScanAndExtractUseCase(scanner, _TestExtractor()),
      ),
      importFromGalleryUseCaseProvider.overrideWithValue(
        ImportFromGalleryUseCase(scanner, ocr, _TestExtractor()),
      ),
      listDocumentsUseCaseProvider.overrideWithValue(
        ListDocumentsUseCase(documentRepo, vehicleRepo),
      ),
      notificationPermissionProvider.overrideWith(
        (_) => NotificationPermissionNotifier(_TestNotificationScheduler()),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ro'),
    ),
  );
}

Future<File> _createTestImage() async {
  final dir = await Directory.systemTemp.createTemp('ctd_router_image');
  final image = File('${dir.path}/itp.png');
  await image.writeAsBytes(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);
  return image;
}

Future<void> _pumpFrames(WidgetTester tester, [int count = 2]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('router flow: Home to ITP gallery import opens confirm', (
    tester,
  ) async {
    final image = (await tester.runAsync(_createTestImage))!;
    final scanner = _TestScanner(galleryImagePath: image.path);
    final ocr = _TestOcrService();

    await tester.pumpWidget(_appWithOcr(scanner: scanner, ocr: ocr));
    await _pumpFrames(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await _pumpFrames(tester);
    await tester.tap(find.text('ITP'));
    await _pumpFrames(tester);
    await tester.tap(find.text('Importă din galerie'));
    await _pumpFrames(tester, 4);

    expect(scanner.galleryCalls, 1);
    expect(ocr.calls, 1);
    expect(find.byType(ConfirmScreen), findsOneWidget);
    expect(find.textContaining('Am găsit câteva date automat'), findsOneWidget);
    expect(find.text('31.12.2026'), findsOneWidget);
    expect(find.text('B 123 ABC'), findsWidgets);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets('router flow: Home to RCA fake scan opens confirm', (
    tester,
  ) async {
    final image = (await tester.runAsync(_createTestImage))!;
    final scanner = _TestScanner(galleryImagePath: image.path);

    await tester.pumpWidget(_app(scanner: scanner));
    await _pumpFrames(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await _pumpFrames(tester);
    await tester.tap(find.text('RCA'));
    await _pumpFrames(tester);
    await tester.tap(find.text('Scanează document'));
    await _pumpFrames(tester, 4);

    expect(scanner.scanCalls, 1);
    expect(find.byType(ConfirmScreen), findsOneWidget);
    expect(find.text('B 123 ABC'), findsWidgets);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets('router flow: gallery cancel stays on capture', (tester) async {
    final image = (await tester.runAsync(_createTestImage))!;
    final scanner = _TestScanner(galleryImagePath: image.path)
      ..galleryResult = () async => throw const ScanCancelled();

    await tester.pumpWidget(_app(scanner: scanner));
    await _pumpFrames(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await _pumpFrames(tester);
    await tester.tap(find.text('ITP'));
    await _pumpFrames(tester);
    await tester.tap(find.text('Importă din galerie'));
    await _pumpFrames(tester, 4);

    expect(scanner.galleryCalls, 1);
    expect(find.byType(CaptureScreen), findsOneWidget);
    expect(find.text('Importă din galerie'), findsOneWidget);
    expect(find.byType(ConfirmScreen), findsNothing);

    await tester.runAsync(() => image.parent.delete(recursive: true));
  });

  testWidgets(
    'router flow: gallery failure stays on capture and shows snackbar',
    (tester) async {
      final image = (await tester.runAsync(_createTestImage))!;
      final scanner = _TestScanner(galleryImagePath: image.path)
        ..galleryResult = () async => throw const ScanFailed();

      await tester.pumpWidget(_app(scanner: scanner));
      await _pumpFrames(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await _pumpFrames(tester);
      await tester.tap(find.text('ITP'));
      await _pumpFrames(tester);
      await tester.tap(find.text('Importă din galerie'));
      await _pumpFrames(tester, 4);

      expect(scanner.galleryCalls, 1);
      expect(find.byType(CaptureScreen), findsOneWidget);
      expect(
        find.text('Nu am putut importa imaginea. Încearcă din nou.'),
        findsWidgets,
      );
      expect(find.byType(ConfirmScreen), findsNothing);

      await tester.runAsync(() => image.parent.delete(recursive: true));
    },
  );

  testWidgets(
    'router flow: OCR failure opens confirm with image and empty fields',
    (tester) async {
      final image = (await tester.runAsync(_createTestImage))!;
      final scanner = _TestScanner(galleryImagePath: image.path);
      final ocr = _TestOcrService(result: const OcrTextResult.failure());

      await tester.pumpWidget(_appWithOcr(scanner: scanner, ocr: ocr));
      await _pumpFrames(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await _pumpFrames(tester);
      await tester.tap(find.text('ITP'));
      await _pumpFrames(tester);
      await tester.tap(find.text('Importă din galerie'));
      await _pumpFrames(tester, 4);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(scanner.galleryCalls, 1);
      expect(ocr.calls, 1);
      expect(find.byType(ConfirmScreen), findsOneWidget);
      expect(find.byType(DocumentImagePreview), findsOneWidget);
      expect(find.textContaining('Nu am putut citi automat'), findsOneWidget);
      expect(textField.controller?.text, isEmpty);
      expect(find.text('Completează manual'), findsOneWidget);

      await tester.runAsync(() => image.parent.delete(recursive: true));
    },
  );
}

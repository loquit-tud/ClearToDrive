import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/data/repositories/drift_app_preferences_repository.dart';
import 'package:cleartodrive/data/repositories/drift_document_repository.dart';
import 'package:cleartodrive/data/repositories/drift_reminder_schedule_repository.dart';
import 'package:cleartodrive/data/repositories/drift_vehicle_repository.dart';
import 'package:cleartodrive/data/services/local_reminder_service.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:cleartodrive/domain/repositories/app_preferences_repository.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:cleartodrive/domain/services/document_field_extractor.dart';
import 'package:cleartodrive/domain/services/document_ocr_service.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:cleartodrive/platform/document_scanner/composite_document_scanner_service.dart';
import 'package:cleartodrive/platform/document_scanner/fake_document_scanner_service.dart';
import 'package:cleartodrive/platform/document_scanner/image_picker_gallery_scanner_service.dart';
import 'package:cleartodrive/platform/ocr/mlkit_document_ocr_service.dart';
import 'package:cleartodrive/platform/ocr/romanian_document_field_extractor.dart';
import 'package:cleartodrive/platform/storage/document_image_store.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<VehicleRepository>()) return;

  getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
  getIt.registerLazySingleton<DriftReminderScheduleRepository>(
    () => DriftReminderScheduleRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<AppPreferencesRepository>(
    () => DriftAppPreferencesRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<VehicleRepository>(
    () => DriftVehicleRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<DocumentRepository>(
    () => DriftDocumentRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );
  getIt.registerLazySingleton<NotificationScheduler>(
    () => FlutterLocalNotificationsScheduler(
      getIt<FlutterLocalNotificationsPlugin>(),
    ),
  );
  getIt.registerLazySingleton<ReminderService>(
    () => LocalReminderService(
      getIt<DriftReminderScheduleRepository>(),
      getIt<NotificationScheduler>(),
    ),
  );
  getIt.registerLazySingleton<DocumentImageStore>(
    () => AppDocumentImageStore(getIt<Uuid>()),
  );
  getIt.registerLazySingleton<DocumentScannerService>(
    () => CompositeDocumentScannerService(
      scanDelegate: FakeDocumentScannerService(),
      galleryDelegate: ImagePickerGalleryScannerService(
        getIt<DocumentImageStore>(),
      ),
    ),
  );
  getIt.registerLazySingleton<DocumentFieldExtractor>(
    RomanianDocumentFieldExtractor.new,
  );
  getIt.registerLazySingleton<DocumentOcrService>(MlKitDocumentOcrService.new);
  getIt.registerLazySingleton<Uuid>(() => const Uuid());
}

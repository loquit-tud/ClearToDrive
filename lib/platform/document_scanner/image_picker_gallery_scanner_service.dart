import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/platform/storage/document_image_store.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the system gallery and persists the selected image locally.
class ImagePickerGalleryScannerService implements DocumentScannerService {
  ImagePickerGalleryScannerService(this._imageStore, [ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final DocumentImageStore _imageStore;
  final ImagePicker _picker;

  @override
  Future<ScanResult> scan() {
    throw const ScannerUnavailable();
  }

  @override
  Future<ScanResult> pickFromGallery() async {
    try {
      var file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
        requestFullMetadata: false,
      );
      file ??= await _recoverLostPick();
      if (file == null) {
        throw const ScanCancelled();
      }

      final persisted = await _imageStore.persistImportedXFile(file);
      return ScanResult(imagePaths: [persisted]);
    } on ScanFailure {
      rethrow;
    } on PlatformException catch (e) {
      throw ScanFailed(e.message ?? e.code);
    } catch (e) {
      throw ScanFailed(e.toString());
    }
  }

  /// After Android kills the activity under memory pressure, the pick result
  /// may only be available via [ImagePicker.retrieveLostData].
  Future<XFile?> _recoverLostPick() async {
    final lost = await _picker.retrieveLostData();
    if (lost.isEmpty) return null;
    if (lost.exception != null) {
      throw ScanFailed(lost.exception!.code);
    }
    final files = lost.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }
}

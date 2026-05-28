import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/platform/storage/document_image_store.dart';
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
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file == null) {
        throw const ScanCancelled();
      }

      final persisted = await _imageStore.persistImportedImage(file.path);
      return ScanResult(imagePaths: [persisted]);
    } on ScanFailure {
      rethrow;
    } catch (e) {
      throw ScanFailed(e.toString());
    }
  }
}

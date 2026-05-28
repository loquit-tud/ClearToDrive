import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Persists imported document images under the app documents directory.
abstract class DocumentImageStore {
  Future<String> persistImportedImage(String sourcePath);

  /// Copies gallery bytes into app storage (works with content URIs / photo picker).
  Future<String> persistImportedXFile(XFile source);
}

class AppDocumentImageStore implements DocumentImageStore {
  AppDocumentImageStore(this._uuid);

  final Uuid _uuid;

  @override
  Future<String> persistImportedImage(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Source image does not exist: $sourcePath');
    }

    return _writeImportedBytes(
      await source.readAsBytes(),
      p.extension(sourcePath),
    );
  }

  @override
  Future<String> persistImportedXFile(XFile source) async {
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Gallery image is empty');
    }
    return _writeImportedBytes(bytes, p.extension(source.path));
  }

  Future<String> _writeImportedBytes(Uint8List bytes, String ext) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final importDir = Directory(p.join(docsDir.path, 'imported'));
    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }

    final safeExt = ext.isEmpty ? '.jpg' : ext;
    final destPath = p.join(importDir.path, '${_uuid.v4()}$safeExt');
    await File(destPath).writeAsBytes(bytes, flush: true);
    return destPath;
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Persists imported document images under the app documents directory.
abstract class DocumentImageStore {
  Future<String> persistImportedImage(String sourcePath);
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

    final docsDir = await getApplicationDocumentsDirectory();
    final importDir = Directory(p.join(docsDir.path, 'imported'));
    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath);
    final safeExt = ext.isEmpty ? '.jpg' : ext;
    final destPath = p.join(importDir.path, '${_uuid.v4()}$safeExt');
    await source.copy(destPath);
    return destPath;
  }
}

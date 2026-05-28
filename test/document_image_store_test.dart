import 'dart:io';

import 'package:cleartodrive/platform/storage/document_image_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Copies files into [baseDir]/imported (no path_provider — runs in unit tests).
class _TestDocumentImageStore implements DocumentImageStore {
  _TestDocumentImageStore(this.baseDir, this._uuid);

  final Directory baseDir;
  final Uuid _uuid;

  @override
  Future<String> persistImportedImage(String sourcePath) async {
    final importDir = Directory(p.join(baseDir.path, 'imported'));
    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }
    final ext = p.extension(sourcePath);
    final destPath = p.join(importDir.path, '${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}');
    await File(sourcePath).copy(destPath);
    return destPath;
  }
}

void main() {
  test('persistImportedImage copies file into imported directory', () async {
    final baseDir = await Directory.systemTemp.createTemp('ctd_store');
    final source = File(p.join(baseDir.path, 'source.jpg'));
    await source.writeAsBytes([0xFF, 0xD8, 0xFF]);

    final store = _TestDocumentImageStore(baseDir, const Uuid());
    final persisted = await store.persistImportedImage(source.path);

    expect(await File(persisted).exists(), isTrue);
    expect(persisted, contains('imported'));
    expect(persisted, isNot(source.path));

    await baseDir.delete(recursive: true);
  });
}

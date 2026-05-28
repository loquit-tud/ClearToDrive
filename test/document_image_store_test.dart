import 'dart:io';

import 'package:cleartodrive/platform/storage/document_image_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persistImportedImage copies file into app documents/imported', () async {
    final tempDir = await Directory.systemTemp.createTemp('ctd_src');
    final source = File(p.join(tempDir.path, 'itp.jpg'));
    await source.writeAsBytes([0xFF, 0xD8, 0xFF, 0x00]);

    final store = AppDocumentImageStore(const Uuid());
    final persisted = await store.persistImportedImage(source.path);

    expect(await File(persisted).exists(), isTrue);
    expect(persisted, contains('imported'));
    expect(persisted, isNot(source.path));

    final docs = await getApplicationDocumentsDirectory();
    expect(persisted.startsWith(docs.path), isTrue);

    await File(persisted).delete();
    await tempDir.delete(recursive: true);
  });
}

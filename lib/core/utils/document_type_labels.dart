import 'package:cleartodrive/domain/enums/document_enums.dart';

/// Maps [DocumentType] to localized UI labels (Romanian in MVP).
class DocumentTypeLabels {
  const DocumentTypeLabels._();

  static String labelRo(DocumentType type) {
    return switch (type) {
      DocumentType.rca => 'RCA',
      DocumentType.itp => 'ITP',
      DocumentType.rovinieta => 'Rovinietă',
    };
  }

  static DocumentType? fromStorageKey(String? key) {
    if (key == null) return null;
    for (final type in DocumentType.values) {
      if (type.storageKey == key) return type;
    }
    return null;
  }
}

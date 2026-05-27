import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:drift/drift.dart';

class DocumentTypeConverter extends TypeConverter<DocumentType, String> {
  const DocumentTypeConverter();

  @override
  DocumentType fromSql(String fromDb) => DocumentType.values.byName(fromDb);

  @override
  String toSql(DocumentType value) => value.name;
}

class DocumentSourceConverter extends TypeConverter<DocumentSource, String> {
  const DocumentSourceConverter();

  @override
  DocumentSource fromSql(String fromDb) => DocumentSource.values.byName(fromDb);

  @override
  String toSql(DocumentSource value) => value.name;
}

class ReminderStatusConverter extends TypeConverter<ReminderStatus, String> {
  const ReminderStatusConverter();

  @override
  ReminderStatus fromSql(String fromDb) => ReminderStatus.values.byName(fromDb);

  @override
  String toSql(ReminderStatus value) => value.name;
}


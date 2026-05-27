// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTableTable extends VehiclesTable
    with TableInfo<$VehiclesTableTable, VehiclesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    licensePlate,
    displayName,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehiclesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licensePlateMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehiclesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehiclesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VehiclesTableTable createAlias(String alias) {
    return $VehiclesTableTable(attachedDatabase, alias);
  }
}

class VehiclesTableData extends DataClass
    implements Insertable<VehiclesTableData> {
  final String id;
  final String licensePlate;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VehiclesTableData({
    required this.id,
    required this.licensePlate,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['license_plate'] = Variable<String>(licensePlate);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehiclesTableCompanion toCompanion(bool nullToAbsent) {
    return VehiclesTableCompanion(
      id: Value(id),
      licensePlate: Value(licensePlate),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VehiclesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehiclesTableData(
      id: serializer.fromJson<String>(json['id']),
      licensePlate: serializer.fromJson<String>(json['licensePlate']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'licensePlate': serializer.toJson<String>(licensePlate),
      'displayName': serializer.toJson<String?>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VehiclesTableData copyWith({
    String? id,
    String? licensePlate,
    Value<String?> displayName = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VehiclesTableData(
    id: id ?? this.id,
    licensePlate: licensePlate ?? this.licensePlate,
    displayName: displayName.present ? displayName.value : this.displayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VehiclesTableData copyWithCompanion(VehiclesTableCompanion data) {
    return VehiclesTableData(
      id: data.id.present ? data.id.value : this.id,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesTableData(')
          ..write('id: $id, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, licensePlate, displayName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehiclesTableData &&
          other.id == this.id &&
          other.licensePlate == this.licensePlate &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehiclesTableCompanion extends UpdateCompanion<VehiclesTableData> {
  final Value<String> id;
  final Value<String> licensePlate;
  final Value<String?> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VehiclesTableCompanion({
    this.id = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesTableCompanion.insert({
    required String id,
    required String licensePlate,
    this.displayName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       licensePlate = Value(licensePlate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VehiclesTableData> custom({
    Expression<String>? id,
    Expression<String>? licensePlate,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? licensePlate,
    Value<String?>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VehiclesTableCompanion(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesTableCompanion(')
          ..write('id: $id, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleDocumentsTableTable extends VehicleDocumentsTable
    with TableInfo<$VehicleDocumentsTableTable, VehicleDocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleDocumentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles_table (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DocumentType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DocumentType>($VehicleDocumentsTableTable.$convertertype);
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DocumentSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DocumentSource>(
        $VehicleDocumentsTableTable.$convertersource,
      );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    type,
    expiryDate,
    source,
    imagePath,
    confirmedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_documents_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleDocumentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleDocumentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleDocumentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      type: $VehicleDocumentsTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      source: $VehicleDocumentsTableTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VehicleDocumentsTableTable createAlias(String alias) {
    return $VehicleDocumentsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DocumentType, String> $convertertype =
      const DocumentTypeConverter();
  static TypeConverter<DocumentSource, String> $convertersource =
      const DocumentSourceConverter();
}

class VehicleDocumentsTableData extends DataClass
    implements Insertable<VehicleDocumentsTableData> {
  final String id;
  final String vehicleId;
  final DocumentType type;
  final DateTime expiryDate;
  final DocumentSource source;
  final String? imagePath;
  final DateTime confirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VehicleDocumentsTableData({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.expiryDate,
    required this.source,
    this.imagePath,
    required this.confirmedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    {
      map['type'] = Variable<String>(
        $VehicleDocumentsTableTable.$convertertype.toSql(type),
      );
    }
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    {
      map['source'] = Variable<String>(
        $VehicleDocumentsTableTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehicleDocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return VehicleDocumentsTableCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      type: Value(type),
      expiryDate: Value(expiryDate),
      source: Value(source),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      confirmedAt: Value(confirmedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VehicleDocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleDocumentsTableData(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      type: serializer.fromJson<DocumentType>(json['type']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      source: serializer.fromJson<DocumentSource>(json['source']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'type': serializer.toJson<DocumentType>(type),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'source': serializer.toJson<DocumentSource>(source),
      'imagePath': serializer.toJson<String?>(imagePath),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VehicleDocumentsTableData copyWith({
    String? id,
    String? vehicleId,
    DocumentType? type,
    DateTime? expiryDate,
    DocumentSource? source,
    Value<String?> imagePath = const Value.absent(),
    DateTime? confirmedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VehicleDocumentsTableData(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    type: type ?? this.type,
    expiryDate: expiryDate ?? this.expiryDate,
    source: source ?? this.source,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VehicleDocumentsTableData copyWithCompanion(
    VehicleDocumentsTableCompanion data,
  ) {
    return VehicleDocumentsTableData(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      type: data.type.present ? data.type.value : this.type,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      source: data.source.present ? data.source.value : this.source,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleDocumentsTableData(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('type: $type, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    type,
    expiryDate,
    source,
    imagePath,
    confirmedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleDocumentsTableData &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.type == this.type &&
          other.expiryDate == this.expiryDate &&
          other.source == this.source &&
          other.imagePath == this.imagePath &&
          other.confirmedAt == this.confirmedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehicleDocumentsTableCompanion
    extends UpdateCompanion<VehicleDocumentsTableData> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<DocumentType> type;
  final Value<DateTime> expiryDate;
  final Value<DocumentSource> source;
  final Value<String?> imagePath;
  final Value<DateTime> confirmedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VehicleDocumentsTableCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.type = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.source = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleDocumentsTableCompanion.insert({
    required String id,
    required String vehicleId,
    required DocumentType type,
    required DateTime expiryDate,
    required DocumentSource source,
    this.imagePath = const Value.absent(),
    required DateTime confirmedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       type = Value(type),
       expiryDate = Value(expiryDate),
       source = Value(source),
       confirmedAt = Value(confirmedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VehicleDocumentsTableData> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? type,
    Expression<DateTime>? expiryDate,
    Expression<String>? source,
    Expression<String>? imagePath,
    Expression<DateTime>? confirmedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (type != null) 'type': type,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (source != null) 'source': source,
      if (imagePath != null) 'image_path': imagePath,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleDocumentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<DocumentType>? type,
    Value<DateTime>? expiryDate,
    Value<DocumentSource>? source,
    Value<String?>? imagePath,
    Value<DateTime>? confirmedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VehicleDocumentsTableCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $VehicleDocumentsTableTable.$convertertype.toSql(type.value),
      );
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $VehicleDocumentsTableTable.$convertersource.toSql(source.value),
      );
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleDocumentsTableCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('type: $type, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderSchedulesTableTable extends ReminderSchedulesTable
    with TableInfo<$ReminderSchedulesTableTable, ReminderSchedulesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderSchedulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_documents_table (id)',
    ),
  );
  static const VerificationMeta _triggerAtMeta = const VerificationMeta(
    'triggerAt',
  );
  @override
  late final GeneratedColumn<DateTime> triggerAt = GeneratedColumn<DateTime>(
    'trigger_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offsetDaysMeta = const VerificationMeta(
    'offsetDays',
  );
  @override
  late final GeneratedColumn<int> offsetDays = GeneratedColumn<int>(
    'offset_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderStatus>(
        $ReminderSchedulesTableTable.$converterstatus,
      );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    triggerAt,
    offsetDays,
    status,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_schedules_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderSchedulesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('trigger_at')) {
      context.handle(
        _triggerAtMeta,
        triggerAt.isAcceptableOrUnknown(data['trigger_at']!, _triggerAtMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerAtMeta);
    }
    if (data.containsKey('offset_days')) {
      context.handle(
        _offsetDaysMeta,
        offsetDays.isAcceptableOrUnknown(data['offset_days']!, _offsetDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_offsetDaysMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderSchedulesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderSchedulesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      triggerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trigger_at'],
      )!,
      offsetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_days'],
      )!,
      status: $ReminderSchedulesTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
    );
  }

  @override
  $ReminderSchedulesTableTable createAlias(String alias) {
    return $ReminderSchedulesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<ReminderStatus, String> $converterstatus =
      const ReminderStatusConverter();
}

class ReminderSchedulesTableData extends DataClass
    implements Insertable<ReminderSchedulesTableData> {
  final String id;
  final String documentId;
  final DateTime triggerAt;
  final int offsetDays;
  final ReminderStatus status;
  final int notificationId;
  const ReminderSchedulesTableData({
    required this.id,
    required this.documentId,
    required this.triggerAt,
    required this.offsetDays,
    required this.status,
    required this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['trigger_at'] = Variable<DateTime>(triggerAt);
    map['offset_days'] = Variable<int>(offsetDays);
    {
      map['status'] = Variable<String>(
        $ReminderSchedulesTableTable.$converterstatus.toSql(status),
      );
    }
    map['notification_id'] = Variable<int>(notificationId);
    return map;
  }

  ReminderSchedulesTableCompanion toCompanion(bool nullToAbsent) {
    return ReminderSchedulesTableCompanion(
      id: Value(id),
      documentId: Value(documentId),
      triggerAt: Value(triggerAt),
      offsetDays: Value(offsetDays),
      status: Value(status),
      notificationId: Value(notificationId),
    );
  }

  factory ReminderSchedulesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderSchedulesTableData(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      triggerAt: serializer.fromJson<DateTime>(json['triggerAt']),
      offsetDays: serializer.fromJson<int>(json['offsetDays']),
      status: serializer.fromJson<ReminderStatus>(json['status']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'triggerAt': serializer.toJson<DateTime>(triggerAt),
      'offsetDays': serializer.toJson<int>(offsetDays),
      'status': serializer.toJson<ReminderStatus>(status),
      'notificationId': serializer.toJson<int>(notificationId),
    };
  }

  ReminderSchedulesTableData copyWith({
    String? id,
    String? documentId,
    DateTime? triggerAt,
    int? offsetDays,
    ReminderStatus? status,
    int? notificationId,
  }) => ReminderSchedulesTableData(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    triggerAt: triggerAt ?? this.triggerAt,
    offsetDays: offsetDays ?? this.offsetDays,
    status: status ?? this.status,
    notificationId: notificationId ?? this.notificationId,
  );
  ReminderSchedulesTableData copyWithCompanion(
    ReminderSchedulesTableCompanion data,
  ) {
    return ReminderSchedulesTableData(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      triggerAt: data.triggerAt.present ? data.triggerAt.value : this.triggerAt,
      offsetDays: data.offsetDays.present
          ? data.offsetDays.value
          : this.offsetDays,
      status: data.status.present ? data.status.value : this.status,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSchedulesTableData(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    triggerAt,
    offsetDays,
    status,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderSchedulesTableData &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.triggerAt == this.triggerAt &&
          other.offsetDays == this.offsetDays &&
          other.status == this.status &&
          other.notificationId == this.notificationId);
}

class ReminderSchedulesTableCompanion
    extends UpdateCompanion<ReminderSchedulesTableData> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<DateTime> triggerAt;
  final Value<int> offsetDays;
  final Value<ReminderStatus> status;
  final Value<int> notificationId;
  final Value<int> rowid;
  const ReminderSchedulesTableCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.triggerAt = const Value.absent(),
    this.offsetDays = const Value.absent(),
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderSchedulesTableCompanion.insert({
    required String id,
    required String documentId,
    required DateTime triggerAt,
    required int offsetDays,
    required ReminderStatus status,
    required int notificationId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       triggerAt = Value(triggerAt),
       offsetDays = Value(offsetDays),
       status = Value(status),
       notificationId = Value(notificationId);
  static Insertable<ReminderSchedulesTableData> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<DateTime>? triggerAt,
    Expression<int>? offsetDays,
    Expression<String>? status,
    Expression<int>? notificationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (triggerAt != null) 'trigger_at': triggerAt,
      if (offsetDays != null) 'offset_days': offsetDays,
      if (status != null) 'status': status,
      if (notificationId != null) 'notification_id': notificationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderSchedulesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<DateTime>? triggerAt,
    Value<int>? offsetDays,
    Value<ReminderStatus>? status,
    Value<int>? notificationId,
    Value<int>? rowid,
  }) {
    return ReminderSchedulesTableCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      triggerAt: triggerAt ?? this.triggerAt,
      offsetDays: offsetDays ?? this.offsetDays,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (triggerAt.present) {
      map['trigger_at'] = Variable<DateTime>(triggerAt.value);
    }
    if (offsetDays.present) {
      map['offset_days'] = Variable<int>(offsetDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ReminderSchedulesTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSchedulesTableCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  const AppSettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsTableData copyWith({String? key, String? value}) =>
      AppSettingsTableData(key: key ?? this.key, value: value ?? this.value);
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTableTable vehiclesTable = $VehiclesTableTable(this);
  late final $VehicleDocumentsTableTable vehicleDocumentsTable =
      $VehicleDocumentsTableTable(this);
  late final $ReminderSchedulesTableTable reminderSchedulesTable =
      $ReminderSchedulesTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehiclesTable,
    vehicleDocumentsTable,
    reminderSchedulesTable,
    appSettingsTable,
  ];
}

typedef $$VehiclesTableTableCreateCompanionBuilder =
    VehiclesTableCompanion Function({
      required String id,
      required String licensePlate,
      Value<String?> displayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VehiclesTableTableUpdateCompanionBuilder =
    VehiclesTableCompanion Function({
      Value<String> id,
      Value<String> licensePlate,
      Value<String?> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VehiclesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $VehiclesTableTable, VehiclesTableData> {
  $$VehiclesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $VehicleDocumentsTableTable,
    List<VehicleDocumentsTableData>
  >
  _vehicleDocumentsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.vehicleDocumentsTable,
        aliasName: $_aliasNameGenerator(
          db.vehiclesTable.id,
          db.vehicleDocumentsTable.vehicleId,
        ),
      );

  $$VehicleDocumentsTableTableProcessedTableManager
  get vehicleDocumentsTableRefs {
    final manager = $$VehicleDocumentsTableTableTableManager(
      $_db,
      $_db.vehicleDocumentsTable,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _vehicleDocumentsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehicleDocumentsTableRefs(
    Expression<bool> Function($$VehicleDocumentsTableTableFilterComposer f) f,
  ) {
    final $$VehicleDocumentsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.vehicleDocumentsTable,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleDocumentsTableTableFilterComposer(
                $db: $db,
                $table: $db.vehicleDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> vehicleDocumentsTableRefs<T extends Object>(
    Expression<T> Function($$VehicleDocumentsTableTableAnnotationComposer a) f,
  ) {
    final $$VehicleDocumentsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.vehicleDocumentsTable,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleDocumentsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.vehicleDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTableTable,
          VehiclesTableData,
          $$VehiclesTableTableFilterComposer,
          $$VehiclesTableTableOrderingComposer,
          $$VehiclesTableTableAnnotationComposer,
          $$VehiclesTableTableCreateCompanionBuilder,
          $$VehiclesTableTableUpdateCompanionBuilder,
          (VehiclesTableData, $$VehiclesTableTableReferences),
          VehiclesTableData,
          PrefetchHooks Function({bool vehicleDocumentsTableRefs})
        > {
  $$VehiclesTableTableTableManager(_$AppDatabase db, $VehiclesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> licensePlate = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesTableCompanion(
                id: id,
                licensePlate: licensePlate,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String licensePlate,
                Value<String?> displayName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VehiclesTableCompanion.insert(
                id: id,
                licensePlate: licensePlate,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleDocumentsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vehicleDocumentsTableRefs) db.vehicleDocumentsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vehicleDocumentsTableRefs)
                    await $_getPrefetchedData<
                      VehiclesTableData,
                      $VehiclesTableTable,
                      VehicleDocumentsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableTableReferences
                          ._vehicleDocumentsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VehiclesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).vehicleDocumentsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTableTable,
      VehiclesTableData,
      $$VehiclesTableTableFilterComposer,
      $$VehiclesTableTableOrderingComposer,
      $$VehiclesTableTableAnnotationComposer,
      $$VehiclesTableTableCreateCompanionBuilder,
      $$VehiclesTableTableUpdateCompanionBuilder,
      (VehiclesTableData, $$VehiclesTableTableReferences),
      VehiclesTableData,
      PrefetchHooks Function({bool vehicleDocumentsTableRefs})
    >;
typedef $$VehicleDocumentsTableTableCreateCompanionBuilder =
    VehicleDocumentsTableCompanion Function({
      required String id,
      required String vehicleId,
      required DocumentType type,
      required DateTime expiryDate,
      required DocumentSource source,
      Value<String?> imagePath,
      required DateTime confirmedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VehicleDocumentsTableTableUpdateCompanionBuilder =
    VehicleDocumentsTableCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<DocumentType> type,
      Value<DateTime> expiryDate,
      Value<DocumentSource> source,
      Value<String?> imagePath,
      Value<DateTime> confirmedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VehicleDocumentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $VehicleDocumentsTableTable,
          VehicleDocumentsTableData
        > {
  $$VehicleDocumentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTableTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehiclesTable.createAlias(
        $_aliasNameGenerator(
          db.vehicleDocumentsTable.vehicleId,
          db.vehiclesTable.id,
        ),
      );

  $$VehiclesTableTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableTableManager(
      $_db,
      $_db.vehiclesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ReminderSchedulesTableTable,
    List<ReminderSchedulesTableData>
  >
  _reminderSchedulesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderSchedulesTable,
        aliasName: $_aliasNameGenerator(
          db.vehicleDocumentsTable.id,
          db.reminderSchedulesTable.documentId,
        ),
      );

  $$ReminderSchedulesTableTableProcessedTableManager
  get reminderSchedulesTableRefs {
    final manager = $$ReminderSchedulesTableTableTableManager(
      $_db,
      $_db.reminderSchedulesTable,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderSchedulesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleDocumentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTableTable> {
  $$VehicleDocumentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DocumentType, DocumentType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DocumentSource, DocumentSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableTableFilterComposer get vehicleId {
    final $$VehiclesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehiclesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableTableFilterComposer(
            $db: $db,
            $table: $db.vehiclesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reminderSchedulesTableRefs(
    Expression<bool> Function($$ReminderSchedulesTableTableFilterComposer f) f,
  ) {
    final $$ReminderSchedulesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderSchedulesTable,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderSchedulesTableTableFilterComposer(
                $db: $db,
                $table: $db.reminderSchedulesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehicleDocumentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTableTable> {
  $$VehicleDocumentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableTableOrderingComposer get vehicleId {
    final $$VehiclesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehiclesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableTableOrderingComposer(
            $db: $db,
            $table: $db.vehiclesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleDocumentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTableTable> {
  $$VehicleDocumentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DocumentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DocumentSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehiclesTableTableAnnotationComposer get vehicleId {
    final $$VehiclesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehiclesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.vehiclesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reminderSchedulesTableRefs<T extends Object>(
    Expression<T> Function($$ReminderSchedulesTableTableAnnotationComposer a) f,
  ) {
    final $$ReminderSchedulesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderSchedulesTable,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderSchedulesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderSchedulesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehicleDocumentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleDocumentsTableTable,
          VehicleDocumentsTableData,
          $$VehicleDocumentsTableTableFilterComposer,
          $$VehicleDocumentsTableTableOrderingComposer,
          $$VehicleDocumentsTableTableAnnotationComposer,
          $$VehicleDocumentsTableTableCreateCompanionBuilder,
          $$VehicleDocumentsTableTableUpdateCompanionBuilder,
          (VehicleDocumentsTableData, $$VehicleDocumentsTableTableReferences),
          VehicleDocumentsTableData,
          PrefetchHooks Function({
            bool vehicleId,
            bool reminderSchedulesTableRefs,
          })
        > {
  $$VehicleDocumentsTableTableTableManager(
    _$AppDatabase db,
    $VehicleDocumentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleDocumentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VehicleDocumentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VehicleDocumentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DocumentType> type = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<DocumentSource> source = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleDocumentsTableCompanion(
                id: id,
                vehicleId: vehicleId,
                type: type,
                expiryDate: expiryDate,
                source: source,
                imagePath: imagePath,
                confirmedAt: confirmedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required DocumentType type,
                required DateTime expiryDate,
                required DocumentSource source,
                Value<String?> imagePath = const Value.absent(),
                required DateTime confirmedAt,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VehicleDocumentsTableCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                type: type,
                expiryDate: expiryDate,
                source: source,
                imagePath: imagePath,
                confirmedAt: confirmedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleDocumentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleId = false, reminderSchedulesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reminderSchedulesTableRefs) db.reminderSchedulesTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable:
                                        $$VehicleDocumentsTableTableReferences
                                            ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$VehicleDocumentsTableTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reminderSchedulesTableRefs)
                        await $_getPrefetchedData<
                          VehicleDocumentsTableData,
                          $VehicleDocumentsTableTable,
                          ReminderSchedulesTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$VehicleDocumentsTableTableReferences
                                  ._reminderSchedulesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleDocumentsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderSchedulesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehicleDocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleDocumentsTableTable,
      VehicleDocumentsTableData,
      $$VehicleDocumentsTableTableFilterComposer,
      $$VehicleDocumentsTableTableOrderingComposer,
      $$VehicleDocumentsTableTableAnnotationComposer,
      $$VehicleDocumentsTableTableCreateCompanionBuilder,
      $$VehicleDocumentsTableTableUpdateCompanionBuilder,
      (VehicleDocumentsTableData, $$VehicleDocumentsTableTableReferences),
      VehicleDocumentsTableData,
      PrefetchHooks Function({bool vehicleId, bool reminderSchedulesTableRefs})
    >;
typedef $$ReminderSchedulesTableTableCreateCompanionBuilder =
    ReminderSchedulesTableCompanion Function({
      required String id,
      required String documentId,
      required DateTime triggerAt,
      required int offsetDays,
      required ReminderStatus status,
      required int notificationId,
      Value<int> rowid,
    });
typedef $$ReminderSchedulesTableTableUpdateCompanionBuilder =
    ReminderSchedulesTableCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<DateTime> triggerAt,
      Value<int> offsetDays,
      Value<ReminderStatus> status,
      Value<int> notificationId,
      Value<int> rowid,
    });

final class $$ReminderSchedulesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReminderSchedulesTableTable,
          ReminderSchedulesTableData
        > {
  $$ReminderSchedulesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehicleDocumentsTableTable _documentIdTable(_$AppDatabase db) =>
      db.vehicleDocumentsTable.createAlias(
        $_aliasNameGenerator(
          db.reminderSchedulesTable.documentId,
          db.vehicleDocumentsTable.id,
        ),
      );

  $$VehicleDocumentsTableTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$VehicleDocumentsTableTableTableManager(
      $_db,
      $_db.vehicleDocumentsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderSchedulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderSchedulesTableTable> {
  $$ReminderSchedulesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get triggerAt => $composableBuilder(
    column: $table.triggerAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderStatus, ReminderStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleDocumentsTableTableFilterComposer get documentId {
    final $$VehicleDocumentsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.vehicleDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleDocumentsTableTableFilterComposer(
                $db: $db,
                $table: $db.vehicleDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReminderSchedulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderSchedulesTableTable> {
  $$ReminderSchedulesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get triggerAt => $composableBuilder(
    column: $table.triggerAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleDocumentsTableTableOrderingComposer get documentId {
    final $$VehicleDocumentsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.vehicleDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleDocumentsTableTableOrderingComposer(
                $db: $db,
                $table: $db.vehicleDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReminderSchedulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderSchedulesTableTable> {
  $$ReminderSchedulesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get triggerAt =>
      $composableBuilder(column: $table.triggerAt, builder: (column) => column);

  GeneratedColumn<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReminderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$VehicleDocumentsTableTableAnnotationComposer get documentId {
    final $$VehicleDocumentsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.vehicleDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleDocumentsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.vehicleDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReminderSchedulesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderSchedulesTableTable,
          ReminderSchedulesTableData,
          $$ReminderSchedulesTableTableFilterComposer,
          $$ReminderSchedulesTableTableOrderingComposer,
          $$ReminderSchedulesTableTableAnnotationComposer,
          $$ReminderSchedulesTableTableCreateCompanionBuilder,
          $$ReminderSchedulesTableTableUpdateCompanionBuilder,
          (ReminderSchedulesTableData, $$ReminderSchedulesTableTableReferences),
          ReminderSchedulesTableData,
          PrefetchHooks Function({bool documentId})
        > {
  $$ReminderSchedulesTableTableTableManager(
    _$AppDatabase db,
    $ReminderSchedulesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderSchedulesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReminderSchedulesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderSchedulesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<DateTime> triggerAt = const Value.absent(),
                Value<int> offsetDays = const Value.absent(),
                Value<ReminderStatus> status = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderSchedulesTableCompanion(
                id: id,
                documentId: documentId,
                triggerAt: triggerAt,
                offsetDays: offsetDays,
                status: status,
                notificationId: notificationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required DateTime triggerAt,
                required int offsetDays,
                required ReminderStatus status,
                required int notificationId,
                Value<int> rowid = const Value.absent(),
              }) => ReminderSchedulesTableCompanion.insert(
                id: id,
                documentId: documentId,
                triggerAt: triggerAt,
                offsetDays: offsetDays,
                status: status,
                notificationId: notificationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderSchedulesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$ReminderSchedulesTableTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$ReminderSchedulesTableTableReferences
                                        ._documentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderSchedulesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderSchedulesTableTable,
      ReminderSchedulesTableData,
      $$ReminderSchedulesTableTableFilterComposer,
      $$ReminderSchedulesTableTableOrderingComposer,
      $$ReminderSchedulesTableTableAnnotationComposer,
      $$ReminderSchedulesTableTableCreateCompanionBuilder,
      $$ReminderSchedulesTableTableUpdateCompanionBuilder,
      (ReminderSchedulesTableData, $$ReminderSchedulesTableTableReferences),
      ReminderSchedulesTableData,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableTableManager get vehiclesTable =>
      $$VehiclesTableTableTableManager(_db, _db.vehiclesTable);
  $$VehicleDocumentsTableTableTableManager get vehicleDocumentsTable =>
      $$VehicleDocumentsTableTableTableManager(_db, _db.vehicleDocumentsTable);
  $$ReminderSchedulesTableTableTableManager get reminderSchedulesTable =>
      $$ReminderSchedulesTableTableTableManager(
        _db,
        _db.reminderSchedulesTable,
      );
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}

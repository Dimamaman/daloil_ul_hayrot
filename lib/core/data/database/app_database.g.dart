// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReadingEntriesTable extends ReadingEntries
    with TableInfo<$ReadingEntriesTable, ReadingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _readingDateMeta = const VerificationMeta(
    'readingDate',
  );
  @override
  late final GeneratedColumn<String> readingDate = GeneratedColumn<String>(
    'reading_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _hizbNumberMeta = const VerificationMeta(
    'hizbNumber',
  );
  @override
  late final GeneratedColumn<int> hizbNumber = GeneratedColumn<int>(
    'hizb_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    readingDate,
    hizbNumber,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reading_date')) {
      context.handle(
        _readingDateMeta,
        readingDate.isAcceptableOrUnknown(
          data['reading_date']!,
          _readingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingDateMeta);
    }
    if (data.containsKey('hizb_number')) {
      context.handle(
        _hizbNumberMeta,
        hizbNumber.isAcceptableOrUnknown(data['hizb_number']!, _hizbNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_hizbNumberMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      readingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_date'],
      )!,
      hizbNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb_number'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $ReadingEntriesTable createAlias(String alias) {
    return $ReadingEntriesTable(attachedDatabase, alias);
  }
}

class ReadingEntry extends DataClass implements Insertable<ReadingEntry> {
  final int id;
  final String readingDate;
  final int hizbNumber;
  final DateTime completedAt;
  const ReadingEntry({
    required this.id,
    required this.readingDate,
    required this.hizbNumber,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reading_date'] = Variable<String>(readingDate);
    map['hizb_number'] = Variable<int>(hizbNumber);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  ReadingEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReadingEntriesCompanion(
      id: Value(id),
      readingDate: Value(readingDate),
      hizbNumber: Value(hizbNumber),
      completedAt: Value(completedAt),
    );
  }

  factory ReadingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingEntry(
      id: serializer.fromJson<int>(json['id']),
      readingDate: serializer.fromJson<String>(json['readingDate']),
      hizbNumber: serializer.fromJson<int>(json['hizbNumber']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'readingDate': serializer.toJson<String>(readingDate),
      'hizbNumber': serializer.toJson<int>(hizbNumber),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  ReadingEntry copyWith({
    int? id,
    String? readingDate,
    int? hizbNumber,
    DateTime? completedAt,
  }) => ReadingEntry(
    id: id ?? this.id,
    readingDate: readingDate ?? this.readingDate,
    hizbNumber: hizbNumber ?? this.hizbNumber,
    completedAt: completedAt ?? this.completedAt,
  );
  ReadingEntry copyWithCompanion(ReadingEntriesCompanion data) {
    return ReadingEntry(
      id: data.id.present ? data.id.value : this.id,
      readingDate: data.readingDate.present
          ? data.readingDate.value
          : this.readingDate,
      hizbNumber: data.hizbNumber.present
          ? data.hizbNumber.value
          : this.hizbNumber,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingEntry(')
          ..write('id: $id, ')
          ..write('readingDate: $readingDate, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, readingDate, hizbNumber, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingEntry &&
          other.id == this.id &&
          other.readingDate == this.readingDate &&
          other.hizbNumber == this.hizbNumber &&
          other.completedAt == this.completedAt);
}

class ReadingEntriesCompanion extends UpdateCompanion<ReadingEntry> {
  final Value<int> id;
  final Value<String> readingDate;
  final Value<int> hizbNumber;
  final Value<DateTime> completedAt;
  const ReadingEntriesCompanion({
    this.id = const Value.absent(),
    this.readingDate = const Value.absent(),
    this.hizbNumber = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  ReadingEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String readingDate,
    required int hizbNumber,
    required DateTime completedAt,
  }) : readingDate = Value(readingDate),
       hizbNumber = Value(hizbNumber),
       completedAt = Value(completedAt);
  static Insertable<ReadingEntry> custom({
    Expression<int>? id,
    Expression<String>? readingDate,
    Expression<int>? hizbNumber,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (readingDate != null) 'reading_date': readingDate,
      if (hizbNumber != null) 'hizb_number': hizbNumber,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  ReadingEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? readingDate,
    Value<int>? hizbNumber,
    Value<DateTime>? completedAt,
  }) {
    return ReadingEntriesCompanion(
      id: id ?? this.id,
      readingDate: readingDate ?? this.readingDate,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (readingDate.present) {
      map['reading_date'] = Variable<String>(readingDate.value);
    }
    if (hizbNumber.present) {
      map['hizb_number'] = Variable<int>(hizbNumber.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('readingDate: $readingDate, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadingEntriesTable readingEntries = $ReadingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [readingEntries];
}

typedef $$ReadingEntriesTableCreateCompanionBuilder =
    ReadingEntriesCompanion Function({
      Value<int> id,
      required String readingDate,
      required int hizbNumber,
      required DateTime completedAt,
    });
typedef $$ReadingEntriesTableUpdateCompanionBuilder =
    ReadingEntriesCompanion Function({
      Value<int> id,
      Value<String> readingDate,
      Value<int> hizbNumber,
      Value<DateTime> completedAt,
    });

class $$ReadingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingEntriesTable> {
  $$ReadingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingEntriesTable> {
  $$ReadingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingEntriesTable> {
  $$ReadingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ReadingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingEntriesTable,
          ReadingEntry,
          $$ReadingEntriesTableFilterComposer,
          $$ReadingEntriesTableOrderingComposer,
          $$ReadingEntriesTableAnnotationComposer,
          $$ReadingEntriesTableCreateCompanionBuilder,
          $$ReadingEntriesTableUpdateCompanionBuilder,
          (
            ReadingEntry,
            BaseReferences<_$AppDatabase, $ReadingEntriesTable, ReadingEntry>,
          ),
          ReadingEntry,
          PrefetchHooks Function()
        > {
  $$ReadingEntriesTableTableManager(
    _$AppDatabase db,
    $ReadingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> readingDate = const Value.absent(),
                Value<int> hizbNumber = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => ReadingEntriesCompanion(
                id: id,
                readingDate: readingDate,
                hizbNumber: hizbNumber,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String readingDate,
                required int hizbNumber,
                required DateTime completedAt,
              }) => ReadingEntriesCompanion.insert(
                id: id,
                readingDate: readingDate,
                hizbNumber: hizbNumber,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingEntriesTable,
      ReadingEntry,
      $$ReadingEntriesTableFilterComposer,
      $$ReadingEntriesTableOrderingComposer,
      $$ReadingEntriesTableAnnotationComposer,
      $$ReadingEntriesTableCreateCompanionBuilder,
      $$ReadingEntriesTableUpdateCompanionBuilder,
      (
        ReadingEntry,
        BaseReferences<_$AppDatabase, $ReadingEntriesTable, ReadingEntry>,
      ),
      ReadingEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadingEntriesTableTableManager get readingEntries =>
      $$ReadingEntriesTableTableManager(_db, _db.readingEntries);
}

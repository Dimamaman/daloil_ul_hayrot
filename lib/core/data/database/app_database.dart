import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// O'qish kunligi jadvali.
/// readingDate: 'yyyy-MM-dd' formatda — timezone muammosini oldini oladi.
/// hizbNumber: 1-8 — qaysi hizb o'qilgani.
class ReadingEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get readingDate => text().unique()();
  IntColumn get hizbNumber => integer()();
  DateTimeColumn get completedAt => dateTime()();
}

@DriftDatabase(tables: [ReadingEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<List<ReadingEntry>> entriesInRange(String from, String to) {
    return (select(readingEntries)
          ..where(
            (e) =>
                e.readingDate.isBiggerOrEqualValue(from) &
                e.readingDate.isSmallerOrEqualValue(to),
          ))
        .get();
  }

  Future<int> insertEntry(ReadingEntriesCompanion entry) {
    return into(readingEntries).insert(entry);
  }

  Future<int> removeEntry(String readingDate) {
    return (delete(readingEntries)
          ..where((e) => e.readingDate.equals(readingDate)))
        .go();
  }

  Future<ReadingEntry?> getEntry(String readingDate) {
    return (select(readingEntries)
          ..where((e) => e.readingDate.equals(readingDate)))
        .getSingleOrNull();
  }

  Future<List<ReadingEntry>> allEntries() {
    return select(readingEntries).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'daloil.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

import '../../calendar/day_boundary.dart';
import '../../calendar/hizb_cycle.dart';
import '../../calendar/reading_day.dart';
import '../database/app_database.dart';

class CalendarRepository {
  CalendarRepository(this._db);

  final AppDatabase _db;

  Future<void> markDay(ReadingDay day, int hizbNumber) async {
    await _db.insertEntry(
      ReadingEntriesCompanion.insert(
        readingDate: day.toIso8601(),
        hizbNumber: hizbNumber,
        completedAt: DateTime.now(),
      ),
    );
  }

  Future<void> unmarkDay(ReadingDay day) async {
    await _db.removeEntry(day.toIso8601());
  }

  Future<bool> isDayMarked(ReadingDay day) async {
    final entry = await _db.getEntry(day.toIso8601());
    return entry != null;
  }

  Future<Set<ReadingDay>> markedDaysInRange(
    ReadingDay from,
    ReadingDay to,
  ) async {
    final entries = await _db.entriesInRange(
      from.toIso8601(),
      to.toIso8601(),
    );
    return entries.map((e) => ReadingDay.parse(e.readingDate)).toSet();
  }

  Future<int> completedKhatmCount(ReadingDay cycleStart) async {
    final entries = await _db.allEntries();
    final dates = entries.map((e) => ReadingDay.parse(e.readingDate)).toSet();
    return khatmCount(dates, cycleStart);
  }

  /// Bugungi holat: qaysi hizb, belgilanganmi, kun qachon tugaydi.
  Future<TodayStatus> todayStatus({
    required ReadingDay cycleStart,
    required DayBoundaryMode mode,
    int boundaryMinutes = 1080,
  }) async {
    final today = currentReadingDay(
      DateTime.now(),
      mode: mode,
      boundaryMinutes: boundaryMinutes,
    );
    final hizb = hizbForDay(today, cycleStart);
    final marked = await isDayMarked(today);
    final endTime = readingDayEnd(
      today,
      mode: mode,
      boundaryMinutes: boundaryMinutes,
    );

    return TodayStatus(
      readingDay: today,
      hizbNumber: hizb,
      isMarked: marked,
      dayEndsAt: endTime,
    );
  }
}

class TodayStatus {
  const TodayStatus({
    required this.readingDay,
    required this.hizbNumber,
    required this.isMarked,
    required this.dayEndsAt,
  });

  final ReadingDay readingDay;
  final int hizbNumber;
  final bool isMarked;
  final DateTime dayEndsAt;
}

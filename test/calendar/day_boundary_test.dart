import 'package:flutter_test/flutter_test.dart';
import 'package:daloil_ul_hayrot/core/calendar/day_boundary.dart';
import 'package:daloil_ul_hayrot/core/calendar/reading_day.dart';

void main() {
  group('currentReadingDay — mag\'rib rejimi (18:00)', () {
    const mode = DayBoundaryMode.maghrib;
    const boundary = 1080; // 18:00

    test('mag\'ribdan keyin (18:01) → bugungi kun', () {
      final now = DateTime(2026, 9, 6, 18, 1);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });

    test('aniq mag\'rib vaqtida (18:00) → bugungi kun', () {
      final now = DateTime(2026, 9, 6, 18, 0);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });

    test('mag\'ribdan 1 daqiqa oldin (17:59) → kechagi kun', () {
      final now = DateTime(2026, 9, 6, 17, 59);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 5)));
    });

    test('ertalab (08:00) → kechagi kun', () {
      final now = DateTime(2026, 9, 6, 8, 0);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 5)));
    });

    test('yarim tunda (00:00) → kechagi kun', () {
      final now = DateTime(2026, 9, 6, 0, 0);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 5)));
    });

    test('oy chegarasi: 1-oktabr 10:00 → 30-sentabr', () {
      final now = DateTime(2026, 10, 1, 10, 0);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 9, 30)));
    });

    test('yil chegarasi: 1-yanvar 10:00 → 31-dekabr', () {
      final now = DateTime(2027, 1, 1, 10, 0);
      final result = currentReadingDay(now, mode: mode, boundaryMinutes: boundary);
      expect(result, equals(ReadingDay(2026, 12, 31)));
    });
  });

  group('currentReadingDay — yarim tun rejimi', () {
    const mode = DayBoundaryMode.midnight;

    test('23:59 → bugungi kun', () {
      final now = DateTime(2026, 9, 6, 23, 59);
      final result = currentReadingDay(now, mode: mode);
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });

    test('00:00 → bugungi kun', () {
      final now = DateTime(2026, 9, 6, 0, 0);
      final result = currentReadingDay(now, mode: mode);
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });

    test('18:01 — mag\'rib ahamiyati yo\'q', () {
      final now = DateTime(2026, 9, 6, 18, 1);
      final result = currentReadingDay(now, mode: mode);
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });
  });

  group('currentReadingDay — noodatiy mag\'rib vaqti', () {
    test('mag\'rib 19:30 da, hozir 19:29 → kecha', () {
      final now = DateTime(2026, 9, 6, 19, 29);
      final result = currentReadingDay(
        now,
        mode: DayBoundaryMode.maghrib,
        boundaryMinutes: 19 * 60 + 30, // 19:30
      );
      expect(result, equals(ReadingDay(2026, 9, 5)));
    });

    test('mag\'rib 19:30 da, hozir 19:30 → bugun', () {
      final now = DateTime(2026, 9, 6, 19, 30);
      final result = currentReadingDay(
        now,
        mode: DayBoundaryMode.maghrib,
        boundaryMinutes: 19 * 60 + 30,
      );
      expect(result, equals(ReadingDay(2026, 9, 6)));
    });
  });

  group('readingDayEnd', () {
    test('mag\'rib rejimi: 6-sentabr kuni → 7-sentabr 18:00', () {
      final day = ReadingDay(2026, 9, 6);
      final end = readingDayEnd(day, mode: DayBoundaryMode.maghrib);
      expect(end, equals(DateTime(2026, 9, 7, 18, 0)));
    });

    test('yarim tun rejimi: 6-sentabr kuni → 7-sentabr 00:00', () {
      final day = ReadingDay(2026, 9, 6);
      final end = readingDayEnd(day, mode: DayBoundaryMode.midnight);
      expect(end, equals(DateTime(2026, 9, 7)));
    });

    test('oy chegarasi: 30-sentabr → 1-oktabr 18:00', () {
      final day = ReadingDay(2026, 9, 30);
      final end = readingDayEnd(day, mode: DayBoundaryMode.maghrib);
      expect(end, equals(DateTime(2026, 10, 1, 18, 0)));
    });
  });

  group('canMarkDay', () {
    final today = ReadingDay(2026, 9, 6);

    test('bugungi kun — ruxsat', () {
      expect(canMarkDay(today, today), isTrue);
    });

    test('1 kun oldin — ruxsat', () {
      expect(canMarkDay(ReadingDay(2026, 9, 5), today), isTrue);
    });

    test('2 kun oldin — ruxsat', () {
      expect(canMarkDay(ReadingDay(2026, 9, 4), today), isTrue);
    });

    test('3 kun oldin — ruxsat yo\'q', () {
      expect(canMarkDay(ReadingDay(2026, 9, 3), today), isFalse);
    });

    test('kelajakdagi kun — ruxsat yo\'q', () {
      expect(canMarkDay(ReadingDay(2026, 9, 7), today), isFalse);
    });
  });
}

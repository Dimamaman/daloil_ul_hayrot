import 'package:flutter_test/flutter_test.dart';
import 'package:daloil_ul_hayrot/core/calendar/hizb_cycle.dart';
import 'package:daloil_ul_hayrot/core/calendar/reading_day.dart';

void main() {
  group('hizbForDay', () {
    final start = ReadingDay(2026, 9, 1);

    test('tsikl boshlangan kun → hizb 1', () {
      expect(hizbForDay(ReadingDay(2026, 9, 1), start), 1);
    });

    test('2-kun → hizb 2', () {
      expect(hizbForDay(ReadingDay(2026, 9, 2), start), 2);
    });

    test('8-kun → hizb 8', () {
      expect(hizbForDay(ReadingDay(2026, 9, 8), start), 8);
    });

    test('9-kun → hizb 1 (yangi tsikl)', () {
      expect(hizbForDay(ReadingDay(2026, 9, 9), start), 1);
    });

    test('16-kun → hizb 8 (2-tsikl oxiri)', () {
      expect(hizbForDay(ReadingDay(2026, 9, 16), start), 8);
    });

    test('to\'liq 8 kunlik ketma-ketlik', () {
      for (var i = 0; i < 8; i++) {
        expect(hizbForDay(start.addDays(i), start), i + 1);
      }
    });

    test('tsikl boshidan oldingi kun → hizb 8 (orqaga aylanadi)', () {
      expect(hizbForDay(ReadingDay(2026, 8, 31), start), 8);
    });

    test('tsikl boshidan 2 kun oldin → hizb 7', () {
      expect(hizbForDay(ReadingDay(2026, 8, 30), start), 7);
    });
  });

  group('cycleNumber', () {
    final start = ReadingDay(2026, 9, 1);

    test('birinchi 8 kun → tsikl 0', () {
      for (var i = 0; i < 8; i++) {
        expect(cycleNumber(start.addDays(i), start), 0);
      }
    });

    test('9-16 kun → tsikl 1', () {
      for (var i = 8; i < 16; i++) {
        expect(cycleNumber(start.addDays(i), start), 1);
      }
    });

    test('tsikl boshidan oldin → -1', () {
      expect(cycleNumber(ReadingDay(2026, 8, 31), start), -1);
    });
  });

  group('khatmCount', () {
    final start = ReadingDay(2026, 9, 1);

    test('hech narsa belgilanmagan → 0', () {
      expect(khatmCount({}, start), 0);
    });

    test('birinchi 7 kun belgilangan, 8-chi yo\'q → 0', () {
      final days = {for (var i = 0; i < 7; i++) start.addDays(i)};
      expect(khatmCount(days, start), 0);
    });

    test('birinchi 8 kun to\'liq → 1 xatm', () {
      final days = {for (var i = 0; i < 8; i++) start.addDays(i)};
      expect(khatmCount(days, start), 1);
    });

    test('16 kun to\'liq → 2 xatm', () {
      final days = {for (var i = 0; i < 16; i++) start.addDays(i)};
      expect(khatmCount(days, start), 2);
    });

    test('1-tsikl to\'liq, 2-tsiklda 1 kun yetishmaydi → 1 xatm', () {
      final days = <ReadingDay>{};
      for (var i = 0; i < 8; i++) {
        days.add(start.addDays(i));
      }
      for (var i = 8; i < 15; i++) {
        days.add(start.addDays(i));
      }
      expect(khatmCount(days, start), 1);
    });

    test('1-tsiklda gap bor, 2-tsikl to\'liq → 1 xatm', () {
      final days = <ReadingDay>{};
      // 1-tsikl: 3-kunni tashlab ketish
      for (var i = 0; i < 8; i++) {
        if (i != 2) days.add(start.addDays(i));
      }
      // 2-tsikl: hammasi
      for (var i = 8; i < 16; i++) {
        days.add(start.addDays(i));
      }
      expect(khatmCount(days, start), 1);
    });
  });
}

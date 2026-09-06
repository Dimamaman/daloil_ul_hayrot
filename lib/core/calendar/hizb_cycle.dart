import 'reading_day.dart';

const kHizbCount = 8;

/// Berilgan o'qish kunida qaysi hizb o'qilishi kerakligini aniqlaydi.
/// 8 kunlik tsikl: [cycleStart] dan boshlab har kuni navbatdagi hizb.
/// Qaytaradi: 1-8.
int hizbForDay(ReadingDay day, ReadingDay cycleStart) {
  final diff = day.daysSince(cycleStart);
  final index = diff % kHizbCount;
  return (index < 0 ? index + kHizbCount : index) + 1;
}

/// Berilgan kun nechichi tsiklga to'g'ri kelishini qaytaradi (0 dan boshlab).
/// Xatm sonini hisoblash uchun ishlatiladi.
int cycleNumber(ReadingDay day, ReadingDay cycleStart) {
  final diff = day.daysSince(cycleStart);
  if (diff < 0) return -1;
  return diff ~/ kHizbCount;
}

/// To'liq xatm sonini hisoblaydi.
/// [completedDates]: belgilangan kunlar to'plami.
/// Tsikl ichidagi 8 kunning hammasi belgilangan bo'lsa = 1 xatm.
int khatmCount(Set<ReadingDay> completedDates, ReadingDay cycleStart) {
  if (completedDates.isEmpty) return 0;

  final maxDay = completedDates.reduce((a, b) => a > b ? a : b);
  final totalCycles = cycleNumber(maxDay, cycleStart) + 1;
  var count = 0;

  for (var c = 0; c < totalCycles; c++) {
    var allDone = true;
    for (var d = 0; d < kHizbCount; d++) {
      final day = cycleStart.addDays(c * kHizbCount + d);
      if (!completedDates.contains(day)) {
        allDone = false;
        break;
      }
    }
    if (allDone) count++;
  }

  return count;
}

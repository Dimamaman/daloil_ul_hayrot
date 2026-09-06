import 'reading_day.dart';

enum DayBoundaryMode { maghrib, midnight }

/// Hozirgi vaqtda qaysi "o'qish kuni" ekanligini aniqlaydi.
///
/// Mag'rib rejimida (masalan, 18:00):
///   - 6-sentabr 17:59 → o'qish kuni = 5-sentabr (mag'rib bo'lmadi)
///   - 6-sentabr 18:00 → o'qish kuni = 6-sentabr (yangi kun boshlandi)
///
/// Yarim tun rejimida oddiy kalendar kuni qaytadi.
///
/// [boundaryMinutes]: kun chegarasi — yarim tundan boshlab daqiqalarda.
/// Mag'rib uchun default 1080 (18:00). Yarim tun rejimida e'tiborsiz.
ReadingDay currentReadingDay(
  DateTime now, {
  required DayBoundaryMode mode,
  int boundaryMinutes = 1080,
}) {
  if (mode == DayBoundaryMode.midnight) {
    return ReadingDay.fromDateTime(now);
  }

  final nowMinutes = now.hour * 60 + now.minute;
  if (nowMinutes >= boundaryMinutes) {
    return ReadingDay.fromDateTime(now);
  }
  // Mag'rib bo'lmagan — hali kechagi kunning davomi
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  return ReadingDay(yesterday.year, yesterday.month, yesterday.day);
}

/// Berilgan o'qish kuni qachon tugashini qaytaradi.
///
/// Mag'rib rejimida 6-sentabr o'qish kuni →
/// 7-sentabr soat 18:00 da tugaydi.
DateTime readingDayEnd(
  ReadingDay day, {
  required DayBoundaryMode mode,
  int boundaryMinutes = 1080,
}) {
  final next = day.addDays(1).toDateTime();
  if (mode == DayBoundaryMode.midnight) return next;
  return next.add(Duration(minutes: boundaryMinutes));
}

/// O'tkazib yuborilgan kunni belgilash mumkinmi?
/// Faqat bugungi va 2 kun orqagacha ruxsat beriladi.
bool canMarkDay(ReadingDay target, ReadingDay today) {
  final diff = today.daysSince(target);
  return diff >= 0 && diff <= 2;
}

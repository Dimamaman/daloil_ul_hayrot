/// Faqat sana (yil/oy/kun) — vaqt yo'q.
/// DateTime'dan farqi: timezone va soat aralashmasligi uchun.
class ReadingDay implements Comparable<ReadingDay> {
  const ReadingDay(this.year, this.month, this.day);

  factory ReadingDay.fromDateTime(DateTime dt) =>
      ReadingDay(dt.year, dt.month, dt.day);

  final int year;
  final int month;
  final int day;

  DateTime toDateTime() => DateTime(year, month, day);

  int daysSince(ReadingDay other) =>
      toDateTime().difference(other.toDateTime()).inDays;

  ReadingDay addDays(int days) {
    final dt = DateTime(year, month, day + days);
    return ReadingDay(dt.year, dt.month, dt.day);
  }

  String toIso8601() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  factory ReadingDay.parse(String iso) {
    final parts = iso.split('-');
    return ReadingDay(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  int compareTo(ReadingDay other) => toDateTime().compareTo(other.toDateTime());

  @override
  bool operator ==(Object other) =>
      other is ReadingDay &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  bool operator <(ReadingDay other) => compareTo(other) < 0;
  bool operator <=(ReadingDay other) => compareTo(other) <= 0;
  bool operator >(ReadingDay other) => compareTo(other) > 0;
  bool operator >=(ReadingDay other) => compareTo(other) >= 0;

  @override
  String toString() => toIso8601();
}

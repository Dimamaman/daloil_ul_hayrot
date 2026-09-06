import 'package:json_annotation/json_annotation.dart';

part 'reading_progress.g.dart';

/// Foydalanuvchi qayerda to'xtaganini saqlaydi.
/// Kitob kontentidan alohida — SharedPreferences'da turadi.
@JsonSerializable()
class ReadingProgress {
  const ReadingProgress({
    required this.hizbId,
    required this.sectionId,
    this.scrollOffset = 0,
    required this.lastReadAt,
  });

  final String hizbId;
  final String sectionId;

  /// Pikselda scroll holati — qayta ochganda o'sha joyga qaytish uchun
  final double scrollOffset;

  final DateTime lastReadAt;

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingProgressToJson(this);
}

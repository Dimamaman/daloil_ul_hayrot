// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingProgress _$ReadingProgressFromJson(Map<String, dynamic> json) =>
    ReadingProgress(
      hizbId: json['hizbId'] as String,
      sectionId: json['sectionId'] as String,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
    );

Map<String, dynamic> _$ReadingProgressToJson(ReadingProgress instance) =>
    <String, dynamic>{
      'hizbId': instance.hizbId,
      'sectionId': instance.sectionId,
      'scrollOffset': instance.scrollOffset,
      'lastReadAt': instance.lastReadAt.toIso8601String(),
    };

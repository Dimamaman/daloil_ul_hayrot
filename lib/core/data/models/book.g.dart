// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  version: (json['version'] as num).toInt(),
  hizbs: (json['hizbs'] as List<dynamic>)
      .map((e) => Hizb.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'version': instance.version,
  'hizbs': instance.hizbs,
};

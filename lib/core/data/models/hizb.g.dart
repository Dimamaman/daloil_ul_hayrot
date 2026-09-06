// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hizb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hizb _$HizbFromJson(Map<String, dynamic> json) => Hizb(
  id: json['id'] as String,
  order: (json['order'] as num).toInt(),
  title: json['title'] as String,
  titleUz: json['titleUz'] as String?,
  sections: (json['sections'] as List<dynamic>)
      .map((e) => Section.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HizbToJson(Hizb instance) => <String, dynamic>{
  'id': instance.id,
  'order': instance.order,
  'title': instance.title,
  'titleUz': instance.titleUz,
  'sections': instance.sections,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) => Section(
  id: json['id'] as String,
  type: $enumDecode(_$SectionTypeEnumMap, json['type']),
  title: json['title'] as String,
  titleUz: json['titleUz'] as String?,
  arabic: json['arabic'] as String,
  transliteration: json['transliteration'] as String?,
  translation: json['translation'] as String?,
);

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$SectionTypeEnumMap[instance.type]!,
  'title': instance.title,
  'titleUz': instance.titleUz,
  'arabic': instance.arabic,
  'transliteration': instance.transliteration,
  'translation': instance.translation,
};

const _$SectionTypeEnumMap = {
  SectionType.salavot: 'salavot',
  SectionType.duo: 'duo',
  SectionType.names: 'names',
};

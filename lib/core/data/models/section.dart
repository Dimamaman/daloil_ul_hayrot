import 'package:json_annotation/json_annotation.dart';

part 'section.g.dart';

/// Bo'lim turi: kontentni UI'da qanday ko'rsatishni belgilaydi
enum SectionType {
  @JsonValue('salavot')
  salavot,
  @JsonValue('duo')
  duo,
  @JsonValue('names')
  names,
}

@JsonSerializable()
class Section {
  const Section({
    required this.id,
    required this.type,
    required this.title,
    this.titleUz,
    required this.arabic,
    this.transliteration,
    this.translation,
  });

  final String id;
  final SectionType type;

  /// Arabcha sarlavha — doim mavjud
  final String title;

  /// O'zbekcha sarlavha — ixtiyoriy, UI tili uchun
  final String? titleUz;

  /// Asosiy arabcha matn (tashkil bilan)
  final String arabic;

  /// Lotin transliteratsiyasi — ba'zi bo'limlarda yo'q
  final String? transliteration;

  /// O'zbekcha tarjima — ba'zi bo'limlarda yo'q
  final String? translation;

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);

  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

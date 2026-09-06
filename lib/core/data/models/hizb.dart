import 'package:json_annotation/json_annotation.dart';
import 'section.dart';

part 'hizb.g.dart';

@JsonSerializable()
class Hizb {
  const Hizb({
    required this.id,
    required this.order,
    required this.title,
    this.titleUz,
    required this.sections,
  });

  final String id;

  /// Tartib raqami (1-8) — UI'da saralash uchun
  final int order;

  final String title;
  final String? titleUz;
  final List<Section> sections;

  factory Hizb.fromJson(Map<String, dynamic> json) => _$HizbFromJson(json);

  Map<String, dynamic> toJson() => _$HizbToJson(this);
}

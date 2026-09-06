import 'package:json_annotation/json_annotation.dart';
import 'hizb.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  const Book({
    required this.version,
    required this.hizbs,
  });

  /// Sxema versiyasi — migratsiya uchun
  final int version;

  final List<Hizb> hizbs;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}

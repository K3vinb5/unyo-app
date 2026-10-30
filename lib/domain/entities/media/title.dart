import 'package:freezed_annotation/freezed_annotation.dart';

part 'title.freezed.dart';
part 'title.g.dart';

/// The title slots every provider can fill.
///
/// [russian] exists because Shikimori is a Russian-localized database: its
/// `russian` field is the only localized title it has, and the settings screen
/// offers `Russian` as a display language for that provider (WP #64 subpart
/// (b)). Other providers leave it empty.
abstract class Title {
  final String romaji;
  final String english;
  final String nativeTitle;
  final String userPreferred;
  final String russian;

  const Title({
    required this.romaji,
    required this.english,
    required this.nativeTitle,
    required this.userPreferred,
    this.russian = '',
  });

  @override
  String toString() {
    return 'Title(romaji: $romaji, english: $english, nativeTitle: $nativeTitle, userPreferred: $userPreferred, russian: $russian)';
  }
}

@freezed
abstract class TitleModel with _$TitleModel implements Title {
  const factory TitleModel({
    required String romaji,
    required String english,
    required String nativeTitle,
    required String userPreferred,
    @Default('') String russian,
  }) = _TitleModel;

  factory TitleModel.empty() => const TitleModel(
    romaji: '',
    english: '',
    nativeTitle: '',
    userPreferred: '',
  );

  factory TitleModel.fromJson(Map<String, dynamic> json) =>
      _$TitleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$TitleModelToJson(this as _TitleModel);
}

class TitleConverter implements JsonConverter<Title, Map<String, dynamic>> {
  const TitleConverter();

  @override
  Title fromJson(Map<String, dynamic> json) => TitleModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(Title object) =>
      (object as TitleModel).toJson();
}

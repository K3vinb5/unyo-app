// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/data/models/shikimori/media/shikimori_media_mapper.dart';
import 'package:unyo/domain/entities/media/media_character.dart';

part 'shikimori_media_character.freezed.dart';

part 'shikimori_media_character.g.dart';

@freezed
abstract class ShikimoriMediaCharacterModel
    with _$ShikimoriMediaCharacterModel
    implements MediaCharacter {
  const factory ShikimoriMediaCharacterModel({
    required int id,
    required String image,
    required String name,
    required String gender,
    required String description,
    required String dateOfBirth,
    required int age,
  }) = _ShikimoriMediaCharacterModel;

  factory ShikimoriMediaCharacterModel.empty() =>
      const ShikimoriMediaCharacterModel(
        id: -1,
        image: '',
        name: '',
        gender: '',
        description: '',
        dateOfBirth: '',
        age: 0,
      );

  factory ShikimoriMediaCharacterModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriMediaCharacterModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ShikimoriMediaCharacterModelToJson(this as _ShikimoriMediaCharacterModel);

  /// Shikimori's `Character` type carries only `id`, `name`, `poster` and
  /// `russian` — no gender, age, birthday or biography — so the placeholder
  /// values stay and only the identity fields are mapped.
  factory ShikimoriMediaCharacterModel.fromRole({
    required String id,
    required String name,
    required String image,
  }) {
    return ShikimoriMediaCharacterModel(
      id: ShikimoriMediaMapper.parseId(id),
      image: image,
      name: name,
      gender: 'Unknown',
      description: 'No description available',
      dateOfBirth: 'Unknown',
      age: -1,
    );
  }
}

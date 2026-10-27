import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'media_list_state.freezed.dart';

@freezed
abstract class MediaListState with _$MediaListState implements HasEffects{
  const factory MediaListState({
    required Map<String, List<Anime>> userAnimeLists,
    required Map<String, List<Manga>> userMangaLists,
    required User loggedUser,
    required bool isLoading,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _MediaListState;

  const MediaListState._();

  @override
  List<AppEffect> get stateEffects => effects;
}
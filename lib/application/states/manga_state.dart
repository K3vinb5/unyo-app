// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'manga_state.freezed.dart';

@freezed
abstract class MangaState with _$MangaState implements HasEffects{
  const factory MangaState({
    required (bool, List<Manga>) trending,
    required (bool, List<Manga>) recentlyCompleted,
    required (bool, List<Manga>) popular,
    required (bool, List<Manga>) upcoming,
    required List<Manga> banners,
    required User loggedUser,
    required bool isLoading,
    @Default(true) bool metadataServiceSupported,
    @Default(<AppEffect>[]) List<AppEffect> effects,
    required bool userLoaded,
  }) = _MangaState;

  const MangaState._();

  @override
  List<AppEffect> get stateEffects => effects;
}
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo_lib/jmodels/jsanime.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'anime_details_state.freezed.dart';

@freezed
abstract class AnimeDetailsState with _$AnimeDetailsState implements HasEffects{
  const factory AnimeDetailsState({
    required User loggedUser,
    required MediaList selectedMediaList,
    required Anime selectedAnime,
    required MediaListEntry mediaListEntry,
    required MediaListEntry newMediaListEntry,
    required (bool, List<MediaCharacter>) characters,
    required (bool, List<Anime>) recommendations,
    required List<EpisodeInfo> episodesInfo,
    required bool episodesLoaded,
    required List<String> banners,
    required String alternateImage,
    required Set<Extension> installedExtensions,
    required bool userLoaded,
    required bool animeServerDialogReady,
    required bool animeServerDialogLoading,
    required Extension? selectedExtension,
    // relations
    // voice actors
    required List<JSAnime> extensionAnimeResults,
    required int selectedAnimeResultIndex,
    required List<JSEpisode> extensionEpisodeResults,
    required List<ext.Video> extensionVideoResults,
    /// True when the opened record could not be matched to the metadata
    /// provider, so the page shows user-provider details and offers the manual
    /// relink action.
    @Default(false) bool mediaLinkUnresolved,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _AnimeDetailsState;

  const AnimeDetailsState._();

  @override
  List<AppEffect> get stateEffects => effects;
}

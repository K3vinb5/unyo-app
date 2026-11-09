import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo_lib/jmodels/jpage.dart';
import 'package:unyo_lib/jmodels/jschapter.dart';
import 'package:unyo_lib/jmodels/jsmanga.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'manga_details_state.freezed.dart';

@freezed
abstract class MangaDetailsState with _$MangaDetailsState implements HasEffects{
  const factory MangaDetailsState({
    required User loggedUser,
    required MediaList selectedMediaList,
    required Manga selectedManga,
    required MediaListEntry mediaListEntry,
    /// The editor's draft copy (WP #167): seeded from [mediaListEntry] when the
    /// entry loads and mutated by the dialog's sliders until Confirm writes it.
    required MediaListEntry newMediaListEntry,
    required (bool, List<MediaCharacter>) characters,
    required (bool, List<Manga>) recommendations,
    required List<String> banners,
    required String alternateImage,
    required Set<Extension> installedExtensions,
    required bool userLoaded,
    required Extension? selectedExtension,
    // relations
    // voice actors
    required List<JSManga> extensionMangaResults,
    required List<JSChapter> extensionEpisodeResults,
    required List<JPage> extensionVideoResults,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _MangaDetailsState;

  const MangaDetailsState._();

  @override
  List<AppEffect> get stateEffects => effects;
}

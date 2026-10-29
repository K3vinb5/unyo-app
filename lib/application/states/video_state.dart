import 'package:cast/cast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/entities/media/video_info.dart';

part 'video_state.freezed.dart';

@freezed
abstract class VideoState with _$VideoState implements HasEffects{
  const factory VideoState({
    required User loggedUser,
    required VideoInfo videoInfo,
    required Anime selectedAnime,
    required List<EpisodeInfo> episodesInfo,
    required bool episodesLoaded,
    required Extension selectedExtension,
    required List<JSEpisode> extensionEpisodeResults,
    required MediaListEntry mediaListEntry,
    required List<CastDevice> availableCastDevices,
    required AniskipTimesResults openingSkipTimes,
    required AniskipTimesResults endingSkipTimes,
    required bool isLoading,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _VideoState;

  const VideoState._();

  @override
  List<AppEffect> get stateEffects => effects;
}

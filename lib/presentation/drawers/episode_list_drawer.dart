// External dependencies
import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/application/states/episode_count.dart';
import 'package:unyo/application/states/video_state.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/unyo_episode_button.dart';

class EpisodeListDrawer extends StatelessWidget {
  final VideoCubit cubit;

  const EpisodeListDrawer({super.key, required this.cubit});

  List<Widget> _getEpisodeButtonsWidgets(BuildContext context, VideoState state) {
    final int numEpisodes = EpisodeCount.resolve(
      extensionResults: state.extensionEpisodeResults.length,
      episodesInfo: state.episodesInfo.length,
      metadataTotal: state.selectedAnime.episodes,
    );
    if (numEpisodes == 0) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80.h),
            const Text(
              "Nothing to see here! Come back later :D",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 3,
            ),
          ],
        ),
      ];
    }
    List<Widget> episodeButtons = [];
    final List<int> episodeNumbers = EpisodeCount.episodeNumbers(
      extensionEpisodeNumbers: state.extensionEpisodeResults
          .map((episode) => episode.getEpisode_number().toInt())
          .toList(growable: false),
      count: numEpisodes,
    );
    for (int i = 0; i < numEpisodes; i++) {
      final int episodeNumber = episodeNumbers[i];
      episodeButtons.add(
        UnyoEpisodeButton(
          mainTitle: "Episode $episodeNumber",
          secondaryTitle: state.episodesInfo.length > i
              ? (state.episodesInfo[i].title.userPreferred != ""
                    ? state.episodesInfo[i].title.userPreferred
                    : "")
              : "",
          episodeImageUrl: state.episodesInfo.length > i
              ? (state.episodesInfo[i].image != ""
                    ? state.episodesInfo[i].image
                    : state.selectedAnime.coverImage)
              : state.selectedAnime.coverImage,
          episodeNumber: episodeNumber,
          progress: state.mediaListEntry.progress,
          released: state.selectedAnime.nextAiringEpisode.episode != 0
              ? (state.selectedAnime.nextAiringEpisode.episode - 1)
              : numEpisodes,
          showDivider: i != 0,
          onPressed: ()
          {
            context.read<VideoCubit>().navigateToEpisode(i);
          }
        ),
      );
    }
    return episodeButtons;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) => SkeletonScope(
          child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: 450.w,
                height: 1.sh,
                padding: EdgeInsets.only(top: 20.h, bottom: 20.h, left: 15.w, right: 25.w),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                    color: ColorScheme.of(context).secondary.withValues(alpha: 0.6)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Episodes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.close),
                              color: ColorScheme.of(context).tertiary,
                              onPressed: () => Navigator.of(context).pop()
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: ListView(
                        children: [
                          if (!state.episodesLoaded)
                            ...List.generate(
                              state.selectedAnime.episodes.clamp(1, 8),
                              (index) => EpisodeRowSkeleton(showDivider: index != 0),
                            )
                          else
                            ..._getEpisodeButtonsWidgets(context, state),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

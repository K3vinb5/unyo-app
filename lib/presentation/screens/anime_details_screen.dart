// External package dependencies
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal package dependencies
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/anime_recommendations_card_list.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_media_banner.dart';
import 'package:unyo/presentation/widgets/styled/unyo_character_list.dart';
import 'package:unyo/presentation/widgets/text/text_body_medium.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

@RoutePage()
class AnimeDetailsScreen extends StatelessWidget {
  const AnimeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<AnimeDetailsCubit>(), child: const _AnimeDetailsListener());
  }
}

class _AnimeDetailsListener extends StatelessWidget {
  const _AnimeDetailsListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimeDetailsCubit, AnimeDetailsState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<AnimeDetailsCubit>().clearEffects,
          );
        }
      },
      child: BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
        builder: (context, state) => const _AnimeDetailsView(),
      ),
    );
  }
}

class _AnimeDetailsView extends StatefulWidget {
  const _AnimeDetailsView();

  @override
  State<_AnimeDetailsView> createState() => _AnimeDetailsViewState();
}

class _AnimeDetailsViewState extends State<_AnimeDetailsView> {
  final ScrollController charactersListController = ScrollController();
  final ScrollController recommendedAnimesController = ScrollController();

  @override
  void dispose() {
    charactersListController.dispose();
    recommendedAnimesController.dispose();
    super.dispose();
  }

  List<Widget> _getEpisodeButtonsWidgets(AnimeDetailsState state) {
    int numEpisodes = max(state.selectedAnime.episodes, state.episodesInfo.length);
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
    for (int i = 0; i < numEpisodes; i++) {
      episodeButtons.add(
        UnyoEpisodeButton(
          mainTitle: "Episode ${i + 1}",
          secondaryTitle:
              state.episodesInfo.length > i
                  ? (state.episodesInfo[i].title.userPreferred != ""
                      ? state.episodesInfo[i].title.userPreferred
                      : "")
                  : "",
          episodeImageUrl:
              state.episodesInfo.length > i
                  ? (state.episodesInfo[i].image != "" ? state.episodesInfo[i].image : state.alternateImage)
                  : (state.alternateImage != "" ? state.alternateImage : state.selectedAnime.coverImage),
          episodeNumber: i + 1,
          progress: state.mediaListEntry.progress,
          released:
              state.selectedAnime.nextAiringEpisode.episode != 0
                  ? (state.selectedAnime.nextAiringEpisode.episode - 1)
                  : numEpisodes,
          showDivider: i != 0,
          onPressed: () => context.read<AnimeDetailsCubit>().openAnimeServerSelectionDrawer(context, i),
        ),
      );
    }
    return episodeButtons;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
      builder: (context, state) {
        return SkeletonScope(
          child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        onPressed: () => context.read<AnimeDetailsCubit>().navigateBackToAnimePage(context),
                        icon: Icon(key: const ValueKey('back-button'), Icons.arrow_back_ios_new_rounded, color: ColorScheme.of(context).tertiary),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 75,
                    child: SizedBox(
                      height: 1.sh - 60,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                state.selectedAnime.id == 0
                                    ? const DetailHeaderSkeleton()
                                    : UnyoMediaBanner(
                                  imageUrl:
                                      state.selectedAnime.bannerImage != ""
                                          ? state.selectedAnime.bannerImage
                                          : (state.alternateImage != ""
                                              ? state.alternateImage
                                              : state.selectedAnime.coverImage),
                                  coverImage:
                                      state.selectedAnime.coverImage != ""
                                          ? state.selectedAnime.coverImage
                                          : state.alternateImage,
                                  title: state.selectedAnime.title.userPreferred,
                                  status: state.selectedAnime.status,
                                  tag: "${state.selectedMediaList.name}-${state.selectedAnime.id}",
                                ),
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              UnyoBannerIcon(
                                                text: "${state.selectedAnime.duration}min",
                                                iconData: Icons.timelapse_rounded,
                                              ),
                                              UnyoBannerIcon(
                                                text: TextUtils.extractYearFromStartDate(
                                                  state.selectedAnime.startDate,
                                                  state.loggedUser,
                                                ),
                                                iconData: Icons.calendar_month_rounded,
                                              ),
                                              UnyoBannerIcon(
                                                text: state.selectedAnime.averageScore.toString(),
                                                iconData: Icons.star,
                                              ),
                                            ],
                                          ),
                                          // TODO: extract to a widget
                                          UnyoInkWell(
                                            child: Container(
                                              width: 120.w,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  state.mediaListEntry.status,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onTap: () => context.read<AnimeDetailsCubit>().openAnimeDetailsMediaEntryDialog(context),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 13.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextBodyMedium(
                                              text: TextUtils.parseHtmlToPlainText(
                                                state.selectedAnime.description,
                                              ),
                                              maxLines: 8,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      height: 85,
                                      child: Row(
                                        children: [
                                          ...state.selectedAnime.genres.mapIndexed(
                                            (index, genre) => Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              child: SizedBox(
                                                width: 210,
                                                child: MediaButton(
                                                  width: 200,
                                                  height: 70,
                                                  onPressed:
                                                      () => context
                                                          .read<AnimeDetailsCubit>()
                                                          .navigateToAnimeAdvancedSearchScreenWithFilters(
                                                            context,
                                                            genre,
                                                          ),
                                                  image: state.banners.isNotEmpty ? state.banners[index] : "",
                                                  text: genre,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                state.characters.$1
                                    ? UnyoCharacterList(
                                      characters: state.characters.$2,
                                      controller: charactersListController,
                                    )
                                    : const CardRowSkeleton(),
                                SizedBox(height: 20.h),
                                state.recommendations.$1
                                    ? AnimeRecommendationCardList(
                                      onPressed: context.read<AnimeDetailsCubit>().navigateToAnimeDetails,
                                      listTitle: "Recommended Animes",
                                      animeList: state.recommendations.$2,
                                      controller: recommendedAnimesController,
                                      loadMore: false,
                                    )
                                    : const CardRowSkeleton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 35,
                    child: Container(
                      height: 1.sh - 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22.w),
                              child: UnyoDropdown(
                                onPressed:
                                    (selectedExtensionName) => context
                                        .read<AnimeDetailsCubit>()
                                        .selectAnimeExtension(selectedExtensionName),
                                selectedValue: state.selectedExtension?.name,
                                label: "Select Extension",
                                children: [...state.installedExtensions.map((extension) => extension.name)],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Expanded(
                            child: ListView(
                              children: [
                                if (!state.episodesLoaded)
                                  ...List.generate(
                                    state.selectedAnime.episodes.clamp(1, 6),
                                    (index) => EpisodeRowSkeleton(showDivider: index != 0),
                                  )
                                else
                                  ..._getEpisodeButtonsWidgets(state),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

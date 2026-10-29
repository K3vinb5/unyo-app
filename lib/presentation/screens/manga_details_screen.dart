// External package dependencies
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal package dependencies
import 'package:unyo/application/cubits/manga_details_cubit.dart';
import 'package:unyo/application/states/manga_details_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/manga_recommendations_card_list.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_media_banner.dart';
import 'package:unyo/presentation/widgets/styled/unyo_character_list.dart';
import 'package:unyo/presentation/widgets/text/text_body_medium.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

@RoutePage()
class MangaDetailsScreen extends StatelessWidget {
  const MangaDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<MangaDetailsCubit>(), child: const _MangaDetailsListener());
  }
}

class _MangaDetailsListener extends StatelessWidget {
  const _MangaDetailsListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MangaDetailsCubit, MangaDetailsState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<MangaDetailsCubit>().clearEffects,
          );
        }
      },
      child: BlocBuilder<MangaDetailsCubit, MangaDetailsState>(
        builder: (context, state) => const _MangaDetailsView(),
      ),
    );
  }
}

class _MangaDetailsView extends StatefulWidget {
  const _MangaDetailsView();

  @override
  State<_MangaDetailsView> createState() => _MangaDetailsViewState();
}

class _MangaDetailsViewState extends State<_MangaDetailsView> {
  final ScrollController charactersListController = ScrollController();
  final ScrollController recommendedMangasController = ScrollController();

  @override
  void dispose() {
    charactersListController.dispose();
    recommendedMangasController.dispose();
    super.dispose();
  }

  List<Widget> _getEpisodeButtonsWidgets(MangaDetailsState state) {
    int numChapters = state.selectedManga.chapters;
    if (numChapters == 0) {
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
    for (int i = 0; i < numChapters; i++) {
      episodeButtons.add(
        UnyoEpisodeButton(
          mainTitle: "Chapter ${i + 1}",
          secondaryTitle: "${state.selectedManga.title.userPreferred} Chapter ${i + 1}",
          episodeImageUrl: state.selectedManga.bannerImage != "" ? state.selectedManga.bannerImage : state.selectedManga.coverImage,
          episodeNumber: i + 1,
          progress: state.mediaListEntry.progress,
          released: numChapters,
          showDivider: i != 0,
          onPressed: () => context.read<MangaDetailsCubit>().openMangaServerSelectionDrawer(context, i),
        ),
      );
    }
    return episodeButtons;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailsCubit, MangaDetailsState>(
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
                        onPressed: () => context.read<MangaDetailsCubit>().navigateBackToMangaPage(context),
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
                                state.selectedManga.id == 0
                                    ? const DetailHeaderSkeleton()
                                    : UnyoMediaBanner(
                                  imageUrl:
                                  state.selectedManga.bannerImage != ""
                                      ? state.selectedManga.bannerImage
                                      : (state.alternateImage != ""
                                      ? state.alternateImage
                                      : state.selectedManga.coverImage),
                                  coverImage:
                                  state.selectedManga.coverImage != ""
                                      ? state.selectedManga.coverImage
                                      : state.alternateImage,
                                  title: state.selectedManga.title.userPreferred,
                                  status: state.selectedManga.status,
                                  tag: "${state.selectedMediaList.name}-${state.selectedManga.id}",
                                ),
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              UnyoBannerIcon(
                                                text: TextUtils.extractYearFromStartDate(state.selectedManga.startDate),
                                                iconData: Icons.calendar_month_rounded,
                                              ),
                                              UnyoBannerIcon(
                                                text: state.selectedManga.averageScore.toString(),
                                                iconData: Icons.star,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 13.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextBodyMedium(
                                              text: TextUtils.parseHtmlToPlainText(
                                                state.selectedManga.description,
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
                                          ...state.selectedManga.genres.mapIndexed(
                                                (index, genre) => Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              child: SizedBox(
                                                width: 210,
                                                child: MediaButton(
                                                  width: 200,
                                                  height: 70,
                                                  onPressed:
                                                      () => context
                                                          .read<MangaDetailsCubit>()
                                                          .navigateToMangaAdvancedSearchScreenWithFilters(
                                                            context,
                                                            genre
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
                                    ? MangaRecommendationCardList(
                                  onPressed: context.read<MangaDetailsCubit>().navigateToMangaDetails,
                                  listTitle: "Recommended Mangas",
                                  mangaList: state.recommendations.$2,
                                  controller: recommendedMangasController,
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
                                onPressed: (selectedExtensionName) => context.read<MangaDetailsCubit>().selectMangaExtension(selectedExtensionName),
                                selectedValue: state.selectedExtension?.name,
                                label: "Select Extension",
                                children: [
                                  ...state.installedExtensions.map(
                                        (extension) => extension.name,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Expanded(child: ListView(children: [..._getEpisodeButtonsWidgets(state)])),
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

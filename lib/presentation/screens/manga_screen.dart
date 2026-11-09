// External dependencies
import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/manga_cubit.dart';
import 'package:unyo/application/states/manga_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/card_row_frame.dart';
import 'package:unyo/presentation/widgets/styled/manga_card_list.dart';
import 'package:unyo/presentation/widgets/styled/media_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

@RoutePage()
class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MangaCubit>(),
      child: const _MangaListener(),
    );
  }
}

class _MangaListener extends StatelessWidget {
  const _MangaListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MangaCubit, MangaState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<MangaCubit>().clearEffects,
          );
        }
      },
      // The real layout renders immediately; unfinished sections show
      // skeletons instead of swapping the whole screen for a spinner.
      child: const SkeletonScope(child: _MangaView()),
    );
  }
}

class _MangaView extends StatefulWidget {
  const _MangaView();

  @override
  State<_MangaView> createState() => _MangaViewState();
}

class _MangaViewState extends State<_MangaView> {
  final ScrollController trendingController = ScrollController();
  final ScrollController recentlyCompletedController = ScrollController();
  final ScrollController popularController = ScrollController();
  final ScrollController upcomingController = ScrollController();

  @override
  void dispose() {
    trendingController.dispose();
    recentlyCompletedController.dispose();
    popularController.dispose();
    upcomingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaCubit, MangaState>(
      builder: (context, state) {
        if (!state.metadataServiceSupported) {
          // The provider has no manga implementation at all: say so instead of
          // rendering the empty rows a failed or empty load would produce.
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0.w),
              child: Text(
                context.tr(
                  'error_manga_unsupported',
                  namedArgs: <String, String>{
                    'provider': TextUtils.capitalize(state.loggedUser.settings.metadataService.name),
                  },
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: ColorScheme.of(context).tertiary,
                ),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20.0.h),
              switch (bannerHeaderMode(
                isLoading: state.isLoading,
                hasBanners: state.banners.isNotEmpty,
              )) {
                BannerHeaderMode.skeleton => const BannerCarouselSkeleton(),
                BannerHeaderMode.hidden => const SizedBox.shrink(),
                BannerHeaderMode.carousel => UnyoBannerCarousel(
                  mangaList: state.banners,
                  onTapManga: context.read<MangaCubit>().navigateToMangaDetails,
                ),
              },
              const SizedBox(height: 40),
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // No Calendar button on the manga browse, on purpose: the
                    // calendar tab is anime-only by data model. Every provider's
                    // schedule feed is `AnimeRepository.getCalendarReleases`
                    // (MAL: Jikan `/schedules`; AniList: `nextAiringEpisode`;
                    // Shikimori: `/api/calendar` `next_episode_at`) and
                    // `MangaRepository` has no calendar method at all, so a
                    // manga calendar could only show anime. The button that sat
                    // here had an empty handler (WP #169).
                    MediaButton(
                      onPressed: () => context.read<MangaCubit>().navigateToAdvancedSearch(context),
                      image:
                          state.banners.isNotEmpty
                              ? state
                                  .banners[0]
                                  .bannerImage
                              : "",
                      text: context.tr('common_advanced_search'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              state.trending.$1
                  ? CardRowFrame.browse(
                    child: MangaCardList(
                      listTitle: context.tr('common_trending_mangas'),
                      mangaList: state.trending.$2,
                      controller: trendingController,
                      onPressed: context.read<MangaCubit>().navigateToMangaDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.recentlyCompleted.$1
                  ? CardRowFrame.browse(
                    child: MangaCardList(
                      listTitle: context.tr('common_recently_completed_mangas'),
                      mangaList: state.recentlyCompleted.$2,
                      controller: recentlyCompletedController,
                      onPressed: context.read<MangaCubit>().navigateToMangaDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.popular.$1
                  ? CardRowFrame.browse(
                    child: MangaCardList(
                      listTitle: context.tr('common_popular_mangas'),
                      mangaList: state.popular.$2,
                      controller: popularController,
                      onPressed: context.read<MangaCubit>().navigateToMangaDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.upcoming.$1
                  ? CardRowFrame.browse(
                    child: MangaCardList(
                      listTitle: context.tr('common_upcoming_mangas'),
                      mangaList: state.upcoming.$2,
                      controller: upcomingController,
                      onPressed: context.read<MangaCubit>().navigateToMangaDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
            ],
          ),
        );
      },
    );
  }
}

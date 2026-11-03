// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Internal dependencies
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/application/states/anime_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/anime_card_list.dart';
import 'package:unyo/presentation/widgets/styled/card_row_frame.dart';
import 'package:unyo/presentation/widgets/styled/media_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';

@RoutePage()
class AnimeScreen extends StatelessWidget {
  const AnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnimeCubit>(),
      child: const _AnimeListener(),
    );
  }
}

class _AnimeListener extends StatelessWidget {
  const _AnimeListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimeCubit, AnimeState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<AnimeCubit>().clearEffects,
          );
        }
      },
      // The real layout renders immediately; unfinished sections show
      // skeletons instead of swapping the whole screen for a spinner.
      child: const SkeletonScope(child: _AnimeView()),
    );
  }
}

class _AnimeView extends StatefulWidget {

  const _AnimeView();

  @override
  State<_AnimeView> createState() => _AnimeViewState();
}

class _AnimeViewState extends State<_AnimeView> {
  final ScrollController recentlyReleasedController = ScrollController();
  final ScrollController trendingController = ScrollController();
  final ScrollController recentlyCompletedController = ScrollController();
  final ScrollController popularController = ScrollController();
  final ScrollController upcomingController = ScrollController();

  @override
  void dispose() {
    recentlyReleasedController.dispose();
    trendingController.dispose();
    recentlyCompletedController.dispose();
    popularController.dispose();
    upcomingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimeCubit, AnimeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20.0.h),
              state.banners.isEmpty
                  ? const BannerCarouselSkeleton()
                  : UnyoBannerCarousel(
                    animeList: state.banners,
                    onTapAnime: context.read<AnimeCubit>().navigateToAnimeDetails,
                  ),
              const SizedBox(height: 40,),
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MediaButton(
                      onPressed: () => context.read<AnimeCubit>().navigateToCalendar(context),
                      image:
                          state.banners.isNotEmpty ? state.banners[0].bannerImage : "",
                      text: context.tr('common_calendar'),
                    ),
                    const SizedBox(width: 30,),
                    MediaButton(
                      onPressed: () => context.read<AnimeCubit>().navigateToAdvancedSearch(context),
                      image:
                          state.banners.isNotEmpty ? state.banners[1].bannerImage : "",
                      text: context.tr('common_advanced_search'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40,),
              state.recentlyReleased.$1
                  ? CardRowFrame.browse(
                    child: AnimeCardList(
                      listTitle: context.tr('common_recently_released'),
                      animeList: state.recentlyReleased.$2,
                      controller: recentlyReleasedController,
                      onPressed: context.read<AnimeCubit>().navigateToAnimeDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.trending.$1
                  ? CardRowFrame.browse(
                    child: AnimeCardList(
                      listTitle: context.tr('common_trending_animes'),
                      animeList: state.trending.$2,
                      controller: trendingController,
                      onPressed: context.read<AnimeCubit>().navigateToAnimeDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.recentlyCompleted.$1
                  ? CardRowFrame.browse(
                    child: AnimeCardList(
                      listTitle: context.tr('common_recently_completed_animes'),
                      animeList: state.recentlyCompleted.$2,
                      controller: recentlyCompletedController,
                      onPressed: context.read<AnimeCubit>().navigateToAnimeDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.popular.$1
                  ? CardRowFrame.browse(
                    child: AnimeCardList(
                      listTitle: context.tr('common_popular_animes'),
                      animeList: state.popular.$2,
                      controller: popularController,
                      onPressed: context.read<AnimeCubit>().navigateToAnimeDetails,
                      loadMore: false,
                    ),
                  )
                  : const CardRowFrame.browse(child: CardRowSkeleton()),
              const SizedBox(height: 30),
              state.upcoming.$1
                  ? CardRowFrame.browse(
                    child: AnimeCardList(
                      listTitle: context.tr('common_upcoming_animes'),
                      animeList: state.upcoming.$2,
                      controller: upcomingController,
                      onPressed: context.read<AnimeCubit>().navigateToAnimeDetails,
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

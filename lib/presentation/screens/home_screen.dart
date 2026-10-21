// Flutter dependencies
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/home_cubit.dart';
import 'package:unyo/application/states/home_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/views/loading_view.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/text/texts.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeCubit>(),
      child: const _HomeListener(),
    );
  }
}

class _HomeListener extends StatelessWidget {
  const _HomeListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<HomeCubit>().clearEffects,
          );
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder:
            (context, state) => state.isLoading ? const LoadingView() : const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController continueWatchingController = ScrollController();
  final ScrollController continueReadingController = ScrollController();

  @override
  void dispose() {
    continueWatchingController.dispose();
    continueReadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 15.0.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 25.0.h),
                SizedBox(
                  width: 1.sw - 140,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const TextDisplaySmall(text: "Welcome back "),
                          TextDisplaySmall(
                            text: state.loggedUser.name,
                            style: TextStyle(
                              color: ColorScheme.of(context).tertiary,
                            ),
                          ),
                          const TextDisplaySmall(text: " , enjoy your journey!"),
                          const Spacer(),
                        ],
                      ),
                      const Row(
                        children: [
                          TextBodyLarge(
                            text: "Find your next favorite anime or manga!",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MediaButton(
                        onPressed:
                            () => context
                                .read<HomeCubit>()
                                .navigateToUserAnimeList(context),
                        image: state.mediaCoverImages.isNotEmpty ? state.mediaCoverImages[0] : "",
                        text: "Anime List",
                      ),
                      SizedBox(width: 50.w),
                      MediaButton(
                        onPressed:
                            () => context
                                .read<HomeCubit>()
                                .navigateToUserMangaList(context),
                        image:
                            state.mediaCoverImages.isNotEmpty ? state.mediaCoverImages[1] : "",
                        text: "Manga List",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                AnimeCardList(
                  listTitle: "Continue Watching",
                  animeList: state.continueWatching,
                  controller: continueWatchingController,
                  onPressed: context.read<HomeCubit>().navigateToAnimeDetails,
                  loadMore: false,
                ),
                const SizedBox(height: 30),
                MangaCardList(
                  listTitle: "Continue Reading",
                  mangaList: state.continueReading,
                  controller: continueReadingController,
                  loadMore: false,
                  onPressed: context.read<HomeCubit>().navigateToMangaDetails,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

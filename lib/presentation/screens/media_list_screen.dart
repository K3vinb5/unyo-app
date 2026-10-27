import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/cubits/media_list_cubit.dart';
import 'package:unyo/application/states/media_list_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/text/texts.dart';

@RoutePage()
class MediaListScreen extends StatelessWidget {
  final String? type;

  const MediaListScreen(@QueryParam('type') this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<MediaListCubit>(), child: _MediaListListener(type: MediaTypeFactory.fromString(type!)));
  }
}

class _MediaListListener extends StatelessWidget {
  final MediaType type;

  const _MediaListListener({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaListCubit, MediaListState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(context, state.effects, context.read<MediaListCubit>().clearEffects);
        }
      },
      child: SkeletonScope(child: _MediaListView(type: type)),
    );
  }
}

class _MediaListView extends StatefulWidget {
  final MediaType type;

  const _MediaListView({required this.type});

  @override
  State<_MediaListView> createState() => _MediaListViewState();
}

class _MediaListViewState extends State<_MediaListView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaListCubit, MediaListState>(
      builder: (context, state) {
        final TabController tabController = TabController(
          length: widget.type == MediaType.anime ? state.userAnimeLists.length : state.userMangaLists.length,
          vsync: this,
        );
        return Column(
          children: [
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () => context.read<MediaListCubit>().popScreen(context),
                    icon: Icon(key: const ValueKey('back-button'), Icons.arrow_back_ios_new_rounded, color: ColorScheme.of(context).tertiary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const TextHeadlineMedium(text: "Hi ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextHeadlineMedium(
                            text: "${state.loggedUser.name}! ",
                            style: TextStyle(color: ColorScheme.of(context).tertiary, fontWeight: FontWeight.bold),
                          ),
                          TextHeadlineMedium(
                            text: "Welcome to your ${widget.type == MediaType.anime ? "Anime" : "Manga"} Lists!",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextBodyLarge(
                            text: "You can find and remember your favorite ${widget.type == MediaType.anime ? "anime" : "manga"} here",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TabBar(
                labelColor: Colors.white,
                dividerColor: ColorScheme.of(context).secondary.withValues(alpha: 0.5),
                indicatorColor: ColorScheme.of(context).primary,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                controller: tabController,
                tabs: [
                  ...(widget.type == MediaType.anime ? state.userAnimeLists : state.userMangaLists).entries.map((entry) {
                    String title = entry.key;
                    return Tooltip(
                      waitDuration: const Duration(milliseconds: 1000),
                      message: "$title (${entry.value.length})",
                      child: SizedBox(width: 150, child: Tab(text: "$title (${entry.value.length})")),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 1.sh - 135,
              child: Padding(
                padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 15.0.h),
                child: state.isLoading
                    ? const MediaGridSkeleton()
                    : TabBarView(
                  controller: tabController,
                  children: [
                    ...(widget.type == MediaType.anime ? state.userAnimeLists : state.userMangaLists).entries.map((entry) {
                      List<Anime>? animeList = widget.type == MediaType.anime ? entry.value as List<Anime> : null;
                      List<Manga>? mangaList = widget.type == MediaType.manga ? entry.value as List<Manga> : null;
                      return GridView.builder(
                        scrollDirection: Axis.vertical,
                        gridDelegate: mediaGridDelegate,
                        itemCount: animeList != null ? animeList.length : mangaList!.length,
                        itemBuilder:
                            (context, index) => SizedBox(
                              width: 165,
                              child: MediaCard(
                                title: animeList != null ? animeList[index].title.userPreferred : mangaList![index].title.userPreferred,
                                score: animeList != null ? animeList[index].averageScore : mangaList![index].averageScore,
                                coverImage: animeList != null ? animeList[index].coverImage : mangaList![index].coverImage,
                                onPressed:
                                    () => context.read<MediaListCubit>().navigateToMediaDetails(
                                      animeList != null ? animeList[index] : mangaList![index],
                                      MediaListModel(name: "MediaList", mediaType: animeList != null ? MediaType.anime : MediaType.manga),
                                    ),
                                status: animeList != null ? animeList[index].status : mangaList![index].status,
                                year: animeList != null ? animeList[index].startDate : mangaList![index].startDate,
                                format: animeList != null ? animeList[index].format : mangaList![index].format,
                                tag: "MediaList-${animeList != null ? animeList[index].id : mangaList![index].id}",
                              ),
                            ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

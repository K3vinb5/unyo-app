// External dependencies
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/calendar_cubit.dart';
import 'package:unyo/application/states/calendar_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/text/texts.dart';

@RoutePage()
class CalendarScreen extends StatelessWidget {

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<CalendarCubit>(),
        child: const _CalendarListener()
    );
  }
}

class _CalendarListener extends StatelessWidget {

  const _CalendarListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarCubit, CalendarState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context
                .read<CalendarCubit>()
                .clearEffects,
          );
        }
      },
      child: const SkeletonScope(child: _CalendarView()),
    );
  }
}

class _CalendarView extends StatefulWidget {

  const _CalendarView();

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView>
    with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final TabController tabController = TabController(
          length: state.animeCalendarReleases.length,
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
                    onPressed: () => context.read<CalendarCubit>().popScreen(context),
                    icon: Icon(
                      key: const ValueKey('back-button'),
                      Icons.arrow_back_ios_new_rounded,
                      color: ColorScheme.of(context).tertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextHeadlineMedium(
                            text: "Anime",
                            style: TextStyle(
                              color: ColorScheme.of(context).tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextHeadlineMedium(
                            text:
                            " Calendar",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextBodyLarge(
                            text:
                            "You can find the next anime releases here!",
                            style: TextStyle(color: Colors.grey),
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
              child: SizedBox(
                child: TabBar(
                  labelColor: Colors.white,
                  dividerColor: ColorScheme.of(
                    context,
                  ).secondary.withValues(alpha: 0.5),
                  indicatorColor: ColorScheme.of(context).primary,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  controller: tabController,
                  tabs: [
                    ...state.animeCalendarReleases
                        .entries
                        .map((entry) {
                      String title = entry.key;
                      return Tooltip(
                        waitDuration: const Duration(milliseconds: 1000),
                        message: "$title (${entry.value.length})",
                        child: SizedBox(
                          width: 170,
                          child: Tab(text: "$title (${entry.value.length})"),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 1.sh - 135,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 15.0.w,
                  right: 15.0.w,
                  top: 15.0.h,
                ),
                child: state.isLoading
                    ? const MediaGridSkeleton()
                    : TabBarView(
                  controller: tabController,
                  children: [
                    ...state.animeCalendarReleases
                        .entries
                        .map((entry) {
                      return GridView.builder(
                        scrollDirection: Axis.vertical,
                        gridDelegate: mediaGridDelegate,
                        itemCount:
                        entry.value.length,
                        itemBuilder:
                            (context, index) => SizedBox(
                          width: 165,
                          child: MediaCard(
                            title:
                           entry.value[index]
                                .title
                                .userPreferred,
                            score:
                            entry.value[index].averageScore,
                            coverImage:
                            entry.value[index].coverImage,
                            onPressed: () => context.read<CalendarCubit>().navigateToAnimeDetails(entry.value[index], const MediaListModel(name: "Calendar", mediaType: MediaType.anime)),
                            status:
                            entry.value[index].status,
                            year:
                            entry.value[index].startDate,
                            format:
                            entry.value[index].format,
                            tag:
                            "Calendar-${entry.value[index].id}",
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
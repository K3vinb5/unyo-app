import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/cubits/anime_advanced_search_cubit.dart';
import 'package:unyo/application/states/anime_advanced_search_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_multi_select_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_sort_widget.dart';
import 'package:unyo/presentation/widgets/styled/unyo_textfield.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';

@RoutePage()
class AnimeAdvancedSearchScreen extends StatelessWidget {
  const AnimeAdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnimeAdvancedSearchCubit>(),
      child: const _AnimeAdvancedSearchListener(),
    );
  }
}

class _AnimeAdvancedSearchListener extends StatelessWidget {
  const _AnimeAdvancedSearchListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<AnimeAdvancedSearchCubit>().clearEffects,
          );
        }
      },
      child: const _AnimeAdvancedSearchView(),
    );
  }
}

class _AnimeAdvancedSearchView extends StatefulWidget {
  const _AnimeAdvancedSearchView();

  @override
  State<_AnimeAdvancedSearchView> createState() => _AnimeAdvancedSearchViewState();
}

class _AnimeAdvancedSearchViewState extends State<_AnimeAdvancedSearchView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      builder: (context, state) {
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
                    onPressed: () => context.read<AnimeAdvancedSearchCubit>().popScreen(context),
                    icon: Icon(key: const ValueKey('back-button'), Icons.arrow_back_ios_new_rounded, color: ColorScheme.of(context).tertiary),
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
                            text: " Advanced Search",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextBodyLarge(
                            text: "Refine your anime search with advanced filters",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  UnyoTextfield(
                    width: 180.w,
                    label: "Search",
                    debounceMilliseconds: 1000,
                    onChange: context.read<AnimeAdvancedSearchCubit>().updateSearchQuery,
                  ),
                  state.genresFilters.$1
                      ? SizedBox(
                        width: 190.w,
                        child: UnyoMultiSelectDropdown(
                          label: "Genres",
                          debounceMilliseconds: 1000,
                          icon: Icons.category_rounded,
                          children: state.genresFilters.$2,
                          selectedValues: state.selectedGenres,
                          onChanged: context.read<AnimeAdvancedSearchCubit>().updateGenres,
                        ),
                      )
                      : const SizedBox.shrink(),
                  state.yearFilters.$1
                      ? SizedBox(
                        width: 190.w,
                        child: UnyoDropdown(
                          label: "Year",
                          icon: Icons.calendar_today_rounded,
                          children: state.yearFilters.$2,
                          selectedValue: state.selectedYear,
                          reactOnCancel: true,
                          onPressed: context.read<AnimeAdvancedSearchCubit>().updateSelectedYear,
                        ),
                      )
                      : const SizedBox.shrink(),
                  state.seasonFilters.$1
                      ? SizedBox(
                        width: 190.w,
                        child: UnyoDropdown(
                          label: "Season",
                          icon: Icons.wb_sunny_rounded,
                          children: state.seasonFilters.$2,
                          selectedValue: state.selectedSeason,
                          reactOnCancel: true,
                          onPressed: context.read<AnimeAdvancedSearchCubit>().updateSelectedSeason,
                        ),
                      )
                      : const SizedBox.shrink(),
                  state.formatFilters.$1
                      ? SizedBox(
                        width: 190.w,
                        child: UnyoDropdown(
                          label: "Format",
                          icon: Icons.video_library_rounded,
                          children: state.formatFilters.$2,
                          selectedValue: state.selectedFormat,
                          reactOnCancel: true,
                          onPressed: context.read<AnimeAdvancedSearchCubit>().updateSelectedFormat,
                        ),
                      )
                      : const SizedBox.shrink(),
                  state.airingStatusFilters.$1
                      ? SizedBox(
                        width: 190.w,
                        child: UnyoDropdown(
                          label: "Airing Status",
                          icon: Icons.signal_cellular_alt_rounded,
                          children: state.airingStatusFilters.$2,
                          selectedValue: state.selectedAiringStatus,
                          reactOnCancel: true,
                          onPressed: context.read<AnimeAdvancedSearchCubit>().updateSelectedAiringStatus,
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            (state.searchSortOptions.$1 && state.searchSortOrder.$1) ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if(state.searchSortOptions.$1) UnyoSortWidget(sortingOptions: state.searchSortOptions.$2, initialSelection: state.selectedSearchSortOption, onSortChanged: context.read<AnimeAdvancedSearchCubit>().updateSearchSortOption,),
                const SizedBox(width: 10,),
                if(state.searchSortOrder.$1) UnyoSortWidget(sortingOptions: state.searchSortOrder.$2, initialSelection: state.selectedSearchOrder, onSortChanged: context.read<AnimeAdvancedSearchCubit>().updateSearchSortOrder,),
                SizedBox(width: 40.w,),
              ],
            ) : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 165,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: state.searchResults.length,
                  itemBuilder:
                      (context, index) => SizedBox(
                        width: 165,
                        child: MediaCard(
                          title: state.searchResults[index].title.userPreferred,
                          score: state.searchResults[index].averageScore,
                          coverImage: state.searchResults[index].coverImage,
                          onPressed:
                              () => context.read<AnimeAdvancedSearchCubit>().navigateToAnimeDetails(
                                context,
                                state.searchResults[index],
                                const MediaListModel(name: "AnimeAdvancedSearch", mediaType: MediaType.anime),
                              ),
                          status: state.searchResults[index].status,
                          year: state.searchResults[index].startDate,
                          format: state.searchResults[index].format,
                          tag: "AnimeAdvancedSearch-${state.searchResults[index].id}",
                        ),
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
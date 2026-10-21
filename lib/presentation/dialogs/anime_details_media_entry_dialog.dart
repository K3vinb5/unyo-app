import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_slider.dart';

class AnimeDetailsMediaEntryDialog extends StatelessWidget {
  final AnimeDetailsCubit cubit;

  const AnimeDetailsMediaEntryDialog({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
        builder:
            (context, state) => Dialog(
              backgroundColor: const Color.fromARGB(255, 30, 30, 30),
              child: SizedBox(
                width: 906.w,
                height: 540.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0.w, vertical: 36.0.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "List Editor",
                                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.delete),
                                style: const ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(12.0, 12.0))),
                              ),
                            ],
                          ),
                          SizedBox(height: 25.0.h),
                          UnyoDropdown(
                            children: const [
                              "Current",
                              "Planning",
                              "Completed",
                              "Repeating",
                              "Paused",
                              "Dropped",
                            ],
                            label: "Status",
                            onPressed: context.read<AnimeDetailsCubit>().updateMediaListEntryStatus,
                            selectedValue: state.newMediaListEntry.status,
                          ),
                          SizedBox(height: 25.0.h),
                        UnyoSlider(
                            minValue: 0,
                            initialValue: state.newMediaListEntry.progress != -1 ? state.newMediaListEntry.progress : 0,
                            title: "Progress",
                            maxValue: state.selectedAnime.episodes,
                            onChanged:
                                (value) =>
                                context.read<AnimeDetailsCubit>().updateMediaListEntryProgress(value.toInt()),
                          ),
                          SizedBox(height: 25.0.h),
                          UnyoSlider(
                            minValue: 0,
                            initialValue:
                            state.newMediaListEntry.score.toInt() != -1 ? state.newMediaListEntry.score.toInt() : 0,
                            title: "Score",
                            maxValue: 10,
                            onChanged: context.read<AnimeDetailsCubit>().updateMediaListEntryScore,
                          ),
                          SizedBox(height: 25.0.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Started At:",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text("${state.newMediaListEntry.startedAt[0]}/${state.newMediaListEntry.startedAt[1]}/${state.newMediaListEntry.startedAt[2]}"),
                                  const SizedBox(width: 5.0),
                                  IconButton(
                                    onPressed:
                                        () => context.read<AnimeDetailsCubit>().updateMediaListEntryStartedAt(
                                      context,
                                    ),
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                              SizedBox(width: 25.0.w),
                              Row(
                                children: [
                                  const Text(
                                    "Completed At:",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text("${state.newMediaListEntry.completedAt[0]}/${state.newMediaListEntry.completedAt[1]}/${state.newMediaListEntry.completedAt[2]}"),
                                  const SizedBox(width: 5.0),
                                  IconButton(
                                    onPressed:
                                        () => context.read<AnimeDetailsCubit>().updateMediaListEntryCompletedAt(
                                      context,
                                    ),
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                              SizedBox(width: 25.0.w),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DarkUnyoButton(text: "Cancel", maxHeight: 50, onPressed: () => context.read<AnimeDetailsCubit>().popRouteEffect(context)),
                              SizedBox(width: 25.0.w),
                              LightUnyoButton(text: "Confirm", maxHeight: 50, onPressed: () => context.read<AnimeDetailsCubit>().updateMediaListEntry(context)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

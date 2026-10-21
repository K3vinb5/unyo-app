// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Internal dependencies
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/application/states/video_state.dart';
import 'package:unyo/core/services/video/video_service.dart';

class UnyoVideoHeaderControls extends StatelessWidget {
  final VideoCubit cubit;
  final VideoService videoService;

  const UnyoVideoHeaderControls({super.key, required this.cubit, required this.videoService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<VideoCubit, VideoState>(
          builder: (context, state) =>
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              context.read<VideoCubit>().navigateBackToAnimeDetailsPage(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: ColorScheme
                                .of(context)
                                .tertiary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${state.selectedAnime.title.userPreferred}  -  Episode ${state.videoInfo
                              .playlistIndex + 1}",
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

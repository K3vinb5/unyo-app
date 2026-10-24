// External dependencies
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/presentation/views/loading_view.dart';
import 'package:unyo/presentation/widgets/styled/unyo_server_button.dart';

class AnimeServerSelectionDrawer extends StatefulWidget {
  final AnimeDetailsCubit cubit;
  final int episodeIndex;
  final Future<bool> Function() onOpen;

  const AnimeServerSelectionDrawer({
    super.key,
    required this.cubit,
    required this.episodeIndex,
    required this.onOpen,
  });

  @override
  State<AnimeServerSelectionDrawer> createState() => _AnimeServerSelectionDrawerState();
}

class _AnimeServerSelectionDrawerState extends State<AnimeServerSelectionDrawer> {
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    bool remainOpen = false;
    try {
      remainOpen = await widget.onOpen();
    } catch (e, stackTrace) {
      // Never let a drawer open failure surface as an unhandled async error.
      widget.cubit.logger.e("Failed to open the server selection drawer: $e", stackTrace: stackTrace);
    }
    if (!remainOpen && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
        builder: (context, state) => Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: 600.w,
                height: 500.h,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  color: ColorScheme.of(context).secondary.withValues(alpha: 0.7),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0.w, vertical: 20.0.h),
                  child: state.animeServerDialogReady
                      ? Column(
                          children: [
                            const Text(
                              "Select Server",
                              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 25.0.h),
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                                children: [
                                  ...state.extensionVideoResults.mapIndexed(
                                    (int videoIndex, ext.Video video) => Column(
                                      children: [
                                        UnyoServerButton(
                                          videoServer: video,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            context.read<AnimeDetailsCubit>().navigateToVideoPlayer(
                                              video,
                                              widget.episodeIndex,
                                              videoIndex,
                                            );
                                          },
                                        ),
                                        SizedBox(height: 25.0.h),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : LoadingView(width: 85.w, description: "Please wait, this can take some seconds..."),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

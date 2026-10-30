// External dependencies

import 'package:auto_route/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/application/states/video_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_scope.dart';
import 'package:unyo/presentation/views/loading_view.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_controls.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_shortcut_feedback.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_texture.dart';

@RoutePage()
class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<VideoCubit>(), child: const _VideoListener());
  }
}

class _VideoListener extends StatelessWidget {
  const _VideoListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCubit, VideoState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<VideoCubit>().clearEffects,
          );
        }
      },
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) => state.isLoading ? const _VideoLoadingView() : const _VideoView(),
      ),
    );
  }
}

class _VideoLoadingView extends StatelessWidget {
  const _VideoLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.black,
      child: LoadingView(description: "The video is loading"),
    );
  }
}

class _VideoView extends StatefulWidget {
  const _VideoView();

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  late VideoService _videoService;
  late VideoShortcutHandler _shortcutHandler;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<VideoCubit>();
    _videoService = cubit.videoService;
    // Keys go through the same command surface as the on-screen buttons:
    // VideoService for playback, VideoCubit for episode navigation.
    _shortcutHandler = VideoShortcutHandler(
      commands: _videoService,
      onNextEpisode: () => cubit.skipToNextEpisode(),
      onPreviousEpisode: () => cubit.skipToPreviousEpisode(),
    );
  }

  @override
  void dispose() {
    _shortcutHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoShortcutScope(
      handler: _shortcutHandler,
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            UnyoVideoTexture(videoService: _videoService),
            // Controls
            UnyoVideoControls(videoCubit: context.read<VideoCubit>(), videoService: _videoService),
            // Transient shortcut indicators (volume / speed / seek)
            UnyoVideoShortcutFeedback(feedback: _shortcutHandler.feedback),
          ],
        ),
      ),
    );
  }
}

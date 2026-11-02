// External dependencies
import 'dart:async';
import 'package:cast/cast.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/application/states/video_state.dart';

// Internal dependencies
import 'package:unyo/core/enums/video_display_mode.dart';
import 'package:unyo/core/services/video/up_next_window.dart';
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/domain/entities/extension/track.dart' as ext;
import 'package:unyo/presentation/drawers/episode_list_drawer.dart';
import 'package:unyo/presentation/video/video_player_interaction.dart';
import 'package:unyo/presentation/widgets/styled/unyo_fade_overlay.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_bottom_status.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_header_controls.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_list_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_volume_button.dart';
import 'package:unyo/presentation/widgets/text/media_title_text.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoVideoControls extends StatefulWidget {
  final VideoCubit videoCubit;
  final VideoService videoService;

  /// The shared player-interaction path (visibility + hide timer + commands).
  /// Both this widget and the keyboard shortcut handler drive it.
  final VideoPlayerInteraction interaction;

  const UnyoVideoControls({
    super.key,
    required this.videoCubit,
    required this.videoService,
    required this.interaction,
  });

  /// Audio entries. With at most one source there is nothing to choose, so the
  /// menu offers a single "Default audio" entry (index -1) instead of an empty
  /// list; index 0 is the default track in that case, so both count as checked.
  @visibleForTesting
  static List<PopupMenuEntry<int>> buildAudioMenuItems({
    required List<ext.Track> audios,
    required int activeIndex,
  }) {
    if (audios.length <= 1) {
      return <PopupMenuEntry<int>>[
        PopupMenuItem<int>(value: -1, child: _menuRow('Default audio', activeIndex <= 0)),
      ];
    }
    return audios
        .mapIndexed(
          (index, audio) => PopupMenuItem<int>(
            value: index,
            // When no explicit override is set, the default track (the first
            // one, which is what "Default audio" selects) is the active entry.
            child: _menuRow(_trackLabel(audio), activeIndex == index || (activeIndex < 0 && index == 0)),
          ),
        )
        .toList();
  }

  /// Subtitle entries. "No subtitles" (index -1) is always first so the menu is
  /// never an empty popup, and it is the entry that is checked when subtitles
  /// are off.
  @visibleForTesting
  static List<PopupMenuEntry<int>> buildSubtitleMenuItems({
    required List<ext.Track> subtitles,
    required int activeIndex,
  }) {
    return <PopupMenuEntry<int>>[
      PopupMenuItem<int>(value: -1, child: _menuRow('No subtitles', activeIndex < 0)),
      ...subtitles.mapIndexed(
        (index, subtitle) => PopupMenuItem<int>(
          value: index,
          child: _menuRow(_trackLabel(subtitle), activeIndex == index),
        ),
      ),
    ];
  }

  /// Icon per display mode — three distinct glyphs, and the icon always shows
  /// the CURRENT mode, never the next one (WP #114).
  static IconData videoDisplayModeIcon(VideoDisplayMode mode) => switch (mode) {
        VideoDisplayMode.fit => Icons.fit_screen_rounded,
        VideoDisplayMode.crop => Icons.crop_rounded,
        VideoDisplayMode.stretch => Icons.aspect_ratio_rounded,
      };

  static String videoDisplayModeLabel(VideoDisplayMode mode) => switch (mode) {
        VideoDisplayMode.fit => 'Fit',
        VideoDisplayMode.crop => 'Crop',
        VideoDisplayMode.stretch => 'Stretch',
      };

  /// Names the current mode and the one a click switches to.
  static String videoDisplayModeTooltip(VideoDisplayMode mode) =>
      '${videoDisplayModeLabel(mode)} — click for ${videoDisplayModeLabel(nextVideoDisplayMode(mode))}';

  static String _trackLabel(ext.Track track) =>
      '${track.lang}${track.embedded ? ' - Embedded' : ''}';

  /// Same layout as the video server menu: label on the left, check on the right.
  static Widget _menuRow(String label, bool checked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, maxLines: 3, softWrap: true, overflow: TextOverflow.ellipsis),
        ),
        checked
            ? const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(Icons.check_rounded, size: 16),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  State<UnyoVideoControls> createState() => _UnyoVideoControlsState();
}

class _UnyoVideoControlsState extends State<UnyoVideoControls> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _refreshTimer;
  late VideoService _videoService;

  bool _isDragging = false;
  double _dragValue = 0.0;

  /// Height of the bottom band (status slot + slider + control row) and of the
  /// status slot itself. The status slot is an overlay *outside* the controls
  /// fade now, so those two numbers reproduce the position the old in-Column
  /// pill had (WP #113).
  static const double _bottomBandHeight = 150;
  static const double _statusSlotHeight = 45;

  /// The three large centre controls (back 30, play/pause, forward 30) size
  /// their button and their glyph identically.
  double get _centreIconSize => 80.w.clamp(80, 100);

  /// The shared interaction path. Visibility, the 4 s auto-hide timer and the
  /// player command all live there, so a keyboard shortcut and a click on this
  /// bar produce the exact same result (WP #116). This widget only listens.
  VideoPlayerInteraction get _interaction => widget.interaction;

  /// The pause glyph's progress: 1 = pause bars, 0 = play triangle. It is
  /// retargeted only from [_onPlaybackChanged], i.e. from the player's own
  /// state change — never from the method that raised it — so every trigger
  /// path (mouse, keyboard, MPRIS/audio_service, end of media) animates.
  bool get _isPlaying => _interaction.isPlaying;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Adjust the duration as needed
    );
    // No morph on mount: the glyph starts on the state the player is in.
    _controller.value = _isPlaying ? 1.0 : 0.0;
    _videoService = widget.videoService;
    _refreshTimer = _progressTimer();
    _interaction.addListener(_onInteractionChanged);
    _interaction.playing.addListener(_onPlaybackChanged);
  }

  void _onInteractionChanged() {
    if (mounted) setState(() {});
  }

  /// The one reaction to a playback-state change, whatever caused it.
  void _onPlaybackChanged() {
    _controller.animateTo(_interaction.playing.value ? 1.0 : 0.0);
    _restartProgressTimer();
    if (mounted) setState(() {});
  }

  /// Repaints the position/duration labels and the drag state. Deliberately not
  /// part of the visibility path: the fade is driven by the interaction's own
  /// listener, so this 100 ms tick can never delay it (WP #116).
  Timer _progressTimer() => Timer.periodic(const Duration(milliseconds: 100), (_) {
    if (mounted && _videoService.isPlaying) {
      setState(() {});
    }
  });

  /// Tick rate follows playback: 100 ms while the position advances, 1 s while
  /// paused (nothing to repaint, no reason to burn frames).
  void _restartProgressTimer() {
    _refreshTimer.cancel();
    _refreshTimer = _isPlaying
        ? _progressTimer()
        : Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted && _videoService.isPlaying) {
              setState(() {});
            }
          });
  }

  void playVideo() {
    if (_isPlaying) return;
    _interaction.play();
  }

  void togglePlayPause() => _interaction.togglePlay();

  @override
  void dispose() {
    _interaction.removeListener(_onInteractionChanged);
    _interaction.playing.removeListener(_onPlaybackChanged);
    _refreshTimer.cancel();
    super.dispose();
  }

  /// The status slot above the seek bar. Precedence and content rules live in
  /// [UnyoVideoBottomStatus] / [shouldShowUpNextCard]; this only collects the
  /// data the current state actually has.
  Widget _buildBottomStatus(BuildContext context, VideoState state) {
    final VideoCubit cubit = widget.videoCubit;
    final int playlistIndex = state.videoInfo.playlistIndex;
    final int nextIndex = playlistIndex + 1;
    final bool upNextVisible = shouldShowUpNextCard(
      position: _videoService.position,
      duration: _videoService.duration,
      playlistIndex: playlistIndex,
      episodeCount: state.extensionEpisodeResults.length,
      dismissedPlaylistIndex: state.upNextDismissedPlaylistIndex,
    );
    return UnyoVideoBottomStatus(
      controlsVisible: _interaction.controlsVisible,
      skipKind: cubit.activeSkipWindowKind,
      skipLabel: cubit.getSkipTimeText(),
      upNextVisible: upNextVisible,
      seriesTitle: displayMediaTitle(state.selectedAnime.title),
      episodeLabel: _nextEpisodeLabel(state, nextIndex),
      thumbnailUrl: _nextEpisodeThumbnail(state, nextIndex),
      onSkip: () => cubit.performSkipActin(),
      onWatchNow: () => cubit.navigateToEpisode(nextIndex),
      onDismiss: cubit.dismissUpNextCard,
    );
  }

  /// `"<episode title> (E<M>)"` from whatever is known: AniZip metadata when it
  /// loaded, the extension's episode number otherwise. No season source exists
  /// yet, so the label omits `S<N>` instead of inventing one.
  String _nextEpisodeLabel(VideoState state, int nextIndex) {
    final bool hasEpisodeInfo = nextIndex >= 0 && state.episodesInfo.length > nextIndex;
    return upNextEpisodeLabel(
      episodeTitle: hasEpisodeInfo ? state.episodesInfo[nextIndex].title.userPreferred : null,
      episodeNumber: _nextEpisodeNumber(state, nextIndex),
    );
  }

  int? _nextEpisodeNumber(VideoState state, int nextIndex) {
    if (nextIndex < 0) return null;
    if (state.episodesInfo.length > nextIndex && state.episodesInfo[nextIndex].episodeNumber > 0) {
      return state.episodesInfo[nextIndex].episodeNumber;
    }
    if (state.extensionEpisodeResults.length > nextIndex) {
      final int number = state.extensionEpisodeResults[nextIndex].getEpisode_number().toInt();
      if (number > 0) return number;
    }
    return nextIndex + 1;
  }

  /// Empty when there is no thumbnail data — the card then renders without an
  /// image instead of a broken box.
  String _nextEpisodeThumbnail(VideoState state, int nextIndex) {
    if (nextIndex < 0 || state.episodesInfo.length <= nextIndex) return '';
    return state.episodesInfo[nextIndex].image;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.videoCubit,
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          return !_videoService.isBuffering
              ? ListenableBuilder(
                  listenable: _interaction,
                  builder: (context, _) => MouseRegion(
                    onHover: (event) => _interaction.reveal(),
                    cursor: _interaction.controlsVisible ? SystemMouseCursors.basic : SystemMouseCursors.none,
                    child: Stack(
                      children: [
                        // Screen Gestures — a click on the picture pauses and
                        // reveals the bar while playing, and does nothing at
                        // all while paused (resuming is the centre glyph's or
                        // the play button's job, WP #119).
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _interaction.handleSurfaceTap,
                          ),
                        ),
                        // Everything that fades with the bar. Hit testing is
                        // disabled while hidden, so an invisible button can never
                        // swallow a click meant for the video surface.
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: VideoPlayerInteraction.fadeDuration,
                            opacity: _interaction.controlsVisible ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: !_interaction.controlsVisible,
                              child: Stack(
                                children: [
                                  // Top and Bottom Fade Overlays
                                  const UnyoFadeOverlay(isTop: true),
                                  const UnyoFadeOverlay(isTop: false),
                                  // Video Header Controls
                                  UnyoVideoHeaderControls(cubit: widget.videoCubit, videoService: _videoService),
                                  // Video Controls Overlay
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: _isPlaying ? 0 : 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: IgnorePointer(
                                        ignoring: _isPlaying,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _interaction.act(
                                                  () => _videoService.reverse(const Duration(seconds: 30)),
                                                );
                                                setState(() {});
                                              },
                                              iconSize: _centreIconSize,
                                              icon: Tooltip(
                                                waitDuration: const Duration(milliseconds: 2000),
                                                textAlign: TextAlign.center,
                                                message: "Reverse 30s",
                                                child: Icon(Icons.fast_rewind_rounded, color: Colors.white, size: _centreIconSize),
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Material(
                                              color: Colors.transparent,
                                              child: Tooltip(
                                                waitDuration: const Duration(milliseconds: 2000),
                                                textAlign: TextAlign.center,
                                                message: "Resume Play",
                                                child: UnyoInkWell(
                                                  onTap: () => playVideo(),
                                                  hoverColor: Colors.white10,
                                                  splashColor: Colors.white12,
                                                  borderRadius: BorderRadius.circular(60.w),
                                                  child: AnimatedIcon(
                                                    icon: AnimatedIcons.play_pause,
                                                    size: 85.w.clamp(85, 110),
                                                    color: Colors.white,
                                                    progress: _controller,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Tooltip(
                                              waitDuration: const Duration(milliseconds: 2000),
                                              textAlign: TextAlign.center,
                                              message: "Forward 30s",
                                              child: IconButton(
                                                iconSize: _centreIconSize,
                                                onPressed: () {
                                                  _interaction.act(
                                                    () => _videoService.forward(const Duration(seconds: 30)),
                                                  );
                                                  setState(() {});
                                                },
                                                icon: Icon(Icons.fast_forward_rounded, color: Colors.white, size: _centreIconSize),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Side Video List
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: UnyoVideoListButton(
                                      tooltip: "Open Episode List",
                                      onPressed: () {
                                        _interaction.hide();
                                        context.read<VideoCubit>().showDrawerDialogEffect(
                                            drawerDialog:EpisodeListDrawer(cubit: widget.videoCubit),
                                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                                            startPosition: AxisDirection.right
                                        );
                                      },
                                    ),
                                  ),
                                  // Video Slider And Controls
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      height: _bottomBandHeight,
                                      child: Column(
                                        children: [
                                          // The status slot (skip pill / up-next
                                          // card) is an overlay outside this
                                          // fade; the Column only keeps its
                                          // space so nothing shifts.
                                          const SizedBox(height: _statusSlotHeight),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              SizedBox(width: 20.w),
                                              SizedBox(
                                                width: 75,
                                                child: Text(
                                                  _isDragging
                                                      ? Duration(milliseconds: _dragValue.toInt()).toString().substring(0, 7)
                                                      : _videoService.position.toString().substring(0, 7),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: Slider(
                                                    min: 0,
                                                    max: _videoService.duration.inMilliseconds.toDouble(),
                                                    value: _isDragging
                                                        ? _dragValue
                                                        : _videoService.position.inMilliseconds.toDouble(),
                                                    label: _isDragging
                                                        ? TextUtils.formatMilliseconds(_dragValue.toInt())
                                                        : _videoService.formattedPosition,
                                                    divisions: _videoService.duration.inMilliseconds.toDouble() > 0
                                                        ? _videoService.duration.inMilliseconds
                                                        : null,
                                                    onChanged: (value) {
                                                      // Dragging is a hold: the bar
                                                      // stays up, the countdown is
                                                      // stopped until the drag ends.
                                                      _interaction.hold();
                                                      _isDragging = true;
                                                      _dragValue = value;
                                                      setState(() {});
                                                    },
                                                    onChangeEnd: (value) {
                                                      _isDragging = false;
                                                      _interaction.seekTo(Duration(milliseconds: value.toInt()));
                                                      _interaction.release();
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 75,
                                                child: Text(
                                                  _videoService.duration.toString().substring(0, 7),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15.w),
                                            ],
                                          ),
                                          // Video Controls
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Left Aligned
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(width: 10.w),
                                                  Tooltip(
                                                    message: "${_isPlaying ? "Pause" : "Play"} Video",
                                                    child: IconButton(
                                                      onPressed: () => togglePlayPause(),
                                                      icon: Icon(
                                                        size: 27,
                                                        _isPlaying
                                                            ? Icons.pause_rounded
                                                            : Icons.play_arrow_rounded,
                                                      ),
                                                    ),
                                                  ),
                                                  UnyoVolumeButton(videoService: _videoService),
                                                ],
                                              ),
                                              // Right Aligned
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  PopupMenuButton<int>(
                                                    tooltip: "Select Audio Track",
                                                    icon: const Icon(Icons.audiotrack_rounded, size: 27),
                                                    onSelected: (int index) {
                                                      _videoService.setAudioTrack(index);
                                                      _interaction.reveal();
                                                      setState(() {});
                                                    },
                                                    itemBuilder: (BuildContext context) => UnyoVideoControls.buildAudioMenuItems(
                                                      audios: _videoService.audios,
                                                      activeIndex: _videoService.audioIndex,
                                                    ),
                                                  ),
                                                  PopupMenuButton<int>(
                                                    tooltip: "Select Subtitle Track",
                                                    icon: const Icon(Icons.subtitles_rounded, size: 27),
                                                    onSelected: (int index) {
                                                      _videoService.setSubtitle(index);
                                                      _interaction.reveal();
                                                      setState(() {});
                                                    },
                                                    itemBuilder: (BuildContext context) => UnyoVideoControls.buildSubtitleMenuItems(
                                                      subtitles: _videoService.subtitles,
                                                      activeIndex: _videoService.subtitleIndex,
                                                    ),
                                                  ),
                                                  PopupMenuButton<int>(
                                                    tooltip: "Select Video Server",
                                                    icon: const Icon(Icons.dns_rounded, size: 27),
                                                    onSelected: (int index) {
                                                      _videoService.swapVideoUrl(index);
                                                      _interaction.reveal();
                                                      setState(() {});
                                                    },
                                                    itemBuilder: (BuildContext context) => state
                                                        .videoInfo
                                                        .alternativeVideos
                                                        .mapIndexed(
                                                          (index, video) => PopupMenuItem<int>(
                                                        value: index,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                video.quality,
                                                                maxLines: 3,
                                                                softWrap: true,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            _videoService.videoIndex == index
                                                                ? const Padding(
                                                                  padding: EdgeInsets.only(left: 12.0),
                                                                  child: Icon(Icons.check_rounded, size: 16),
                                                                )
                                                                : const SizedBox.shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                        .toList(),
                                                  ),
                                                  PopupMenuButton<double>(
                                                    tooltip: "Adjust Playback Speed",
                                                    icon: const Icon(Icons.speed_rounded, size: 27),
                                                    onSelected: (double speed) {
                                                      _interaction.setPlaybackSpeed(speed);
                                                      setState(() {});
                                                    },
                                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
                                                      const PopupMenuItem<double>(value: 0.5, child: Text('0.5x')),
                                                      const PopupMenuItem<double>(value: 0.75, child: Text('0.75x')),
                                                      const PopupMenuItem<double>(value: 1.0, child: Text('1.0x')),
                                                      const PopupMenuItem<double>(value: 1.25, child: Text('1.25x')),
                                                      const PopupMenuItem<double>(value: 1.5, child: Text('1.5x')),
                                                      const PopupMenuItem<double>(value: 2.0, child: Text('2.0x')),
                                                    ],
                                                  ),
                                                  PopupMenuButton<CastDevice>(
                                                    tooltip: "Cast to Device",
                                                    icon: const Icon(Icons.cast_rounded, size: 22),
                                                    onSelected: (CastDevice device) {
                                                      context.read<VideoCubit>().castToDevice(device);
                                                    },
                                                    itemBuilder: (BuildContext context) => state.availableCastDevices.map(
                                                        (device) => PopupMenuItem<CastDevice>(value: device, child: Text(device.name))
                                                    ).toList()
                                                  ),
                                                  Tooltip(
                                                    message: UnyoVideoControls.videoDisplayModeTooltip(state.videoDisplayMode),
                                                    child: IconButton(
                                                      onPressed: () => context.read<VideoCubit>().cycleVideoDisplayMode(),
                                                      icon: Icon(
                                                        size: 27,
                                                        UnyoVideoControls.videoDisplayModeIcon(state.videoDisplayMode),
                                                      ),
                                                    ),
                                                  ),
                                                  Tooltip(
                                                    message: "${_videoService.isFullscreen ? "Disable" : "Enable"} Fullscreen",
                                                    child: IconButton(
                                                      onPressed: () {
                                                        _interaction.setFullscreen(!_videoService.isFullscreen);
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                        size: 27,
                                                        _videoService.isFullscreen
                                                            ? Icons.fullscreen_exit_rounded
                                                            : Icons.fullscreen_rounded,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Status slot: skip pill / up-next card. Deliberately
                        // OUTSIDE the controls fade — an active skip window
                        // must stay tappable while the bar is auto-hidden, and
                        // the up-next card appears without any interaction
                        // (WP #113).
                        Positioned(
                          right: 20.w,
                          bottom: _bottomBandHeight - _statusSlotHeight,
                          child: _buildBottomStatus(context, state),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    UnyoVideoHeaderControls(cubit: widget.videoCubit, videoService: _videoService),
                    Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 100.w.clamp(100, 170)),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

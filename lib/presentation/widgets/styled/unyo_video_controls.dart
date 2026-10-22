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
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/presentation/drawers/episode_list_drawer.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_fade_overlay.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_header_controls.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_list_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_volume_button.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoVideoControls extends StatefulWidget {
  final VideoCubit videoCubit;
  final VideoService videoService;

  const UnyoVideoControls({super.key, required this.videoCubit, required this.videoService});

  @override
  State<UnyoVideoControls> createState() => _UnyoVideoControlsState();
}

class _UnyoVideoControlsState extends State<UnyoVideoControls> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _refreshTimer;
  late VideoService _videoService;
  late Timer _hideControlsTimer;

  bool _controlsVisible = true;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Adjust the duration as needed
    );
    _controller.animateTo(1.0);
    _videoService = widget.videoService;
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _videoService.isPlaying) {
        setState(() {});
      }
    });
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _videoService.isPlaying) {
        _controlsVisible = false;
      }
    });
  }

  void playVideo() {
    if (!_videoService.isPlaying) {
      _videoService.play();
      setState(() {});
      _refreshTimer.cancel();
      _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (mounted && _videoService.isPlaying) {
          setState(() {});
        }
      });
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _videoService.isPlaying) {
          _controlsVisible = false;
        }
      });
      _controller.animateTo(1.0);
    }
  }

  void pauseVideo() {
    if (_videoService.isPlaying) {
      _refreshTimer.cancel();
      _refreshTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        if (mounted && _videoService.isPlaying) {
          setState(() {});
        }
      });
      _videoService.pause();
      _controlsVisible = true;
      setState(() {});
      _controller.animateTo(0.0);
    }
  }

  void togglePlayPause() {
    if (_videoService.isPlaying) {
      pauseVideo();
    } else {
      playVideo();
    }
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _hideControlsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.videoCubit,
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          return !_videoService.isBuffering
              ? MouseRegion(
                  onHover: (event) {
                    _hideControlsTimer.cancel();
                    _controlsVisible = true;
                    setState(() {});
                    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
                      if (mounted && _videoService.isPlaying) {
                        _controlsVisible = false;
                        setState(() {});
                      }
                    });
                  },
                  cursor: _controlsVisible ? SystemMouseCursors.basic : SystemMouseCursors.none,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _controlsVisible ? 1 : 0,
                    child: Stack(
                      children: [
                        // Screen Gestures
                        GestureDetector(onTap: () => pauseVideo()),
                        // Top and Bottom Fade Overlays
                        const UnyoFadeOverlay(isTop: true),
                        const UnyoFadeOverlay(isTop: false),
                        // Video Header Controls
                        UnyoVideoHeaderControls(cubit: widget.videoCubit, videoService: _videoService),
                        // Video Controls Overlay
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _videoService.isPlaying ? 0 : 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: IgnorePointer(
                              ignoring: _videoService.isPlaying,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _videoService.reverse(const Duration(seconds: 30));
                                      setState(() {});
                                    },
                                    iconSize: 80.w.clamp(80, 100),
                                    icon: Tooltip(
                                      waitDuration: const Duration(milliseconds: 2000),
                                      textAlign: TextAlign.center,
                                      message: "Reverse 30s",
                                      child: Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 80.w.clamp(80, 100)),
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
                                        // highlightColor: Colors.white12,
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
                                      iconSize: 80.w.clamp(80, 100),
                                      onPressed: () {
                                        _videoService.forward(const Duration(seconds: 30));
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.fast_forward_rounded, color: Colors.white, size: 80.w.clamp(80, 100)),
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
                              _hideControlsTimer.cancel();
                              _controlsVisible = false;
                              setState(() {});
                              _hideControlsTimer = Timer(const Duration(seconds: 4), () {
                                if (mounted && _videoService.isPlaying) {
                                  _controlsVisible = false;
                                  setState(() {});
                                }
                              });
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
                            height: 150,
                            child: Column(
                              children: [
                                // Video Slider
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Opacity(
                                      opacity: 0.7,
                                      child: DarkUnyoButton(
                                        text: context.read<VideoCubit>().getSkipTimeText(),
                                        color: ColorScheme.of(context).primary,
                                        width: 90.w,
                                        maxWidth: 110,
                                        maxHeight: 45,
                                        onPressed: () => context.read<VideoCubit>().performSkipActin(),
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                  ],
                                ),
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
                                            _isDragging = true;
                                            _dragValue = value;
                                            _hideControlsTimer.cancel();
                                            _controlsVisible = true;
                                            setState(() {});
                                          },
                                          onChangeEnd: (value) {
                                            _isDragging = false;
                                            _videoService.seekTo(Duration(milliseconds: value.toInt()));
                                            _hideControlsTimer = Timer(const Duration(seconds: 4), () {
                                              if (mounted && _videoService.isPlaying) {
                                                _controlsVisible = false;
                                                setState(() {});
                                              }
                                            });
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
                                          message: "${_videoService.isPlaying ? "Pause" : "Play"} Video",
                                          child: IconButton(
                                            onPressed: () => togglePlayPause(),
                                            icon: Icon(
                                              size: 27,
                                              _videoService.isPlaying
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
                                            setState(() {});
                                          },
                                          itemBuilder: (BuildContext context) => _videoService.audios
                                              .mapIndexed(
                                                (index, audio) => PopupMenuItem<int>(
                                                  value: index,
                                                  child: Text('${audio.lang}${audio.embedded ? ' - Embedded' : ''}'),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        PopupMenuButton<int>(
                                          tooltip: "Select Subtitle Track",
                                          icon: const Icon(Icons.subtitles_rounded, size: 27),
                                          onSelected: (int index) {
                                            _videoService.setSubtitle(index);
                                            setState(() {});
                                          },
                                          itemBuilder: (BuildContext context) => _videoService.subtitles
                                              .mapIndexed(
                                                (index, subtitle) => PopupMenuItem<int>(
                                              value: index,
                                              child: Text('${subtitle.lang}${subtitle.embedded ? ' - Embedded' : ''}'),
                                            ),
                                          )
                                              .toList(),
                                        ),
                                        PopupMenuButton<int>(
                                          tooltip: "Select Video Server",
                                          icon: const Icon(Icons.video_settings_rounded, size: 27),
                                          onSelected: (int index) {
                                            _videoService.swapVideoUrl(index);
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
                                            _videoService.setPlaybackSpeed(speed);
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
                                          message: "${_videoService.isFullscreen ? "Disable" : "Enable"} Fullscreen",
                                          child: IconButton(
                                            onPressed: () {
                                              _videoService.setFullscreen(!_videoService.isFullscreen);
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

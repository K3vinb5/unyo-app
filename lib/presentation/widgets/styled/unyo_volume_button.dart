import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/core/services/video/video_service.dart';

class UnyoVolumeButton extends StatefulWidget {
  final VideoService videoService;

  const UnyoVolumeButton({super.key, required this.videoService});

  @override
  CustomMaterialDesktopVolumeButtonState createState() => CustomMaterialDesktopVolumeButtonState();
}

class CustomMaterialDesktopVolumeButtonState extends State<UnyoVolumeButton>
    with SingleTickerProviderStateMixin {
  bool hover = false;

  bool mute = false;
  double _volume = 0.0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) {
        setState(() {
          hover = true;
        });
      },
      onExit: (e) {
        setState(() {
          hover = false;
        });
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            double volume = widget.videoService.volume;
            if (event.scrollDelta.dy < 0) {
              widget.videoService.setVolume((volume + 0.1).clamp(0.0, 1.0));
            }
            if (event.scrollDelta.dy > 0) {
              widget.videoService.setVolume((volume - 0.1).clamp(0.0, 1.0));
            }
          }
        },
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                double volume = widget.videoService.volume;
                if (mute) {
                  widget.videoService.setVolume(_volume);
                  mute = !mute;
                } else if (volume == 0.0) {
                  _volume = 1.0;
                  widget.videoService.setVolume(1.0);
                  mute = false;
                } else {
                  _volume = volume;
                  widget.videoService.setVolume(0.0);
                  mute = !mute;
                }

                setState(() {});
              },
              iconSize: 27,
              color: Colors.white,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: widget.videoService.volume == 0.0
                    ? const Icon(Icons.volume_off, key: ValueKey(Icons.volume_off_rounded))
                    : widget.videoService.volume < 0.5
                    ? const Icon(Icons.volume_down, key: ValueKey(Icons.volume_down_rounded))
                    : const Icon(Icons.volume_up, key: ValueKey(Icons.volume_up_rounded)),
              ),
            ),
            AnimatedOpacity(
              opacity: hover ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: AnimatedContainer(
                width: hover ? (8.0 + 52.0 + 18.0) : 0,
                duration: const Duration(milliseconds: 150),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      SizedBox(
                        width: 50.0,
                        child: SliderTheme(
                          data: SliderThemeData(
                            valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                            trackHeight: 1.2,
                            inactiveTrackColor: const Color(0x3DFFFFFF),
                            activeTrackColor: Colors.white,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                              elevation: 0.0,
                              pressedElevation: 0.0,
                            ),
                            trackShape: _CustomTrackShape(),
                            overlayColor: const Color(0x00000000),
                          ),
                          child: Slider(
                            activeColor: Colors.white,
                            min: 0,
                            max: 1,
                            value: widget.videoService.volume,
                            label: "${(widget.videoService.volume * 100).toInt().toString()}%",
                            divisions: 100,
                            onChanged: (value) {
                              setState(() {
                                mute = false;
                                widget.videoService.setVolume(value);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight;
    final left = offset.dx;
    final top = offset.dy + (parentBox.size.height - height!) / 2;
    final width = parentBox.size.width;
    return Rect.fromLTWH(left, top, width, height);
  }
}

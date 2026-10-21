import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnyoEpisodeButton extends StatefulWidget {
  final String secondaryTitle;
  final String mainTitle;
  final String episodeImageUrl;
  final int episodeNumber;
  final int progress;
  final int released;
  final bool showDivider;
  final void Function()? onPressed;

  const UnyoEpisodeButton({
    super.key,
    this.onPressed,
    required this.mainTitle,
    required this.secondaryTitle,
    required this.episodeImageUrl,
    required this.episodeNumber,
    required this.progress,
    required this.released,
    required this.showDivider
  });

  @override
  State<UnyoEpisodeButton> createState() => _UnyoEpisodeButtonState();
}

class _UnyoEpisodeButtonState extends State<UnyoEpisodeButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.released >= widget.episodeNumber
          ? widget.onPressed
          : null,
      onHover: (hovering) => setState(() => isHovered = hovering),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          widget.showDivider ? Divider(
            height: 0,
            thickness: 1,
            color: Colors.white,
            endIndent: 40.w,
            indent: 40.w,
          ) : const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 12.h, top: widget.showDivider ? 12.h : 0),
            child: AnimatedScale(
              scale: isHovered ? 1.017 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: SizedBox(
                height: 70.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 105.w.clamp(105, 200),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Opacity(
                              opacity: 0.8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(widget.episodeImageUrl, fit: BoxFit.cover,),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        SizedBox(
                          width: 120.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: widget.mainTitle,
                                waitDuration: const Duration(milliseconds: 1500),
                                child: Text(
                                  widget.mainTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: widget.secondaryTitle,
                                waitDuration: const Duration(milliseconds: 1500),
                                child: Text(
                                  widget.secondaryTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.progress >= widget.episodeNumber
                            ? const Icon(Icons.check_rounded, color: Colors.grey)
                            : const SizedBox.shrink(),
                        SizedBox(width: 12.w),
                        Text(
                          widget.released >= widget.episodeNumber
                              ? context.tr("released")
                              : context.tr("not_yet_released"),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                widget.released >= widget.episodeNumber
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

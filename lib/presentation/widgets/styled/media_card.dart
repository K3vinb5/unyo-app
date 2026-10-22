import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class MediaCard extends StatelessWidget {
  final String title;
  final int score;
  final String coverImage;
  final void Function() onPressed;
  final String status;
  final String year;
  final String format;
  final String tag;

  const MediaCard({
    super.key,
    required this.title,
    required this.score,
    required this.coverImage,
    required this.onPressed,
    required this.status,
    required this.year,
    required this.format,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152.5,
      height: 256,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UnyoInkWell(
            onTap: onPressed,
            // TODO maybe Stack over HoverAnimatedContainer
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Hero(
                  tag: tag,
                  child: HoverAnimatedContainer(
                    width: 140.0 /*.w.clamp(144.08, 181.7)*/,
                    hoverWidth: 152.5 /*.w.clamp(156.49, 199.1)*/,
                    height: 200.5 /*.h.clamp(200.44, 260.6)*/,
                    hoverHeight: 213.0 /*.h.clamp(206.03, 268.44)*/,
                    hoverCursor: SystemMouseCursors.click,
                    hoverDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2.6),
                      image: DecorationImage(
                        image: NetworkImage(coverImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(coverImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      children: [
                        score != 0
                            ? Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorScheme.of(context).primary,
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(50),
                                      topLeft: Radius.circular(50),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "  ${(score / 10)}",
                                          style: TextStyle(
                                            color:
                                                ColorScheme.of(context).primary
                                                            .computeLuminance() >
                                                        0.2
                                                    ? Colors.black.withValues(alpha:
                                                0.8,
                                                )
                                                    : Colors.white.withValues(alpha:
                                                0.8,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color:
                                              ColorScheme.of(context).primary
                                                          .computeLuminance() >
                                                      0.2
                                                  ? Colors.black.withValues(alpha:
                                                    0.8,
                                                    )
                                                  : Colors.white.withValues(alpha:
                                                    0.8,
                                                    ),
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                        SizedBox(
                          // width: 128.w,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: CircleAvatar(
                                backgroundColor:
                                    status == "RELEASING"
                                        ? Colors.green
                                        : status == "NOT_YET_RELEASED"
                                        ? Colors.amber
                                        : Colors.transparent,
                                maxRadius: 6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140.0 /*.w.clamp(144.08, 181.7)*/,
            height: 24,
            child: Center(
              child: Tooltip(
                message: title,
                waitDuration: const Duration(milliseconds: 1000),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 140.0 /*.w.clamp(144.08, 181.7)*/,
            height: 18,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: ColorScheme.of(context).tertiary.withValues(alpha: 0.8),
                    size: 17,
                  ),
                  Text(
                    " ${year.split("/")[2]}",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorScheme.of(
                        context,
                      ).tertiary.withValues(alpha: 0.8),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${format.replaceAll("_", " ")} ",
                    style: TextStyle(
                      color: ColorScheme.of(
                        context,
                      ).tertiary.withValues(alpha: 0.8),
                      overflow: TextOverflow.ellipsis,
                      fontSize:
                          format == "TV_SHORT" ||
                                  format == "SPECIAL" ||
                                  format == "MANGA" ||
                                  format == "ONE_SHOT" ||
                                  format == "MOVIE" ||
                                  format == "NOVEL" ||
                                  format == "ONE_SHOT" ||
                                  format == "MUSIC"
                              ? 8
                              : 14,
                    ),
                  ),
                  Icon(
                    format != 'MANGA' ? Icons.tv_rounded : Icons.book_rounded,
                    color: ColorScheme.of(context).tertiary.withValues(alpha: 0.8),
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

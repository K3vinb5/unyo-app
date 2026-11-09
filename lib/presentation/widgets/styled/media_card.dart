import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/media_badge_clipper.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/media_cover_silhouette.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Format labels too long for the meta row at its normal size.
const Set<String> _compactFormatLabels = <String>{
  "TV_SHORT",
  "SPECIAL",
  "MANGA",
  "ONE_SHOT",
  "MOVIE",
  "NOVEL",
  "MUSIC",
};

/// Provider format code (lowercased) -> i18n key.
///
/// The codes are API data, never copy: only their *display* is translated. They
/// are keyed lowercased and looked up case-insensitively so the literal codes
/// keep living purely as data ([_compactFormatLabels], the icon switch below),
/// which is what the raw-string ratchet expects. An unknown code falls back to
/// the underscore-free code itself.
const Map<String, String> _formatKeys = <String, String>{
  "tv": "common_format_tv",
  "tv_short": "common_format_tv_short",
  "movie": "common_format_movie",
  "ova": "common_format_ova",
  "ona": "common_format_ona",
  "special": "common_format_special",
  "music": "common_format_music",
  "manga": "common_format_manga",
  "manhwa": "common_format_manhwa",
  "manhua": "common_format_manhua",
  "novel": "common_format_novel",
  "one_shot": "common_format_one_shot",
  "doujinshi": "common_format_doujinshi",
};

/// Display label for a provider format code, translated when the code is known.
String _formatLabel(BuildContext context, String format) {
  final String? key = _formatKeys[format.toLowerCase()];
  return key == null ? format.replaceAll("_", " ") : context.tr(key);
}

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
      width: MediaCardMetrics.width,
      height: MediaCardMetrics.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UnyoInkWell(
            onTap: onPressed,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Hero(
                  tag: tag,
                  child: HoverAnimatedContainer(
                    width: MediaCardMetrics.coverWidth,
                    hoverWidth: MediaCardMetrics.width,
                    height: MediaCardMetrics.coverHeight,
                    hoverHeight: 213.0 /*.h.clamp(206.03, 268.44)*/,
                    hoverCursor: SystemMouseCursors.click,
                    hoverDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaCardMetrics.coverRadius,
                      ),
                      border: Border.all(color: Colors.white, width: 2.6),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaCardMetrics.coverRadius,
                      ),
                    ),
                    // The cover silhouette (one clip, shared with the
                    // skeleton): nothing painted in the cover stack may spill
                    // over the area the 20-radius corner cuts away. The score
                    // badge floats inside it by `badgeInset`, so its stadium
                    // ends are never carved by that corner (WP #109, #119).
                    child: MediaCoverSilhouette(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: UnyoNetworkImage(
                              url: coverImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                          score != 0
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  // Flush in the cover's bottom-right corner,
                                  // like the original leaf: MediaBadgeClipper
                                  // hands the badge's right end over to the
                                  // cover's own 20-radius arc, so nothing is
                                  // carved into a square step (WP #119).
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      MediaCardMetrics.badgeInset,
                                    ),
                                    child: Opacity(
                                      opacity: 0.8,
                                      child: ClipPath(
                                        clipper: const MediaBadgeClipper(),
                                        child: ColoredBox(
                                          color: ColorScheme.of(
                                            context,
                                          ).primary,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "  ${TextUtils.scoreOutOfTen(score)}",
                                                  style: TextStyle(
                                                    color:
                                                        ColorScheme.of(context)
                                                                .primary
                                                                .computeLuminance() >
                                                            0.2
                                                        ? Colors.black
                                                              .withValues(
                                                                alpha: 0.8,
                                                              )
                                                        : Colors.white
                                                              .withValues(
                                                                alpha: 0.8,
                                                              ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color:
                                                      ColorScheme.of(context)
                                                              .primary
                                                              .computeLuminance() >
                                                          0.2
                                                      ? Colors.black.withValues(
                                                          alpha: 0.8,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.8,
                                                        ),
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          // Release-status dot, bottom-left of the cover.
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 5.0,
                              left: 5.0,
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: CircleAvatar(
                                backgroundColor: status == "RELEASING"
                                    ? Colors.green
                                    : status == "NOT_YET_RELEASED"
                                    ? Colors.amber
                                    : Colors.transparent,
                                maxRadius: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.titleRowHeight,
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
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.metaRowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: ColorScheme.of(
                      context,
                    ).tertiary.withValues(alpha: 0.8),
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
                    "${_formatLabel(context, format)} ",
                    style: TextStyle(
                      color: ColorScheme.of(
                        context,
                      ).tertiary.withValues(alpha: 0.8),
                      overflow: TextOverflow.ellipsis,
                      fontSize: _compactFormatLabels.contains(format) ? 8 : 14,
                    ),
                  ),
                  Icon(
                    format != 'MANGA' ? Icons.tv_rounded : Icons.book_rounded,
                    color: ColorScheme.of(
                      context,
                    ).tertiary.withValues(alpha: 0.8),
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

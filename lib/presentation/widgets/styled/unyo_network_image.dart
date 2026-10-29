import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// The app's single network-image widget: the slot is filled with the skeleton
/// colour until the first frame of [url] arrives, then the image fades in over
/// [fadeDuration] with [fadeCurve] instead of popping in.
///
/// The placeholder matters as much as the fade: covers, banners and avatars are
/// painted once their data has already arrived, so the area used to stay empty
/// for as long as the download took (see the media-list grid in the OP #62
/// proof shots, where the posters were missing but the titles were not).
///
/// When `MediaQuery.disableAnimations` is set the frame is swapped in without
/// animating, matching [SkeletonScope]'s accessibility path.
class UnyoNetworkImage extends StatelessWidget {
  const UnyoNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 0,
    this.fadeDuration = defaultFadeDuration,
    this.filterQuality = FilterQuality.medium,
  });

  /// 250ms is the Material default for a content image replacing a placeholder.
  static const Duration defaultFadeDuration = Duration(milliseconds: 250);
  static const Curve fadeCurve = Curves.easeOut;

  /// Empty means "no image": only the placeholder is painted.
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final double borderRadius;
  final Duration fadeDuration;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ColoredBox(
          color: SkeletonBlock.baseColor(context),
          child: url.isEmpty
              ? null
              : Image(
                  image: NetworkImage(url),
                  width: width,
                  height: height,
                  fit: fit,
                  alignment: alignment,
                  filterQuality: filterQuality,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) =>
                          const SizedBox.shrink(),
                  frameBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (wasSynchronouslyLoaded || reduceMotion) {
                          return child;
                        }
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: fadeDuration,
                          curve: fadeCurve,
                          child: child,
                        );
                      },
                ),
        ),
      ),
    );
  }
}

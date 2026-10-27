import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Generic row placeholder: circular leading block, title and subtitle bars and
/// an optional trailing bar.
///
/// Mirrors `widgets/styled/user_avatar.dart` for the login screen (pass
/// [leadingSize] 160 and [circleLeading] true) and plain list rows.
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({
    super.key,
    this.height = 64,
    this.leadingSize = 40,
    this.titleWidth = 160,
    this.subtitleWidth = 100,
    this.circleLeading = true,
    this.showTrailing = false,
  });

  final double height;
  final double leadingSize;
  final double titleWidth;
  final double subtitleWidth;
  final bool circleLeading;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonBlock(
            width: leadingSize,
            height: leadingSize,
            borderRadius: circleLeading ? leadingSize / 2 : 8,
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: titleWidth, height: 14),
              const SizedBox(height: 8),
              SkeletonBlock(width: subtitleWidth, height: 12),
            ],
          ),
          if (showTrailing) ...[
            const Spacer(),
            const SkeletonBlock(width: 45, height: 45, borderRadius: 10),
          ],
        ],
      ),
    );
  }
}

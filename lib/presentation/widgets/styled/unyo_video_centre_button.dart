// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// The centre play/pause glyph — the one control that resumes a paused frame.
///
/// It is deliberately *not* focusable. [InkWell] takes the focus on a pointer
/// tap by default, and its `focusColor` then keeps a filled disc painted behind
/// the glyph for as long as it holds focus: on a paused screen the button read
/// as *selected* (WP #119 follow-up). Keyboard access does not go through this
/// button anyway — `VideoShortcutScope` keeps the keyboard on its own focus
/// node and Space/K resume the frame — so declining the focus here costs
/// nothing and stops the pointer path from taking the shortcuts with it.
class UnyoVideoCentreButton extends StatelessWidget {
  const UnyoVideoCentreButton({
    super.key,
    required this.onPressed,
    required this.progress,
  });

  /// Glyph morph: 1 = pause bars, 0 = play triangle
  /// (`AnimatedIcons.play_pause`). Retargeted from the player's own state, never
  /// from whichever widget raised the change.
  final Animation<double> progress;

  final VoidCallback onPressed;

  /// Glyph size: screen-scaled and clamped, matching the flanking ±30 s
  /// buttons' `_centreIconSize`.
  static double iconSize() => 85.w.clamp(85, 110);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        waitDuration: const Duration(milliseconds: 2000),
        textAlign: TextAlign.center,
        message: 'Resume Play',
        child: UnyoInkWell(
          onTap: onPressed,
          // No focus, therefore no focus ring (see the class comment).
          canRequestFocus: false,
          // Clickable, and it says so: the glyph is a button (resume the frame),
          // so the pointer becomes a hand over it. The canvas behind it stays on
          // the default arrow — the picture never advertises a click (WP #119).
          mouseCursor: SystemMouseCursors.click,
          focusColor: Colors.transparent,
          hoverColor: Colors.white10,
          splashColor: Colors.white12,
          borderRadius: BorderRadius.circular(60.w),
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            size: iconSize(),
            color: Colors.white,
            progress: progress,
          ),
        ),
      ),
    );
  }
}

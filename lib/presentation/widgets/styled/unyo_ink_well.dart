import 'package:material_ui/material_ui.dart';

/// An [InkWell] that always shows the clickable mouse cursor on hover.
///
/// Flutter 3.47 changed the default `mouseCursor` of [InkWell] from
/// [WidgetStateMouseCursor.clickable] to
/// [WidgetStateMouseCursor.adaptiveClickable]
/// (`packages/flutter/lib/src/material/ink_well.dart`). The adaptive cursor
/// resolves to [SystemMouseCursors.click] only on web; on desktop (Linux,
/// Windows, macOS) it resolves to [SystemMouseCursors.basic], so a bare
/// [InkWell] no longer looks clickable with a mouse.
///
/// material_ui 1.8.0 mirrors that framework default, so every clickable
/// surface in the app should use this wrapper instead of a bare [InkWell].
/// Passing a `mouseCursor` explicitly still wins.
class UnyoInkWell extends StatelessWidget {
  const UnyoInkWell({
    super.key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onLongPressUp,
    this.onHover,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.borderRadius,
    this.customBorder,
    this.mouseCursor,
    this.overlayColor,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.canRequestFocus = true,
    this.excludeFromSemantics = false,
    this.enableFeedback = true,
    this.splashFactory,
    this.radius,
  });

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressUpCallback? onLongPressUp;
  final ValueChanged<bool>? onHover;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final MouseCursor? mouseCursor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;
  final bool canRequestFocus;
  final bool excludeFromSemantics;
  final bool enableFeedback;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Flutter 3.47 defaults to the adaptive (arrow on desktop) cursor, so
      // opt back into the hand cursor wherever this wrapper is used.
      mouseCursor: mouseCursor ?? WidgetStateMouseCursor.clickable,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onLongPressUp: onLongPressUp,
      onHover: onHover,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      borderRadius: borderRadius,
      customBorder: customBorder,
      overlayColor: overlayColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      hoverColor: hoverColor,
      focusColor: focusColor,
      canRequestFocus: canRequestFocus,
      excludeFromSemantics: excludeFromSemantics,
      enableFeedback: enableFeedback,
      splashFactory: splashFactory,
      radius: radius,
      child: child,
    );
  }
}

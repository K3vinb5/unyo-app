import 'package:material_ui/material_ui.dart';

/// Hosts the single shimmer [AnimationController] of a screen.
///
/// Every [SkeletonBlock] below a [SkeletonScope] shares one animation, so a
/// screen with a dozen placeholders still only runs one ticker. When
/// `MediaQuery.disableAnimations` is set (accessibility) the blocks render
/// static: [animationOf] returns `null` and nothing animates.
///
/// A screen that never wraps itself in a [SkeletonScope] still gets static
/// blocks instead of an exception.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({
    super.key,
    this.child,
    this.period = const Duration(milliseconds: 1200),
  });

  final Widget? child;

  /// Duration of one full shimmer sweep.
  final Duration period;

  /// The shimmer driving the nearest [SkeletonScope], or `null` when shimmer
  /// is disabled.
  static Animation<double>? animationOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonAnimation>()?.animation;

  /// Whether skeletons below [context] shimmer.
  static bool isAnimated(BuildContext context) => animationOf(context) != null;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool shouldAnimate = !(MediaQuery.maybeDisableAnimationsOf(context) ??
        false);
    if (shouldAnimate && !_running) {
      _running = true;
      _controller.repeat();
    } else if (!shouldAnimate && _running) {
      _running = false;
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SkeletonAnimation(
    animation: _running ? _controller : null,
    child: widget.child ?? const SizedBox.shrink(),
  );
}

class _SkeletonAnimation extends InheritedWidget {
  const _SkeletonAnimation({required this.animation, required super.child});

  final Animation<double>? animation;

  @override
  bool updateShouldNotify(_SkeletonAnimation oldWidget) =>
      animation != oldWidget.animation;
}

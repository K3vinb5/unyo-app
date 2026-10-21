import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

class UnyoAnimatedImageBanner extends StatefulWidget {
  final String imageUrl;
  const UnyoAnimatedImageBanner({super.key, required this.imageUrl});

  @override
  State<UnyoAnimatedImageBanner> createState() =>
      _UnyoAnimatedImageBannerState();
}

class _UnyoAnimatedImageBannerState extends State<UnyoAnimatedImageBanner> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Offset _currentFocalPoint = Offset.zero;
  Offset _targetFocalPoint = Offset.zero;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.2, end: 1.6)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addListener(_updateFocalPoint);
    _selectNewFocalPoint();
  }

  void _updateFocalPoint() {
    if (_animationController.isCompleted) {
      _selectNewFocalPoint();
    }
  }

  void _selectNewFocalPoint() {
    setState(() {
      _currentFocalPoint = _targetFocalPoint;
      _targetFocalPoint = Offset(
        _random.nextDouble() * 0.5 + 0.3,
        _random.nextDouble() * 0.5 + 0.3,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final lerpedOffset =
            Offset.lerp(
              _currentFocalPoint,
              _targetFocalPoint,
              _animationController.value,
            )!;

        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment(
              2.0 * lerpedOffset.dx - 1.0,
              2.0 * lerpedOffset.dy - 1.0,
            ),
            child: Image.network(widget.imageUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

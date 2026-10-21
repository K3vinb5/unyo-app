import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class HoverAnimatedContainer extends StatefulWidget {
  final double width;
  final double hoverWidth;
  final double height;
  final double hoverHeight;
  final Curve curve;
  final Decoration decoration;
  final Decoration hoverDecoration;
  final SystemMouseCursor hoverCursor;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry hoverMargin;
  final Duration duration;
  final Alignment alignment;

  const HoverAnimatedContainer({
    super.key,
    required this.width,
    required this.hoverWidth,
    required this.height,
    required this.hoverHeight,
    required this.decoration,
    required this.hoverDecoration,
    required this.child,
    this.curve = Curves.linear,
    this.hoverCursor = SystemMouseCursors.basic,
    this.margin = EdgeInsets.zero,
    this.hoverMargin = EdgeInsets.zero,
    this.duration = const Duration(milliseconds: 200),
    this.alignment = Alignment.center,
  });

  @override
  State<HoverAnimatedContainer> createState() => _HoverAnimatedContainerState();
}

class _HoverAnimatedContainerState extends State<HoverAnimatedContainer> {
  bool hovering = false;

  void _onHover(bool value) => setState(() => hovering = value);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: hovering ? widget.hoverCursor : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        width: hovering ? widget.hoverWidth : widget.width,
        height: hovering ? widget.hoverHeight : widget.height,
        decoration: hovering ? widget.hoverDecoration : widget.decoration,
        margin: hovering ? widget.hoverMargin : widget.margin,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
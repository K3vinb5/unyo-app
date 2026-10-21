import 'package:flutter/material.dart';

class StyledButton extends StatefulWidget {
  const StyledButton(
      {super.key,
      this.text,
      required this.onPressed,
      this.child,
      this.backgroundColor});

  final String? text;
  final Widget? child;
  final Color? backgroundColor;
  final void Function() onPressed;

  @override
  State<StyledButton> createState() => _StyledButtonState();
}

class _StyledButtonState extends State<StyledButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          widget.backgroundColor ?? const Color.fromARGB(255, 37, 37, 37),
        ),
        foregroundColor: const WidgetStatePropertyAll(
          Colors.white,
        ),
      ),
      onPressed: widget.onPressed,
      child: widget.text != null
          ? Text(widget.text!)
          : widget.child ?? const SizedBox(),
    );
  }
}

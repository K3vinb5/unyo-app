import 'package:material_ui/material_ui.dart';

class UnyoMenuIcon extends StatefulWidget {
  final bool isSelected;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final void Function() onPressed;

  const UnyoMenuIcon({
    super.key,
    required this.isSelected,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.onPressed,
  });

  @override
  State<UnyoMenuIcon> createState() => _UnyoMenuIconState();
}

class _UnyoMenuIconState extends State<UnyoMenuIcon> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(15.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.white.withValues(alpha: .10)
                  : isHovered
                      ? Colors.white.withValues(alpha: .05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedContainer(
                  height: widget.isSelected ? 33.0 : 0,
                  duration: const Duration(milliseconds: 200),
                  width: 3.5,
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).tertiary,
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
                SizedBox(width: widget.isSelected ? 10.0 : 9.5),
                AnimatedScale(
                  scale: isHovered && !widget.isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isSelected ? widget.selectedIcon : widget.unselectedIcon,
                    size: 27,
                    color: widget.isSelected
                        ? ColorScheme.of(context).tertiary
                        : isHovered
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
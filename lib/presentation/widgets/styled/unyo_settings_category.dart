import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnyoSettingsCategory extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String alignment;
  final String childAlignment;
  final List<Widget> settingsOptions;
  final bool initiallyExpanded;
  final bool isChild;

  const UnyoSettingsCategory({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.alignment,
    required this.childAlignment,
    required this.settingsOptions,
    this.initiallyExpanded = false,
    this.isChild = false,
  });

  @override
  State<UnyoSettingsCategory> createState() => _UnyoSettingsCategoryState();
}

class _UnyoSettingsCategoryState extends State<UnyoSettingsCategory> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuint));
    _fadeAnimation = CurvedAnimation(parent: _slideController, curve: Curves.bounceIn, reverseCurve: Curves.bounceOut);

    if (_isExpanded) _slideController.value = 1.0;
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpanded,
          child: Container(
            width: double.infinity,
            height: 75,
            decoration: BoxDecoration(
              borderRadius:
                  widget.alignment == "top"
                      ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                      : widget.alignment == "bottom" && !_isExpanded
                      ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )
                      : BorderRadius.circular(0),
              color: !widget.isChild ? Colors.black.withValues(alpha: 0.15) : Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                        ),
                        child: Icon(widget.icon, color: ColorScheme.of(context).tertiary),
                      ),
                      const SizedBox(width: 18.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(widget.description, style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.75 : 0.50,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Align(alignment: Alignment.centerLeft, heightFactor: _slideController.value, child: child);
            },
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      widget.childAlignment == "bottom"
                          ? const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )
                          : BorderRadius.circular(0),
                  color: !widget.isChild ? Colors.black.withValues(alpha: 0.15) : Colors.transparent,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 55),
                    child: Column(
                      children: [
                        Column(children: widget.settingsOptions),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

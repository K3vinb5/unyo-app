import 'package:material_ui/material_ui.dart';

class UnyoSortWidget extends StatefulWidget {
  final List<String> sortingOptions;
  final void Function(String)? onSortChanged;
  final String? initialSelection;
  final double? width;
  final IconData icon;

  const UnyoSortWidget({
    super.key,
    required this.sortingOptions,
    this.onSortChanged,
    this.initialSelection,
    this.width,
    this.icon = Icons.sort_rounded,
  });

  @override
  State<UnyoSortWidget> createState() => _UnyoSortWidgetState();
}

class _UnyoSortWidgetState extends State<UnyoSortWidget> {
  late String _selectedOption;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedOption =
        widget.initialSelection ?? (widget.sortingOptions.isNotEmpty ? widget.sortingOptions.first : '');
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: Colors.transparent)),
                Positioned(
                  width: 140,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: const Offset(0, 54),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      color: ColorScheme.of(context).secondary.withValues(alpha: 0.8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          children:
                              widget.sortingOptions.map((option) {
                                final isSelected = option == _selectedOption;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedOption = option);
                                    widget.onSortChanged?.call(option);
                                    _overlayEntry?.markNeedsBuild();
                                    _closeDropdown();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    // _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(widget.icon, color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7)),
                onPressed: _toggleDropdown,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedOption,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedOption.isEmpty ? Colors.white.withValues(alpha: 0.8) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

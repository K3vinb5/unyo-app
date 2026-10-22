import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoMultiSelectDropdown extends StatefulWidget {
  final void Function(List<String>)? onChanged;
  final int debounceMilliseconds;
  final List<String> children;
  final IconData? icon;
  final String? label;
  final List<String> selectedValues;

  const UnyoMultiSelectDropdown({
    super.key,
    required this.children,
    required this.debounceMilliseconds,
    this.icon,
    required this.label,
    required this.onChanged,
    this.selectedValues = const [],
  });

  @override
  State<UnyoMultiSelectDropdown> createState() => _UnyoMultiSelectDropdownState();
}

class _UnyoMultiSelectDropdownState extends State<UnyoMultiSelectDropdown> {
  late List<String> _selectedItems;
  final LayerLink _layerLink = LayerLink();
  Timer debounceTimer = Timer(const Duration(milliseconds: 0), () {});
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(covariant UnyoMultiSelectDropdown oldWidget) {
    if (oldWidget.selectedValues != _selectedItems ) {
      setState(() {
      _selectedItems = List.from(widget.selectedValues);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // _closeDropdown();
    super.dispose();
  }

  String _getDisplayText() {
    if (_selectedItems.isEmpty) return '';
    if (_selectedItems.length == 1) return _selectedItems.first;
    return '${_selectedItems.first} +${_selectedItems.length - 1}';
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
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                // backdrop
                Positioned.fill(child: Container(color: Colors.transparent)),
                Positioned(
                  width: size.width - 10,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height + 4),
                    child: Material(
                      elevation: 4,
                      color: ColorScheme.of(context).secondary.withValues(alpha: 0.8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          children:
                              widget.children.map((item) {
                                final isSelected = _selectedItems.contains(item);
                                return UnyoInkWell(
                                  onTap: () {
                                    // manage internal state here (not relying on external controller)
                                    if (isSelected) {
                                      _selectedItems.remove(item);
                                    } else {
                                      _selectedItems.add(item);
                                    }
                                    // notify caller with a defensive copy
                                    debounceTimer.cancel();
                                    debounceTimer = Timer(
                                      Duration(milliseconds: widget.debounceMilliseconds),
                                      () => widget.onChanged?.call(List.from(_selectedItems)),
                                    );
                                    // update the main widget (label, border) and refresh overlay UI
                                    setState(() {});
                                    _overlayEntry?.markNeedsBuild();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check, color: Colors.white.withValues(alpha: 0.8), size: 20),
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: UnyoInkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _isOpen
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
                width: _isOpen ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    _selectedItems.isEmpty ? widget.label ?? '' : _getDisplayText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedItems.isEmpty ? Colors.white.withValues(alpha: 0.8) : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: _isOpen ? Colors.white : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

class UnyoDropdown extends StatefulWidget {
  final void Function(String?)? onPressed;
  final List<String> children;
  final double? width;
  final IconData? icon;
  final String? label;
  final String? selectedValue;
  final bool? reactOnCancel;

  const UnyoDropdown({
    super.key,
    required this.children,
    this.width,
    this.icon,
    required this.label,
    required this.onPressed,
    this.selectedValue,
    this.reactOnCancel = false,
  });

  @override
  State<UnyoDropdown> createState() => _UnyoDropdownState();
}

class _UnyoDropdownState extends State<UnyoDropdown> {
  late TextEditingController searchController;

  @override
  void initState() {
    searchController = TextEditingController();
    if (widget.selectedValue != null) {
      searchController.text = widget.selectedValue!;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UnyoDropdown oldWidget) {
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        searchController.text = widget.selectedValue ?? '';
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constrains) => DropdownMenu<String?>(
            key: const ValueKey('unyo-dropdown'),
            width: widget.width ?? constrains.maxWidth,
            controller: searchController,
            onSelected: widget.onPressed,
            leadingIcon: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Icon(
                widget.icon ?? Icons.search_rounded,
                color: ColorScheme.of(context).tertiary.withValues(alpha: 0.7),
              ),
            ),
            trailingIcon:
                widget.selectedValue == null || widget.selectedValue!.isEmpty || searchController.text.isEmpty
                    ? Icon(Icons.arrow_drop_down, color: ColorScheme.of(context).tertiary.withValues(alpha: 0.7))
                    : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                          });
                          if (widget.reactOnCancel == true) {
                            widget.onPressed?.call(null);
                          }
                        },
                        child: Icon(Icons.clear, color: ColorScheme.of(context).tertiary.withValues(alpha: 0.7)),
                      ),
                    ),
            enableFilter: true,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorScheme.of(context).secondary.withValues(alpha: 0.8)),
              maximumSize: WidgetStatePropertyAll(Size(constrains.maxWidth, 300)),
            ),
            label:
                widget.label != null
                    ? Text(widget.label!, style: TextStyle(color: Colors.white.withValues(alpha: 0.8)))
                    : null,
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                borderSide: BorderSide(color: ColorScheme.of(context).primary, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                borderSide: BorderSide(color: ColorScheme.of(context).tertiary.withValues(alpha: 0.8), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            ),
            dropdownMenuEntries:
                [
                  ...widget.children
                      .map(
                        (element) => DropdownMenuEntry<String?>(
                          value: element,
                          label: element,
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                            alignment: Alignment.center,
                          ),
                        ),
                      )
                ].toList(),
          ),
    );
  }
}

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_sort_widget.dart';

/// The sort strip shared by the anime and manga advanced-search screens.
///
/// The two provider dictionaries ([sortOptions] / [sortOrders]) are independent
/// capabilities: a provider that offers sort fields but no direction control
/// (Shikimori: `OrderEnum` has no `_desc` twin for any option it exposes) must
/// still render the field picker. Gating the whole row on both flags hid the
/// picker — the row is therefore shown when **either** dictionary is enabled,
/// and each [UnyoSortWidget] still renders only for its own flag.
class AdvancedSearchSortRow extends StatelessWidget {
  /// `(enabled, options)` for the sort FIELD picker.
  final (bool, List<String>) sortOptions;

  /// `(enabled, options)` for the sort DIRECTION picker.
  final (bool, List<String>) sortOrders;

  final String? selectedSortOption;
  final String? selectedSortOrder;
  final void Function(String)? onSortOptionChanged;
  final void Function(String)? onSortOrderChanged;

  const AdvancedSearchSortRow({
    super.key,
    required this.sortOptions,
    required this.sortOrders,
    this.selectedSortOption,
    this.selectedSortOrder,
    this.onSortOptionChanged,
    this.onSortOrderChanged,
  });

  /// Whether anything can be sorted at all — no capability, no row.
  bool get hasAnySortCapability => sortOptions.$1 || sortOrders.$1;

  @override
  Widget build(BuildContext context) {
    if (!hasAnySortCapability) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (sortOptions.$1)
          UnyoSortWidget(
            sortingOptions: sortOptions.$2,
            initialSelection: selectedSortOption,
            onSortChanged: onSortOptionChanged,
          ),
        const SizedBox(width: 10),
        if (sortOrders.$1)
          UnyoSortWidget(
            sortingOptions: sortOrders.$2,
            initialSelection: selectedSortOrder,
            onSortChanged: onSortOrderChanged,
          ),
        SizedBox(width: 40.w),
      ],
    );
  }
}

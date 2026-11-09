import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/states/media_list_entry_display.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// The list-status chip that opens the list editor, on both details pages
/// (WP #167).
///
/// It was inlined in the anime page only, which is why manga entries had no
/// editor entry point at all. One widget means one place decides what the chip
/// reads: a title on no list shows the localized "Not on list" instead of the
/// raw `ADD TO LIST` sentinel.
class MediaListStatusChip extends StatelessWidget {
  static const Key chipKey = ValueKey('media-list-status-chip');

  final String status;
  final void Function() onTap;

  const MediaListStatusChip({super.key, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String label = MediaListEntryDisplay.statusLabel(status) ?? context.tr('details_status_not_on_list');
    return UnyoInkWell(
      key: chipKey,
      onTap: onTap,
      child: Container(
        width: 120.w,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

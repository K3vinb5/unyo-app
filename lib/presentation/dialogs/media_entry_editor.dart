import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/states/episode_count.dart';
import 'package:unyo/application/states/media_list_entry_display.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/presentation/dialogs/confirm_dialog.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_slider.dart';

/// The one list-entry editor layout, shared by the anime and manga details
/// pages (WP #167).
///
/// Both pages edit the same tracker vocabulary — status, progress, score,
/// started/completed dates and removal — against the same [MediaListEntry]
/// shape, so the layout lives here once and each details cubit supplies the
/// values and the actions. Only the *meaning* of progress differs (episodes vs
/// chapters), which is why the caller passes its own [progressLabel] and range.
///
/// Every displayed value goes through [MediaListEntryDisplay]: a fresh entry
/// carries `-1` sentinels that must never reach a slider or the status field.
class MediaEntryEditor extends StatelessWidget {
  static const Key dialogKey = ValueKey('media-entry-editor');
  static const Key deleteButtonKey = ValueKey('media-entry-editor-delete');

  /// The entry being edited (the cubit's *draft* copy, not the stored one).
  final MediaListEntry entry;

  /// Upper bound of the progress slider — episodes for anime, chapters for
  /// manga. Zero means "unknown": the slider keeps its 0-minimum.
  final int progressMax;

  /// Localized title of the progress slider.
  final String progressLabel;

  final void Function(String?) onStatusChanged;
  final void Function(int) onProgressChanged;
  final void Function(double) onScoreChanged;
  final void Function() onStartedAtPressed;
  final void Function() onCompletedAtPressed;
  final void Function() onCancel;
  final void Function() onConfirm;

  /// Runs after the user confirms the removal card; the caller owns the write.
  final void Function() onDelete;

  const MediaEntryEditor({
    super.key,
    required this.entry,
    required this.progressMax,
    required this.progressLabel,
    required this.onStatusChanged,
    required this.onProgressChanged,
    required this.onScoreChanged,
    required this.onStartedAtPressed,
    required this.onCompletedAtPressed,
    required this.onCancel,
    required this.onConfirm,
    required this.onDelete,
  });

  /// `day/month/year`, or the entity's `~` marker when no date is set.
  String _date(List<String> parts) =>
      parts.length >= 3 ? '${parts[0]}/${parts[1]}/${parts[2]}' : '~';

  Future<void> _confirmRemoval(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: dialogContext.tr('details_remove_entry_title'),
        message: dialogContext.tr('details_remove_entry_message'),
        onConfirm: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: dialogKey,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: SizedBox(
        width: 906.w,
        height: 540.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0.w, vertical: 36.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('details_list_editor'),
                        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        key: deleteButtonKey,
                        onPressed: () => _confirmRemoval(context),
                        icon: const Icon(Icons.delete),
                        style: const ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(12.0, 12.0))),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0.h),
                  UnyoDropdown(
                    children: MediaListEntryDisplay.statusOptions,
                    label: context.tr('details_status'),
                    onPressed: onStatusChanged,
                    selectedValue:
                        MediaListEntryDisplay.statusLabel(entry.status) ??
                        context.tr('details_status_not_on_list'),
                  ),
                  SizedBox(height: 25.0.h),
                  UnyoSlider(
                    minValue: 0,
                    initialValue: EpisodeCount.progressForControl(
                      progress: entry.progress,
                      episodeCount: progressMax,
                    ),
                    title: progressLabel,
                    maxValue: progressMax,
                    onChanged: (value) => onProgressChanged(value.toInt()),
                  ),
                  SizedBox(height: 25.0.h),
                  UnyoSlider(
                    minValue: 0,
                    initialValue: MediaListEntryDisplay.score(entry.score),
                    title: context.tr('details_score'),
                    maxValue: 10,
                    onChanged: onScoreChanged,
                  ),
                  SizedBox(height: 25.0.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('details_started_at'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4.0),
                          Text(_date(entry.startedAt)),
                          const SizedBox(width: 5.0),
                          IconButton(
                            onPressed: onStartedAtPressed,
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                      SizedBox(width: 25.0.w),
                      Row(
                        children: [
                          Text(
                            context.tr('details_completed_at'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4.0),
                          Text(_date(entry.completedAt)),
                          const SizedBox(width: 5.0),
                          IconButton(
                            onPressed: onCompletedAtPressed,
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                      SizedBox(width: 25.0.w),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DarkUnyoButton(
                        text: context.tr('common_cancel'),
                        maxHeight: 50,
                        onPressed: onCancel,
                      ),
                      SizedBox(width: 25.0.w),
                      LightUnyoButton(
                        text: context.tr('common_confirm'),
                        maxHeight: 50,
                        onPressed: onConfirm,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

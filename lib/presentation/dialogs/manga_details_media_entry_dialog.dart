import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/application/cubits/manga_details_cubit.dart';
import 'package:unyo/application/states/manga_details_state.dart';
import 'package:unyo/presentation/dialogs/media_entry_editor.dart';

/// Manga details list editor (WP #167): the anime editor's shared layout bound
/// to [MangaDetailsCubit], with chapters as the progress range.
class MangaDetailsMediaEntryDialog extends StatelessWidget {
  final MangaDetailsCubit cubit;

  const MangaDetailsMediaEntryDialog({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MangaDetailsCubit, MangaDetailsState>(
        builder: (context, state) => MediaEntryEditor(
          entry: state.newMediaListEntry,
          progressMax: state.selectedManga.chapters,
          progressLabel: context.tr('details_chapters'),
          onStatusChanged: context.read<MangaDetailsCubit>().updateMediaListEntryStatus,
          onProgressChanged: context.read<MangaDetailsCubit>().updateMediaListEntryProgress,
          onScoreChanged: context.read<MangaDetailsCubit>().updateMediaListEntryScore,
          onStartedAtPressed: () => context.read<MangaDetailsCubit>().updateMediaListEntryStartedAt(context),
          onCompletedAtPressed: () => context.read<MangaDetailsCubit>().updateMediaListEntryCompletedAt(context),
          onCancel: () => context.read<MangaDetailsCubit>().popRouteEffect(context),
          onConfirm: () => context.read<MangaDetailsCubit>().updateMediaListEntry(context),
          onDelete: () => context.read<MangaDetailsCubit>().removeMediaListEntry(context),
        ),
      ),
    );
  }
}

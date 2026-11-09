import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/application/states/episode_count.dart';
import 'package:unyo/presentation/dialogs/media_entry_editor.dart';

/// Anime details list editor: binds the shared [MediaEntryEditor] layout to
/// [AnimeDetailsCubit] (WP #167 moved the layout out of this file so the manga
/// page can reuse it).
class AnimeDetailsMediaEntryDialog extends StatelessWidget {
  final AnimeDetailsCubit cubit;

  const AnimeDetailsMediaEntryDialog({super.key, required this.cubit});

  /// The list editor's progress range: the same resolved count the episode
  /// lists render, so an unknown provider total cannot collapse it to zero.
  int _episodeCount(AnimeDetailsState state) => EpisodeCount.resolve(
    extensionResults: state.extensionEpisodeResults.length,
    episodesInfo: state.episodesInfo.length,
    metadataTotal: state.selectedAnime.episodes,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
        builder: (context, state) => MediaEntryEditor(
          entry: state.newMediaListEntry,
          progressMax: _episodeCount(state),
          progressLabel: context.tr('details_progress'),
          onStatusChanged: context.read<AnimeDetailsCubit>().updateMediaListEntryStatus,
          onProgressChanged: context.read<AnimeDetailsCubit>().updateMediaListEntryProgress,
          onScoreChanged: context.read<AnimeDetailsCubit>().updateMediaListEntryScore,
          onStartedAtPressed: () => context.read<AnimeDetailsCubit>().updateMediaListEntryStartedAt(context),
          onCompletedAtPressed: () => context.read<AnimeDetailsCubit>().updateMediaListEntryCompletedAt(context),
          onCancel: () => context.read<AnimeDetailsCubit>().popRouteEffect(context),
          onConfirm: () => context.read<AnimeDetailsCubit>().updateMediaListEntry(context),
          onDelete: () => context.read<AnimeDetailsCubit>().removeMediaListEntry(context),
        ),
      ),
    );
  }
}

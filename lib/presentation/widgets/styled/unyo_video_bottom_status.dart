// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/services/video/skip_window.dart';
import 'package:unyo/presentation/video/video_player_interaction.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

/// What occupies the status slot above the seek slider.
enum VideoBottomSlot {
  /// "+ 85s": the manual skip button, fades with the rest of the bar.
  manualSkip,

  /// "Skip Opening" / "Skip Ending": shown whenever the window is active,
  /// including while the rest of the bar is auto-hidden (WP #113 B).
  skipWindow,

  /// The end-of-episode up-next card (WP #113 A).
  upNext,
}

/// The status slot above the seek bar: skip pill, up-next card, or the manual
/// skip button — one at a time, never stacked.
///
/// Rendered *outside* the controls fade so an active skip window can never be
/// hidden by the 4 s auto-hide. Everything else in the slot still fades with
/// the bar.
class UnyoVideoBottomStatus extends StatelessWidget {
  const UnyoVideoBottomStatus({
    super.key,
    required this.controlsVisible,
    required this.skipKind,
    required this.skipLabel,
    required this.upNextVisible,
    required this.seriesTitle,
    required this.episodeLabel,
    required this.thumbnailUrl,
    required this.onSkip,
    required this.onWatchNow,
    required this.onDismiss,
  });

  /// Width of the card, so the slot keeps its footprint between states.
  static const double cardWidth = 430;

  final bool controlsVisible;
  final SkipWindowKind skipKind;
  final String skipLabel;
  final bool upNextVisible;
  final String seriesTitle;
  final String episodeLabel;
  final String thumbnailUrl;
  final VoidCallback onSkip;
  final VoidCallback onWatchNow;
  final VoidCallback onDismiss;

  /// Precedence: an active skip window owns the slot (that is the actionable
  /// control at that moment), then the up-next card, then the manual skip.
  static VideoBottomSlot resolveSlot({
    required SkipWindowKind skipKind,
    required bool upNextVisible,
  }) {
    if (skipKind != SkipWindowKind.none) return VideoBottomSlot.skipWindow;
    if (upNextVisible) return VideoBottomSlot.upNext;
    return VideoBottomSlot.manualSkip;
  }

  @override
  Widget build(BuildContext context) {
    switch (resolveSlot(skipKind: skipKind, upNextVisible: upNextVisible)) {
      case VideoBottomSlot.upNext:
        return _UpNextCard(
          seriesTitle: seriesTitle,
          episodeLabel: episodeLabel,
          thumbnailUrl: thumbnailUrl,
          onWatchNow: onWatchNow,
          onDismiss: onDismiss,
        );
      case VideoBottomSlot.skipWindow:
        return _skipPill(context, opacity: 1);
      case VideoBottomSlot.manualSkip:
        return _skipPill(context, opacity: controlsVisible ? 1 : 0);
    }
  }

  Widget _skipPill(BuildContext context, {required double opacity}) {
    return IgnorePointer(
      ignoring: opacity == 0,
      child: AnimatedOpacity(
        duration: VideoPlayerInteraction.fadeDuration,
        opacity: opacity,
        child: Opacity(
          opacity: 0.7,
          child: DarkUnyoButton(
            text: skipLabel,
            color: ColorScheme.of(context).primary,
            width: 90.w,
            maxWidth: 110,
            maxHeight: 45,
            onPressed: onSkip,
          ),
        ),
      ),
    );
  }
}

class _UpNextCard extends StatelessWidget {
  const _UpNextCard({
    required this.seriesTitle,
    required this.episodeLabel,
    required this.thumbnailUrl,
    required this.onWatchNow,
    required this.onDismiss,
  });

  final String seriesTitle;
  final String episodeLabel;
  final String thumbnailUrl;
  final VoidCallback onWatchNow;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UnyoVideoBottomStatus.cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // No thumbnail data means no box at all — never a broken placeholder.
          if (thumbnailUrl.isNotEmpty) ...[
            UnyoNetworkImage(url: thumbnailUrl, width: 96, height: 54, borderRadius: 8),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next: $seriesTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ColorScheme.of(context).tertiary,
                  ),
                ),
                if (episodeLabel.isNotEmpty)
                  Text(
                    episodeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CardAction(
            label: 'Dismiss',
            icon: Icons.close_rounded,
            filled: false,
            onPressed: onDismiss,
          ),
          const SizedBox(width: 6),
          _CardAction(
            label: 'Watch now',
            icon: Icons.play_arrow_rounded,
            filled: true,
            onPressed: onWatchNow,
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color accent = ColorScheme.of(context).primary;
    return Material(
      color: Colors.transparent,
      child: UnyoInkWell(
        onTap: onPressed,
        hoverColor: Colors.white10,
        splashColor: Colors.white12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: filled ? null : Border.all(color: Colors.white38),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : Colors.white70),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

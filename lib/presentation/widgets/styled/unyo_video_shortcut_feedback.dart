// External dependencies
import 'dart:async';

import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';

/// Transient YouTube-style indicator for the keyboard shortcuts that show one
/// (volume, playback speed, seek delta). Reuses the player's existing dark
/// overlay styling — no new design system.
class UnyoVideoShortcutFeedback extends StatefulWidget {
  const UnyoVideoShortcutFeedback({super.key, required this.feedback});

  final ValueNotifier<VideoShortcutFeedback?> feedback;

  @override
  State<UnyoVideoShortcutFeedback> createState() => _UnyoVideoShortcutFeedbackState();
}

class _UnyoVideoShortcutFeedbackState extends State<UnyoVideoShortcutFeedback> {
  static const Duration _visibleFor = Duration(milliseconds: 900);

  VideoShortcutFeedback? _current;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.feedback.addListener(_onFeedback);
  }

  @override
  void didUpdateWidget(UnyoVideoShortcutFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedback != widget.feedback) {
      oldWidget.feedback.removeListener(_onFeedback);
      widget.feedback.addListener(_onFeedback);
    }
  }

  @override
  void dispose() {
    widget.feedback.removeListener(_onFeedback);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onFeedback() {
    final value = widget.feedback.value;
    if (value == null) return;
    _hideTimer?.cancel();
    setState(() => _current = value);
    _hideTimer = Timer(_visibleFor, () {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.75),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: current == null ? 0 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              current?.text ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// External dependencies
import 'package:flutter/widgets.dart';

// Internal dependencies
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';
import 'package:unyo/presentation/shortcuts/video_shortcuts.dart';

/// Scopes the video key table to the video screen.
///
/// Focus discipline (WP #98):
/// - the scope only exists inside `VideoScreen`, so keys do nothing elsewhere;
/// - the [Focus] node is autofocused, which puts the video screen in the key
///   event chain only while the video route is the active one;
/// - a modal route above the video screen (any dialog, including the episode
///   drawer) or a focused text field [EditableText] short-circuits every intent;
/// - [enabled] is false while the loading/error overlay is up.
class VideoShortcutScope extends StatefulWidget {
  const VideoShortcutScope({
    super.key,
    required this.handler,
    required this.child,
    this.enabled = true,
  });

  final VideoShortcutHandler handler;
  final Widget child;
  final bool enabled;

  @override
  State<VideoShortcutScope> createState() => _VideoShortcutScopeState();
}

class _VideoShortcutScopeState extends State<VideoShortcutScope> {
  late Map<ShortcutActivator, Intent> _shortcuts;
  late Map<Type, Action<Intent>> _actions;

  @override
  void initState() {
    super.initState();
    _shortcuts = videoShortcutMap();
    _actions = videoShortcutActions((intent) {
      if (!_canHandle()) return false;
      return widget.handler.handle(intent);
    });
  }

  @override
  void didUpdateWidget(VideoShortcutScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handler != widget.handler) {
      _actions = videoShortcutActions((intent) {
        if (!_canHandle()) return false;
        return widget.handler.handle(intent);
      });
    }
  }

  /// True only when this screen owns the keyboard right now.
  bool _canHandle() {
    if (!mounted || !widget.enabled) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    // No focus inside the video screen means the key event cannot reach this
    // Shortcuts widget anyway; the text-field check is the extra guard needed
    // because typing does propagate to ancestor Shortcuts.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null || !focused.mounted) return true;
    return !_isTextInputFocused(focused);
  }

  /// Typing in a text field must never trigger a player shortcut.
  ///
  /// `TextField` puts its [Focus] *above* the `EditableText`, so the check has
  /// to look down the focused element's subtree as well as up its ancestors.
  static bool _isTextInputFocused(BuildContext focused) {
    if (focused.widget is EditableText) return true;
    if (focused.findAncestorWidgetOfExactType<EditableText>() != null) return true;
    if (focused is! Element) return false;
    var found = false;
    void visit(Element element) {
      if (found) return;
      if (element.widget is EditableText) {
        found = true;
        return;
      }
      element.visitChildren(visit);
    }

    focused.visitChildren(visit);
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: Focus(autofocus: true, child: widget.child),
      ),
    );
  }
}

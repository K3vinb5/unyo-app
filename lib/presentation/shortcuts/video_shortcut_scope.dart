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
/// - [enabled] is false while the loading/error overlay is up;
/// - the screen takes the keyboard back when it is left with nobody holding it
///   (WP #119, defect #119) — see [_VideoShortcutScopeState._reclaimKeyboard].
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
  late final Map<ShortcutActivator, Intent> _shortcuts;
  late Map<Type, Action<Intent>> _actions;

  /// Owned here (instead of an implicit node) so focus loss can be repaired.
  final FocusNode _focusNode = FocusNode(debugLabel: 'video shortcut scope');

  @override
  void initState() {
    super.initState();
    _shortcuts = videoShortcutMap();
    _actions = videoShortcutActions((intent) {
      if (!_canHandle()) return false;
      return widget.handler.handle(intent);
    });
    FocusManager.instance.addListener(_reclaimKeyboard);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_reclaimKeyboard);
    _focusNode.dispose();
    super.dispose();
  }

  /// Takes the keyboard back whenever nothing in this screen — and nothing
  /// above it — owns it.
  ///
  /// Autofocus fires once per node, so before this anything that moved the
  /// primary focus away from the video screen took the shortcuts with it for
  /// the rest of the route's life: a click that focused a control, a control
  /// that was then unmounted by a rebuild, or any path that handed the focus
  /// back to the route/root scope (measured in the WP #116 proof,
  /// `research/unyo-116-video-shortcuts-proof/logs/player-states.txt`: after a
  /// few pointer clicks `ext.unyo.focus` reported `debugLabel: "Root Focus
  /// Scope", inScope: false` and Space/K were dropped from then on).
  ///
  /// "Orphaned" is precise: the primary focus sits on an element that
  /// *encloses* this screen (the route's modal scope, the root scope) or on
  /// nothing at all. A dialog, the episode drawer, another route or a focused
  /// text field lives in a different subtree and keeps what it took, and the
  /// loading/error overlay ([enabled] == false) or a non-current route is never
  /// fought.
  void _reclaimKeyboard() {
    if (!mounted || !widget.enabled) return;
    final FocusManager manager = FocusManager.instance;
    final BuildContext? primary = manager.primaryFocus?.context;
    if (primary != null && !_isAncestorOfScreen(primary)) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    if (_focusNode.hasPrimaryFocus) return;
    _focusNode.requestFocus();
  }

  /// True when [candidate] is an ancestor of this screen in the element tree.
  bool _isAncestorOfScreen(BuildContext candidate) {
    if (candidate == context) return true;
    var found = false;
    context.visitAncestorElements((Element element) {
      if (element == candidate) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
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
        child: Focus(focusNode: _focusNode, autofocus: true, child: widget.child),
      ),
    );
  }
}

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';

abstract class AppEffect {}

// Navigation Effects
class ReplaceRouteEffect extends AppEffect {
  final String routeName;
  final Object? arguments;

  ReplaceRouteEffect(this.routeName, {this.arguments});
}

class PushRouteEffect extends AppEffect {
  final String routeName;
  final Object? arguments;

  PushRouteEffect(this.routeName, {this.arguments});
}

class NavigateRouteEffect extends AppEffect {
  final String routeName;
  final Object? arguments;

  NavigateRouteEffect(this.routeName, {this.arguments});
}

class ChangeTabRouteEffect extends AppEffect {
  final int routeIndex;
  final BuildContext context;
  ChangeTabRouteEffect(this.routeIndex, this.context);
}

// Dialogs Effects
class ShowWidgetDialogEffect extends AppEffect {
  final Widget dialog;

  ShowWidgetDialogEffect(this.dialog);
}

class ShowDrawerDialogEffect extends AppEffect {
  final Widget drawerDialog;
  final Color backgroundColor;
  final AxisDirection startPosition;

  ShowDrawerDialogEffect(this.drawerDialog, this.backgroundColor, this.startPosition);
}

class CloseDialogEffect extends AppEffect {
  BuildContext context;

  CloseDialogEffect(this.context);
}

// Feedback Effects

/// A banner notification expressed as translation **keys plus arguments**.
///
/// Cubits emit keys, never user-facing English: `lib/application` has no
/// `BuildContext` and no `Locale`, so the English (or translated) sentence only
/// exists at the presentation boundary, inside
/// `AppEffectHandler._handleShowSnackbarEffect`, which resolves these keys with
/// `context.tr(...)`.
///
/// Values that are not ours to translate (extension/provider names, media
/// titles, device names) travel in [titleArgs] / [messageArgs] as named
/// placeholders, so one key covers every provider.
class ShowSnackbarEffect extends AppEffect {
  /// Translation key for the banner title. Empty renders no title.
  final String titleKey;

  /// Named placeholders for [titleKey].
  final Map<String, String>? titleArgs;

  /// Translation key for the banner body. `null` renders no body — an absent
  /// message stays absent instead of minting an empty key.
  final String? messageKey;

  /// Named placeholders for [messageKey].
  final Map<String, String>? messageArgs;

  final ContentType contentType;

  ShowSnackbarEffect(
    this.titleKey, {
    this.titleArgs,
    this.messageKey,
    this.messageArgs,
    required this.contentType,
  });
}
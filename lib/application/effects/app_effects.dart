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
class ShowSnackbarEffect extends AppEffect {
  final String title;
  final String message;
  final ContentType contentType;

  /// Optional call to action, rendered as a button inside the banner.
  final String? actionLabel;
  final void Function()? onAction;

  /// How long the banner stays on screen before hiding itself. Defaults to the
  /// handler's per-contentType duration when null.
  final Duration? duration;

  ShowSnackbarEffect(
    this.title, {
    required this.message,
    required this.contentType,
    this.actionLabel,
    this.onAction,
    this.duration,
  });
}
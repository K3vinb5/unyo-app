// External dependencies
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';

class AppEffectHandler {
  final Logger _logger = sl<Logger>();

  /// The banner currently on screen. The auto-hide timer lives inside
  /// [_BannerLifetime], i.e. the lifetime belongs to the notification, not to
  /// the handler: a replacing notification cancels the previous lifetime and
  /// starts its own, so nothing renews a banner that is already showing.
  _BannerLifetime? _visibleBanner;

  late BuildContext rootContext;

  /// Effects are kept on the state snapshot. When a cubit emits again before
  /// the BlocListener has drained them (e.g. `addEffect` followed by a
  /// `copyWith` emit), consecutive states carry the SAME effect instances and
  /// every snapshot would run them again — double dialogs that then fight over
  /// a single `Navigator.pop`, double snackbars. Each instance is one-shot, so
  /// remember what already ran. An [Expando] keeps it weak: effects are
  /// collected along with their states.
  final Expando<bool> _handledEffects = Expando<bool>('AppEffectHandler.handled');

  AppEffectHandler();

  void attachRootContext(BuildContext context) {
    rootContext = context;
  }

  void handleEffects(
    BuildContext context,
    List<AppEffect> effects,
    void Function() clearAppEffects,
  ) {
    for (var effect in effects) {
      if (_handledEffects[effect] ?? false) continue;
      _handledEffects[effect] = true;
      handle(effect, context);
    }
    clearAppEffects();
  }

  void handle(AppEffect effect, BuildContext context) {
    switch (effect) {
      case ShowSnackbarEffect showSnackBarEffect:
        _handleShowSnackbarEffect(context, showSnackBarEffect);
      case ReplaceRouteEffect replaceRouteEffect:
        _handleReplaceRouteEffect(replaceRouteEffect, context);
      case NavigateRouteEffect navigateRouteEffect:
        _handleNavigateRouteEffect(navigateRouteEffect, context);
      case PushRouteEffect pushRouteEffect:
        _handlePushRouteEffect(pushRouteEffect, context);
      case ShowWidgetDialogEffect showWidgetDialogEffect:
        _handleShowWidgetDialogEffect(showWidgetDialogEffect, context);
      case ShowDrawerDialogEffect showDrawerDialogEffect:
        _handleShowDrawerDialogEffect(showDrawerDialogEffect, context);
      case CloseDialogEffect closeDialogEffect:
        _handleCloseDialogEffect(closeDialogEffect, closeDialogEffect.context);
      case ChangeTabRouteEffect changeTabRouteEffect:
        _handleChangeTabRouteEffect(changeTabRouteEffect);
      default:
        _handleUnkownEffect(effect);
    }
  }

  void _handleShowWidgetDialogEffect(
    ShowWidgetDialogEffect effect,
    BuildContext context,
  ) {
    _logger.d("Handling ShowWidgetDialogEffect");
    showDialog(context: context, builder: (dialogContext) => effect.dialog);
  }

  void _handleShowDrawerDialogEffect(
    ShowDrawerDialogEffect effect,
    BuildContext context,
  ) {
    _logger.d("Handling ShowDrawerDialogEffect");
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: effect.backgroundColor,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder:(context, animation, secondaryAnimation) => effect.drawerDialog,
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(
                  effect.startPosition == AxisDirection.right ? 1 : (effect.startPosition == AxisDirection.left ? -1 : 0),
                  effect.startPosition == AxisDirection.up ? -1 : (effect.startPosition == AxisDirection.down ? 1 : 0)
              ),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
    );
  }

  void _handleCloseDialogEffect(
    CloseDialogEffect effect,
    BuildContext context,
  ) {
    _logger.d("Handling CloseDialogEffect");
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _logger.w("No Dialog found");
    }
  }

  void _handleShowSnackbarEffect(
    BuildContext context,
    ShowSnackbarEffect effect,
  ) {
    _logger.d("Handling ShowSnackbarEffect");
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final _BannerLifetime lifetime = _BannerLifetime();

    // A replacement notification takes over the screen: stop the previous
    // banner's countdown instead of extending anything it had left.
    _visibleBanner?.cancel();
    _visibleBanner = lifetime;

    final MaterialBanner snackBar = MaterialBanner(
      elevation: double.maxFinite,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: effect.title,
        message: effect.message,
        contentType: effect.contentType,
        inMaterialBanner: true,
      ),
      // One explicit dismiss control, labelled so it cannot be confused with
      // the decorative failure badge on the left of the ribbon (that glyph is
      // package-owned and has no gesture behind it).
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>("notification-dismiss"),
          onPressed: () {
            lifetime.cancel();
            if (identical(_visibleBanner, lifetime)) {
              _visibleBanner = null;
            }
            messenger.hideCurrentMaterialBanner();
          },
          child: const Text("Dismiss"),
        ),
      ],
    );

    messenger.hideCurrentMaterialBanner();
    final ScaffoldFeatureController<MaterialBanner, MaterialBannerClosedReason> controller =
        messenger.showMaterialBanner(snackBar);

    final Duration duration = Duration(seconds: effect.contentType == ContentType.success ? 1 : 3);
    lifetime.schedule(duration, () {
      final bool isCurrent = identical(_visibleBanner, lifetime);
      _logger.d("Auto-hiding notification after ${duration.inSeconds}s (current banner: $isCurrent)");
      if (!isCurrent) return;
      _visibleBanner = null;
      messenger.hideCurrentMaterialBanner();
      // `closed` only completes when the messenger actually removes the
      // banner. If this line never follows the one above, the hide was a
      // no-op (wrong messenger / banner not hosted); if it follows, the
      // auto-hide went through.
      controller.closed.then<void>(
        (MaterialBannerClosedReason reason) {
          _logger.d("Notification auto-hide closed after ${duration.inSeconds}s (reason: ${reason.name})");
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.e("Notification auto-hide failed after ${duration.inSeconds}s", error: error, stackTrace: stackTrace);
        },
      );
    });
  }

  void _handleReplaceRouteEffect(
    ReplaceRouteEffect effect,
    BuildContext context,
  ) {
    _logger.d("Handling ReplaceRouteEffect");
    AutoRouter.of(context).replacePath(
      effect.routeName.replaceFirst("/", ""),
      onFailure: _handleRouteFailure,
    );
  }

  void _handleNavigateRouteEffect(
    NavigateRouteEffect effect,
    BuildContext context,
  ) {
    _logger.d("Handling NavigateRouteEffect");
    AutoRouter.of(context).navigatePath(
      effect.routeName.replaceFirst("/", ""),
      onFailure: _handleRouteFailure,
    );
  }

  void _handlePushRouteEffect(PushRouteEffect effect, BuildContext context) {
    _logger.d("Handling PushRouteEffect");
    AutoRouter.of(context).pushPath(
      effect.routeName.replaceFirst("/", ""),
      onFailure: _handleRouteFailure,
    );
  }

  void _handleChangeTabRouteEffect(ChangeTabRouteEffect effect) {
    _logger.d("Handling ChangeTabRouteEffect");
    AutoTabsRouter.of(effect.context).setActiveIndex(effect.routeIndex);
  }

  void _handleRouteFailure(NavigationFailure failure) {
    _logger.e("Navigation failure: ${failure.toString()}, type: ${failure.runtimeType}");
  }

  void _handleUnkownEffect(AppEffect effect) {
    _logger.e("Unimplemented Effect Handler for effect: $effect");
  }
}

/// One notification's auto-hide countdown.
///
/// The timer belongs to the notification, not to [AppEffectHandler]: showing a
/// new notification cancels the previous lifetime and starts a fresh one, so a
/// replacement never renews the lifetime of the banner it replaced.
class _BannerLifetime {
  Timer? _timer;

  void schedule(Duration duration, void Function() onExpired) {
    _timer?.cancel();
    _timer = Timer(duration, onExpired);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

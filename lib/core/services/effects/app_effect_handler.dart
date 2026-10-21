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
  final _logger = sl<Logger>();
  Timer timer = Timer(Duration.zero, () {});
  late BuildContext rootContext;

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
    final snackBar = MaterialBanner(
      elevation: double.maxFinite,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: effect.title,
        message: effect.message,
        contentType: effect.contentType,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    timer.cancel();
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(snackBar);
    timer = Timer(Duration(seconds: effect.contentType == ContentType.success ? 1 : 3), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
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

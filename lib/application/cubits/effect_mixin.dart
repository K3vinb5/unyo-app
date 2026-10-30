// External dependencies
import 'package:auto_route/auto_route.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
// Internal dependencies
import 'package:unyo/application/cubits/error_copy_mapper.dart';
import 'package:unyo/application/effects/app_effects.dart';

mixin EffectMixin<State> on Cubit<State> {
  State copyStateWithEffects(State state, List<AppEffect> effects);
  Logger get logger;
  static const Map<String, int> _routesIndexMapper = {
    "/home" : 0,
    "/anime" : 1,
    "/manga" : 2,
    "/extensions" : 3,
    "/settings" : 4,
    "/animesearch": 5,
    "/mangasearch": 6
  };

  void addEffect(AppEffect effect) {
    if (isClosed) {
      logger.d("Skipping AppEffect on a closed cubit: $effect");
      return;
    }
    logger.d("Adding AppEffect: $effect");
    final current = state;
    final newEffects = [..._currentEffects, effect];
    emit(copyStateWithEffects(current, newEffects));
  }

  void clearEffects() {
    logger.d("Clearing all effects");
    if (isClosed) return;
    emit(copyStateWithEffects(state, []));
  }

  List<AppEffect> get _currentEffects {
    if (state is HasEffects) {
      return (state as HasEffects).stateEffects;
    }
    throw StateError('Cubit/Bloc State must implement HasEffects');
  }

  void showWidgetDialogEffect({required Widget dialog}) {
    logger.i("ShowWidgetDialog with dialog: $dialog");
    addEffect(ShowWidgetDialogEffect(dialog));
  }

  void showDrawerDialogEffect({required Widget drawerDialog, required Color backgroundColor, required AxisDirection startPosition}) {
    logger.i("ShowDrawerDialog with dialog: $drawerDialog and startPosition: $startPosition");
    addEffect(ShowDrawerDialogEffect(drawerDialog, backgroundColor, startPosition));
  }

  void closeDialogEffect(BuildContext context) {
    logger.i("CloseDialog attempted");
    addEffect(CloseDialogEffect(context));
  }

  void showSnackBarEffect(String title, {required String message, required ContentType contentType}) {
    logger.i("ShowSnackbar with message: $message");
    addEffect(ShowSnackbarEffect(title, message: message, contentType: contentType));
  }

  void replaceRouteEffect({required String path}) {
    logger.i("ReplaceRoute with path: $path");
    addEffect(ReplaceRouteEffect(path));
  }

  void navigateRouteEffect({required String path}) {
    logger.i("NavigateRoute with path: $path");
    addEffect(NavigateRouteEffect(path));
  }

  void pushRouteEffect({required String path}) {
    logger.i("PushRoute with path: $path");
    addEffect(PushRouteEffect(path));
  }

  void popRouteEffect(BuildContext context) {
    logger.i("PopRoute attempted");
    AutoRouter.of(context).pop();
  }

  void changeRouteTabEffect( BuildContext context, {required String path}) {
    if (!_routesIndexMapper.containsKey(path)) {
      logger.e("Route with path $path is not in AutoTabsRouter, therefore not allowed");
      return;
    }
    logger.i("ChangeRouteTab with path: $path");
    addEffect(ChangeTabRouteEffect(_routesIndexMapper[path]!, context));
  }

  // Handle errors and others

  /// Reports a failure to the user.
  ///
  /// [message] is developer detail and stays in the log, together with
  /// [stackTrace] and [responseBody]. The banner only ever gets the classified
  /// copy from [ErrorCopyMapper]: no exception class names, no `Bad state:`
  /// text, no stack fragments and no dangling separators.
  void handleError(String message, {ContentType contentType = ContentType.failure, StackTrace? stackTrace, String? responseBody}) {
    final String detail = responseBody == null ? message : "$message [$responseBody]";
    logger.e(detail, stackTrace: stackTrace);
    final ErrorCopy copy = ErrorCopyMapper.classify(message: message, responseBody: responseBody);
    showSnackBarEffect(
      copy.title,
      message: copy.message,
      contentType: contentType,
    );
  }
}

abstract class HasEffects {
  List<AppEffect> get stateEffects;
}

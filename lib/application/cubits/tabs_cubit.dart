import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/tabs_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/selected_menu_option.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/drawers/user_options_drawer.dart' show UserOptionsDrawer;

class TabsCubit extends Cubit<TabsState>
    with EffectMixin<TabsState> {
  final ThemeService _themeService;
  final UserNotifier _loggedUserNotifier;
  final MenuBarNotifier _menuBarNotifier;
  final Logger _logger = sl<Logger>();
  late StreamSubscription<User> _newLoggedUserSubscription;
  late StreamSubscription<bool> _showMenuBarSubscription;

  TabsCubit(
      this._themeService,
      this._loggedUserNotifier,
      this._menuBarNotifier,) : super(
    TabsState(
      selectedMenuOption: SelectedMenuOption.home,
      showMenuBar: false,
      showTabView: false,
      loggedUser: UserModel.empty(),
    ),
  ) {
    _init();
  }

  @override
  TabsState copyStateWithEffects(TabsState state,
      List<AppEffect> effects,) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  void _init() {
    _newLoggedUserSubscription = _loggedUserNotifier.userStream.listen((user) {
      if (user == UserModel.empty()) {
        return;
      }
      emit(state.copyWith(loggedUser: user));
    });
    _showMenuBarSubscription = _menuBarNotifier.menuBarStream.listen((showMenuBar,) {
      emit(state.copyWith(showMenuBar: showMenuBar));
    });
  }

  @override
  Future<void> close() {
    _newLoggedUserSubscription.cancel();
    _showMenuBarSubscription.cancel();
    return super.close();
  }

  void logoutUser() {
    _logger.i("Logging out user: ${state.loggedUser.name}");
    _menuBarNotifier.showMenuBar(false);
    _themeService.updateThemeFromColors(
      loggedUser: null,
      useWallpaperAsThemeColor: null,
      primary: _themeService.defaultPrimaryColor,
      secondary: _themeService.defaultSecondaryColor,
      tertiary: _themeService.defaultTertiaryColor,
    );
    replaceRouteEffect(path: "/login");
  }

  void selectMenuOption(SelectedMenuOption option, BuildContext context) {
    _logger.i("Selected menu option: $option");
    switch (option) {
      case SelectedMenuOption.home:
        changeRouteTabEffect(path: "/home", context);
      case SelectedMenuOption.anime:
        changeRouteTabEffect(path: "/anime", context);
      case SelectedMenuOption.manga:
        changeRouteTabEffect(path: "/manga", context);
      case SelectedMenuOption.extensions:
        changeRouteTabEffect(path: "/extensions", context);
      case SelectedMenuOption.settings:
        changeRouteTabEffect(path: "/settings", context);
    }
    emit(state.copyWith(selectedMenuOption: option));
  }

  void showUserOptionsDrawer() {
    showDrawerDialogEffect(
        drawerDialog: UserOptionsDrawer(
            cubit: this,
            loggedUser: state.loggedUser
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        startPosition: AxisDirection.down
    );
  }
}

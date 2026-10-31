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
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/update_available_dialog.dart';
import 'package:unyo/presentation/dialogs/user_profile_dialog.dart';
import 'package:unyo/presentation/drawers/user_options_drawer.dart' show UserOptionsDrawer;

class TabsCubit extends Cubit<TabsState>
    with EffectMixin<TabsState> {
  final ThemeService _themeService;
  final UserNotifier _loggedUserNotifier;
  final MenuBarNotifier _menuBarNotifier;
  final UpdateCheckerService _updateCheckerService;
  final AppVersionProvider _versionProvider;
  final Logger _logger = sl<Logger>();
  late StreamSubscription<User> _newLoggedUserSubscription;
  late StreamSubscription<bool> _showMenuBarSubscription;

  /// Guards "once per process launch": the shell is built once per logged-in
  /// session, so a repeat [checkForUpdate] within the same launch is a no-op.
  /// Nothing is persisted — the next launch asks again, which is the intended
  /// nagging policy ("every start while outdated").
  bool _updateCheckStarted = false;

  TabsCubit(
      this._themeService,
      this._loggedUserNotifier,
      this._menuBarNotifier,
      this._updateCheckerService,
      this._versionProvider,) : super(
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
    // Best-effort: fired once from the shell's init, never awaited and never
    // allowed to block or break startup.
    unawaited(checkForUpdate());
  }

  /// Asks GitHub whether a newer release exists and, when it does, opens the
  /// release-notes dialog. Every failure path is silent apart from a log line.
  Future<void> checkForUpdate() async {
    if (_updateCheckStarted) {
      _logger.d("Update check already ran in this process launch, skipping");
      return;
    }
    _updateCheckStarted = true;

    final String? currentVersion = await _versionProvider.currentVersion();
    if (isClosed) return;
    if (currentVersion == null) {
      _logger.w("Cannot check for updates: the current app version is unavailable");
      return;
    }

    final UpdateCheckResult result = await _updateCheckerService.checkForUpdate(currentVersion);
    if (isClosed) return;
    switch (result) {
      case UpToDate():
        _logger.d("App is up to date (running $currentVersion)");
      case UpdateCheckFailed(:final reason):
        _logger.w("Update check failed: $reason");
      case UpdateAvailable(:final release, :final latestVersion):
        showWidgetDialogEffect(
          dialog: UpdateAvailableDialog(
            release: release,
            latestVersion: latestVersion,
            onOpenReleasePage: () =>
                ReleasePageLauncher.openPage(release.htmlUrl),
          ),
        );
    }
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

  /// Opens the profile card for the signed-in account. It reads the same
  /// [TabsState.loggedUser] the drawer was built from and carries no provider
  /// branch: the dialog drops the slots the account does not fill.
  void openUserProfileDialog() {
    _logger.i("Opening the user profile dialog for ${state.loggedUser.name}");
    showWidgetDialogEffect(dialog: UserProfileDialog(user: state.loggedUser));
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

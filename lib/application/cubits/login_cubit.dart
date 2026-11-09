// External dependencies
import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/states/login_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/dto/anilist/auth_token_dto.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/models.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/account_creation_dialog.dart';
import 'package:unyo/presentation/dialogs/coming_soon_dialog.dart';

class LoginCubit extends Cubit<LoginState> with EffectMixin<LoginState> {
  // Repositories
  final UserRepositoryLocal _userRepositoryLocal;
  final UserRepositoryAnilist _userRepositoryAnilist;
  final UserRepositoryShikimori _userRepositoryShikimori;
  final Logger _logger = sl<Logger>();

  // Notifiers / Subscriptions
  final UserNotifier _loggedUserNotifier;
  final UserNotifier _newUserNotifier;
  late StreamSubscription<User> _newUserCreatedSubscription;

  // Services
  final ColorImageService _colorImageService;
  final ThemeService _themeService;

  LoginCubit(
    this._userRepositoryLocal,
    this._loggedUserNotifier,
    this._newUserNotifier,
    this._userRepositoryAnilist,
    this._userRepositoryShikimori,
    this._colorImageService,
    this._themeService,
  ) : super(
        const LoginState(
          availableUsers: [],
          selectedLoginCard: LoginCardType.anilist,
          isLoading: true,
        ),
      ) {
    _init();
  }

  @override
  LoginState copyStateWithEffects(LoginState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  @override
  Future<void> close() {
    _newUserCreatedSubscription.cancel();
    return super.close();
  }

  void _init() {
    _newUserCreatedSubscription = _newUserNotifier.userStream.listen((
        newLoggedUser,
        ) {
      // A cleared notifier (WP #151: the account was unlinked) must not become
      // a blank tile in the picker.
      if (newLoggedUser == UserModel.empty()) {
        return;
      }
      //In case of user update!!
      emit(
        state.copyWith(
          availableUsers: [
            ...state.availableUsers.where(
                  (user) => user.name != newLoggedUser.name,
            ),
          ],
        ),
      );
      emit(
        state.copyWith(
          availableUsers: [...state.availableUsers, newLoggedUser],
        ),
      ); // Update state on new data
    });
  }

  void initiateAccountCreation(BuildContext context) async {
    // The dialog itself is presentational (WP #111); this is the only place it
    // is wired to the cubit.
    showWidgetDialogEffect(
      dialog: BlocProvider.value(
        value: this,
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (dialogContext, state) => AccountCreationDialog(
            selectedType: state.selectedLoginCard,
            onSelect: (LoginCardType type) =>
                dialogContext.read<LoginCubit>().selectLoginType(type),
            onCancel: () =>
                dialogContext.read<LoginCubit>().closeDialogEffect(dialogContext),
            onConfirm: () =>
                dialogContext.read<LoginCubit>().attemptToCreateUser(dialogContext),
          ),
        ),
      ),
    );
  }

  void selectLoginType(LoginCardType type) async {
    if (state.selectedLoginCard == type) return;
    _logger.d("Login type selected: $type");
    emit(state.copyWith(selectedLoginCard: type));
  }

  Future<void> loginUser(User user, BuildContext context) async {
    try {
      switch (user) {
        case AnilistUserModel anilistUserModel:
          _logger.i("Logging in Anilist User: ${anilistUserModel.name}");
          await _loginAnilistUser(anilistUserModel);
        case ShikimoriUserModel shikimoriUserModel:
          _logger.i("Logging in Shikimori User: ${shikimoriUserModel.name}");
          await _loginShikimoriUser(shikimoriUserModel);
        case LocalUserModel localUserModel:
          _logger.i("Logging in Local User: ${localUserModel.name}");
        default:
          handleError(
            "Unsupported user type for login: ${user.runtimeType}",
            contentType: ContentType.warning,
          );
      }
      // Init User Extensions
      // _loadUserExtensions();
      setUsersTheme(user);
      replaceRouteEffect(path: "/tabs");
      // close();
    } catch (e, stackTrace) {
      handleError("Error logging in user: $e", stackTrace: stackTrace);
      return;
    }
  }

  Future<void> attemptToCreateUser(BuildContext context) async {
    switch (state.selectedLoginCard) {
      case LoginCardType.anilist:
        _logger.i("Attempting to create Anilist User");
        await _createAnilistUser();
      case LoginCardType.shikimori:
        _logger.i("Attempting to create Shikimori User");
        await _createShikimoriUser();
      case LoginCardType.mal:
        // Not implemented yet (WP #148): say so instead of closing the dialog
        // and leaving the user staring at the login screen again.
        _logger.i("Attempting to create MyAnimeList User");
        ComingSoonDialog.show(context, ComingSoonFeature.malAccounts);
        return;
      case LoginCardType.local:
        _logger.i("Attempting to create Local User");
        ComingSoonDialog.show(context, ComingSoonFeature.localAccounts);
        return;
    }
    if (context.mounted) closeDialogEffect(context);
  }

  Future<void> fetchAllUsers() async {
    _logger.i("Fetching all logged in users");
    try {
      List<User> usersAvailableLocal =
          (await _userRepositoryLocal.fetchAllLoggedInUsers()).cast<User>();
      List<User> usersAvailableAnilist =
          (await _userRepositoryAnilist.fetchAllLoggedInUsers()).cast<User>();
      List<User> usersAvailableShikimori =
          (await _userRepositoryShikimori.fetchAllLoggedInUsers()).cast<User>();
      _updateAvailableUsers(usersAvailableAnilist + usersAvailableShikimori + usersAvailableLocal);
    } finally {
      // Settles the avatar skeletons even when a repository fails.
      if (!isClosed && state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  void setUsersTheme(User user) async {
    List<Color> wallpaperColors = [];
    if (user.settings.useWallpaperAsThemeColor) {
      switch (user) {
        case AnilistUserModel anilistUserModel:
          _logger.d("Getting anilist user's theme");
          wallpaperColors = await _colorImageService
              .getColorsFromPalleteGenerator(
            NetworkImage(anilistUserModel.bannerImage),
          );
        case ShikimoriUserModel _:
          // `currentUser` carries no banner, so there is no wallpaper to sample.
          _logger.d("Getting shikimori user's theme");
        case LocalUserModel _:
          _logger.d("Getting local user's theme");
      }
      _themeService.updateThemeFromColors(
        loggedUser: user,
        useWallpaperAsThemeColor: true,
        primary: wallpaperColors[0],
        secondary: wallpaperColors[1],
        tertiary: wallpaperColors[2],
      );
    } else {
      _themeService.updateThemeFromColors(
        loggedUser: user,
        useWallpaperAsThemeColor: false,
        primary: user.settings.themeColor,
      );
    }
  }

  void _updateAvailableUsers(List<User> users) {
    emit(state.copyWith(availableUsers: users));
  }

  Future<void> _loginAnilistUser(AnilistUserModel user) async {
    DateTime dateTime = JwtDecoder.getExpirationDate(user.accessToken);
    if (dateTime.isBefore(DateTime.now())) {
      _logger.w("Anilist User token is expired, getting new accessToken");
      try {
        ApiResponse<AuthTokenEntity> authToken = await _userRepositoryAnilist
            .getAuthToken(user.accessCode);
        User updatedUser = user.copyWith(
          accessToken: authToken.data.accessToken,
          refreshToken: authToken.data.refreshToken,
        );
        _loggedUserNotifier.updateUser(updatedUser);
        return;
      } catch (e, stackTrace) {
        handleError(
          "Error refreshing user expired token: $e",
          stackTrace: stackTrace,
        );
        return;
      }
    }
    _loggedUserNotifier.updateUser(user);
  }

  /// A Shikimori access token lives 1 day and there is no JWT to inspect, so the
  /// stored expiry decides: an expired pair is rotated here (from the stored
  /// refresh token) and re-persisted before the session starts.
  Future<void> _loginShikimoriUser(ShikimoriUserModel user) async {
    try {
      final ShikimoriUserModel fresh = await _userRepositoryShikimori.ensureFreshAccessToken(user);
      _loggedUserNotifier.updateUser(fresh);
    } catch (e, stackTrace) {
      handleError(
        "Error refreshing the Shikimori token: $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _createShikimoriUser() async {
    try {
      await _userRepositoryShikimori.attemptCreateUser();
    } catch (e, stackTrace) {
      handleError("Error creating Shikimori user $e", stackTrace: stackTrace);
    }
  }

  Future<void> _createAnilistUser() async {
    try {
      await _userRepositoryAnilist.attemptCreateUser();
    } catch (e, stackTrace) {
      handleError("Error creating user $e", stackTrace: stackTrace);
    }
  }
}

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

class LoginCubit extends Cubit<LoginState> with EffectMixin<LoginState> {
  // Repositories
  final UserRepositoryLocal _userRepositoryLocal;
  final UserRepositoryAnilist _userRepositoryAnilist;
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
    showWidgetDialogEffect(dialog: AccountCreationDialog(context, cubit: this));
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
      case LoginCardType.mal:
        _logger.i("Attempting to create MyAnimeList User");
      case LoginCardType.local:
        _logger.i("Attempting to create Local User");
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
      _updateAvailableUsers(usersAvailableAnilist + usersAvailableLocal);
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
        case LocalUserModel localUserModel:
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

  Future<void> _createAnilistUser() async {
    try {
      await _userRepositoryAnilist.attemptCreateUser();
    } catch (e, stackTrace) {
      handleError("Error creating user $e", stackTrace: stackTrace);
    }
  }
}

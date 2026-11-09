// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// Where the app lands once an account is gone (WP #151).
///
/// This app has a single pre-session route: `"/login"` renders the
/// "Who's watching?" picker while accounts remain and the add-account card when
/// none do. [destinationFor] keeps that rule named and testable instead of
/// leaving it implicit in an empty list, and the cubit logs the verdict so a
/// driven run can show which branch was taken.
enum UnlinkDestination {
  /// Other accounts remain: `/login` renders the picker with them.
  picker,

  /// No accounts remain: `/login` renders the login card alone.
  login;

  /// Both branches share the one pre-session route; what differs is what the
  /// screen finds in the user boxes.
  String get route => '/login';

  static UnlinkDestination destinationFor(int remainingUsers) =>
      remainingUsers == 0 ? login : picker;
}

/// What [AccountUnlinkService.unlink] left behind.
class AccountUnlinkResult {
  const AccountUnlinkResult({
    required this.remainingUsers,
    required this.destination,
  });

  /// Every account still stored on this device, read back from the provider
  /// boxes after the removal.
  final List<User> remainingUsers;

  final UnlinkDestination destination;
}

/// Removes one account from the device and everything derived from it.
///
/// A removal that leaves state behind resurrects the deleted account (theme,
/// notifier, cached payloads), so the steps are owned here rather than in the
/// cubit: the stored row, both [UserNotifier]s, the [ThemeService] fallback and
/// the [ResponseCacheScope] revision. Every step runs even when an earlier one
/// throws — the session must never continue as a user that is no longer stored —
/// and the first failure is rethrown to the caller after the cleanup.
///
/// The media-id pivot cache (`mediaIdMappings`) is deliberately **not** purged:
/// its rows are keyed by `(service, nativeId)` and hold only the MAL pivot of a
/// *media record* (`IdMapping` carries no account id, name or token), so there
/// is nothing of one account in it to leak into the next. Purging would only
/// force a re-resolution.
class AccountUnlinkService {
  final Logger _logger = sl<Logger>();
  final UserRepositoryAnilist _userRepositoryAnilist;
  final UserRepositoryShikimori _userRepositoryShikimori;
  final UserRepositoryLocal _userRepositoryLocal;
  final UserNotifier _loggedUserNotifier;
  final UserNotifier _newUserNotifier;
  final ThemeService _themeService;
  final ResponseCacheScope _responseCacheScope;

  AccountUnlinkService(
    this._userRepositoryAnilist,
    this._userRepositoryShikimori,
    this._userRepositoryLocal,
    this._loggedUserNotifier,
    this._newUserNotifier,
    this._themeService,
    this._responseCacheScope,
  );

  Future<AccountUnlinkResult> unlink(User user) async {
    _logger.i("Unlinking account ${user.name}");
    Object? failure;
    StackTrace? failureStackTrace;

    // Keeps the first failure and still runs the remaining steps: a step that
    // throws half way must not leave the notifiers or the theme on a user that
    // is already gone from its box. The caller sees the failure and reports it.
    void captureFailure(String description, Object error, StackTrace stackTrace) {
      _logger.e("Unlink: $description", error: error, stackTrace: stackTrace);
      if (failure != null) return;
      failure = error;
      failureStackTrace = stackTrace;
    }

    try {
      await _removeFromProvider(user);
    } catch (e, stackTrace) {
      captureFailure("could not remove ${user.name} from its provider box", e, stackTrace);
    }

    try {
      _clearNotifiers();
    } catch (e, stackTrace) {
      captureFailure("could not clear the user notifiers", e, stackTrace);
    }

    try {
      _resetTheme();
    } catch (e, stackTrace) {
      captureFailure("could not reset the theme", e, stackTrace);
    }

    try {
      _responseCacheScope.invalidate();
      _logger.d("Unlink: response cache scope invalidated (revision ${_responseCacheScope.revision})");
    } catch (e, stackTrace) {
      captureFailure("could not invalidate the response cache scope", e, stackTrace);
    }

    final List<User> remainingUsers = await _remainingUsers();
    final Object? firstFailure = failure;
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, failureStackTrace ?? StackTrace.current);
    }
    return AccountUnlinkResult(
      remainingUsers: remainingUsers,
      destination: UnlinkDestination.destinationFor(remainingUsers.length),
    );
  }

  /// Dispatches on the model type, not on `settings.userService`: a local
  /// account can carry a provider service in its settings while owning no row
  /// in that provider's box.
  Future<void> _removeFromProvider(User user) async {
    switch (user) {
      case AnilistUserModel _:
        return _userRepositoryAnilist.removeUser(user);
      case ShikimoriUserModel _:
        return _userRepositoryShikimori.removeUser(user);
      case LocalUserModel _:
        return _userRepositoryLocal.removeUser(user);
      default:
        throw StateError("Unsupported user type for removal: ${user.runtimeType}");
    }
  }

  /// Both notifiers must stop pointing at the removed account: the tabs shell
  /// listens to [UserNotifier] for the signed-in user, and the login picker for
  /// newly created ones.
  void _clearNotifiers() {
    _loggedUserNotifier.clear();
    _newUserNotifier.clear();
    _logger.d("Unlink: user notifiers cleared");
  }

  /// Same fallback `logoutUser` applies: the default palette, never the removed
  /// user's colour. `loggedUser: null` keeps the fallback from writing the old
  /// settings back into a box.
  void _resetTheme() {
    _themeService.updateThemeFromColors(
      loggedUser: null,
      useWallpaperAsThemeColor: null,
      primary: _themeService.defaultPrimaryColor,
      secondary: _themeService.defaultSecondaryColor,
      tertiary: _themeService.defaultTertiaryColor,
    );
    _logger.d("Unlink: theme reset to the default palette");
  }

  /// Reads the provider boxes back. A box that cannot be read must not keep the
  /// session alive, so the failure degrades to "no accounts remain" and lands on
  /// the login card.
  Future<List<User>> _remainingUsers() async {
    try {
      final List<User> anilistUsers = await _userRepositoryAnilist.fetchAllLoggedInUsers();
      final List<User> shikimoriUsers = await _userRepositoryShikimori.fetchAllLoggedInUsers();
      final List<User> localUsers = await _userRepositoryLocal.fetchAllLoggedInUsers();
      final List<User> remaining = <User>[...anilistUsers, ...shikimoriUsers, ...localUsers];
      _logger.i("Unlink: ${remaining.length} account(s) remain on this device");
      return remaining;
    } catch (e, stackTrace) {
      _logger.e("Unlink: could not read the remaining accounts", stackTrace: stackTrace);
      return <User>[];
    }
  }
}

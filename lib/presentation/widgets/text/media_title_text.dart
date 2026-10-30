import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/media/media_title_language.dart';
import 'package:unyo/domain/entities/media/title.dart';

/// The one place the app turns a [Title] into the string a card, carousel or
/// detail header shows.
///
/// Every display site calls this instead of reading [Title.userPreferred]
/// directly, so *Settings → Default Media Title Language*
/// (`settings.mediaTitleLanguage`) actually reaches the UI: `Russian` renders
/// Shikimori's `russian` slot, `English` the English one, and an empty slot
/// falls back to [Title.userPreferred] (see [MediaTitleLanguage.resolve]) — a
/// card never renders blank because of a preference.
///
/// The setting lives on the logged-in user, which the logged-user
/// [UserNotifier] already holds, so a display site needs no extra plumbing.
/// Callers that already hold the user can use
/// [MediaTitleLanguage.resolve] with `user.settings.mediaTitleLanguage`.
String displayMediaTitle(Title title) {
  final UserNotifier notifier = sl<UserNotifier>(instanceName: config.loggedUserNotifier);
  return MediaTitleLanguage.resolve(title, notifier.currentUser.settings.mediaTitleLanguage);
}

/// Bundled asset paths (WP #102).
///
/// Everything the UI paints unconditionally ships with the binary: no default
/// avatar or "add user" glyph is downloaded from a third-party host any more, so
/// a cold start performs no image request for them and the first frame is
/// already correct offline.
abstract final class AppAssets {
  /// Placeholder avatar for local accounts / accounts without a picture.
  /// Rendered wherever a persisted `avatarImage` resolves to a bundled asset —
  /// see `UserAvatarImage`.
  static const String defaultAvatar = 'assets/images/default_avatar.png';

  /// The "+" glyph in the add-user tile of the "Who's watching?" picker.
  static const String addUserIcon = 'assets/images/plus.png';
}

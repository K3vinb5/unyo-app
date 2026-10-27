/// Thrown when a user-provider operation (list entry read/write) cannot be
/// addressed because the opened record has no verifiable mapping to the user
/// provider's native id.
///
/// Writing to a guessed id would corrupt an unrelated entry, so callers must
/// skip the write and surface the miss instead.
class MediaLinkUnresolvedException implements Exception {
  final String message;

  const MediaLinkUnresolvedException(this.message);

  @override
  String toString() => 'MediaLinkUnresolvedException: $message';
}

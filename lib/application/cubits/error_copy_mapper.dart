/// Turns a failure reported through `EffectMixin.handleError` into one short
/// user-facing sentence.
///
/// Call sites pass developer-oriented strings (`"Error fetching Anime Info
/// from selected extension: $e"`, sometimes with a dangling `:` and no cause at
/// all). Those strings leak exception class names, `Bad state:` messages and
/// stack fragments into the banner. The raw text belongs in the log; the user
/// gets classified copy from this mapper instead.
///
/// Classification (documented because the ticket asks for it):
/// - HTTP/server failure (`HttpServerException` at the call site, or any
///   connectivity marker in the text) → "Can't reach the server" plus a next
///   step ("check your connection and try again").
/// - `StateError` / `Bad state`, parse errors, and anything unrecognised →
///   the generic "Something went wrong" copy.
/// - A message with no failure evidence at all (already human copy such as
///   "This version of X is already installed.") keeps the call site's own
///   translation key, so the central mapper does not degrade copy that already
///   works. It arrives as `copyKey`; without one the sentence cannot be
///   translated and the generic copy is used.
class ErrorCopyMapper {
  const ErrorCopyMapper._();

  /// Banner title key used when the failure looks connectivity/server related.
  static const String connectivityTitleKey = 'error_connectivity_title';

  /// Banner message key for connectivity/server failures: what happened + next
  /// step.
  static const String connectivityMessageKey = 'error_connectivity_message';

  /// Banner title key for every non-network failure.
  static const String genericTitleKey = 'error_generic_title';

  /// Banner message key for every non-network failure.
  static const String genericMessageKey = 'error_generic_message';

  /// Substrings that identify a network/server failure in an interpolated
  /// exception string. `responseBody` alone is enough too — the call sites only
  /// pass it from `on HttpServerException` branches.
  static const List<String> _connectivityMarkers = <String>[
    "HttpServerException",
    "HttpNetworkException",
    "HttpTimeoutException",
    "SocketException",
    "ClientException",
    "ServerException",
    "HandshakeException",
    "TimeoutException",
    "Connection refused",
    "Connection reset",
    "Failed host lookup",
    "Network is unreachable",
    "No internet",
    "XMLHttpRequest",
  ];

  /// Substrings that identify raw failure text rather than human copy.
  static const List<String> _rawFailureMarkers = <String>[
    "Exception",
    "Error:",
    "Error ",
    "Failed to",
    "Bad state",
    "StateError",
    "LateInitializationError",
    "UnimplementedError",
    "MissingStubError",
    "Null check operator",
    "Null is not",
    "is not a subtype",
    "No element",
    "Invalid argument",
    "FormatException",
    "TypeError",
    "CastError",
    "Stack Trace",
    "#0 ",
    "unhandled",
  ];

  /// Trailing separators left behind by `"...: $e"` style interpolation when
  /// the cause is missing. A user sentence must never dangle on one.
  static final RegExp _danglingSeparators = RegExp(r'[\s:;,\-–—]+$');

  /// Classifies [message] (plus the HTTP [responseBody], when the call site had
  /// one) into banner copy.
  ///
  /// [copyKey] / [copyArgs] carry the translation key for call sites whose
  /// [message] is already clean human copy. Without a key that sentence cannot
  /// be translated at the presentation boundary, so the generic copy is used
  /// instead of leaking English out of `lib/application`.
  static ErrorCopy classify({
    required String message,
    String? responseBody,
    String? copyKey,
    Map<String, String>? copyArgs,
  }) {
    final String trimmed = stripDanglingSeparators(message);
    if (_looksLikeHumanCopy(trimmed) &&
        !_containsAny(trimmed, _rawFailureMarkers) &&
        responseBody == null &&
        !_containsAny(trimmed, _connectivityMarkers) &&
        copyKey != null) {
      return ErrorCopy(
        titleKey: genericTitleKey,
        messageKey: copyKey,
        messageArgs: copyArgs,
        kind: ErrorFailureKind.existingCopy,
      );
    }
    if (responseBody != null || _containsAny(trimmed, _connectivityMarkers)) {
      return const ErrorCopy(
        titleKey: connectivityTitleKey,
        messageKey: connectivityMessageKey,
        kind: ErrorFailureKind.connectivity,
      );
    }
    return const ErrorCopy(
      titleKey: genericTitleKey,
      messageKey: genericMessageKey,
      kind: ErrorFailureKind.generic,
    );
  }

  /// Human copy is a finished sentence ("... installed.") with no failure
  /// markers. Anything else — including a bare fragment like "boom" — is
  /// treated as unknown and mapped to the generic copy.
  static bool _looksLikeHumanCopy(String message) {
    return message.endsWith(".") || message.endsWith("!") || message.endsWith("?");
  }

  /// Removes trailing whitespace and dangling separators (`:`, `;`, `,`, `-`).
  static String stripDanglingSeparators(String message) {
    String result = message.trim();
    String previous = "";
    while (result != previous) {
      previous = result;
      result = result.replaceFirst(_danglingSeparators, "");
    }
    return result;
  }

  static bool _containsAny(String message, List<String> markers) {
    for (final String marker in markers) {
      if (message.contains(marker)) return true;
    }
    return false;
  }
}

/// How a failure was classified. Kept explicit so tests and future call sites
/// can branch on the reason instead of re-parsing copy.
enum ErrorFailureKind {
  /// Network/server failure: connectivity copy with a next step.
  connectivity,

  /// State/parse/unknown failure: generic copy.
  generic,

  /// The call site already produced clean human copy and supplied its own
  /// translation key.
  existingCopy,
}

/// Banner copy produced by [ErrorCopyMapper.classify].
///
/// Copy is translation keys plus args, never rendered English: the resolution
/// happens at the presentation boundary in `AppEffectHandler`.
class ErrorCopy {
  const ErrorCopy({
    required this.titleKey,
    required this.messageKey,
    this.messageArgs,
    required this.kind,
  });

  final String titleKey;
  final String messageKey;
  final Map<String, String>? messageArgs;
  final ErrorFailureKind kind;
}

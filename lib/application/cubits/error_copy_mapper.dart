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
///   "This version of X is already installed.") is shown unchanged, so the
///   central mapper does not degrade the copy that already works.
class ErrorCopyMapper {
  const ErrorCopyMapper._();

  /// Banner title used when the failure looks connectivity/server related.
  static const String connectivityTitle = "Can't reach the server";

  /// Banner message for connectivity/server failures: what happened + next step.
  static const String connectivityMessage =
      "The server did not answer that request. Check your connection and try again.";

  /// Banner title for every non-network failure.
  static const String genericTitle = "Something went wrong";

  /// Banner message for every non-network failure.
  static const String genericMessage = "That did not work. Please try again.";

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
  static ErrorCopy classify({required String message, String? responseBody}) {
    final String trimmed = stripDanglingSeparators(message);
    if (responseBody != null || _containsAny(trimmed, _connectivityMarkers)) {
      return const ErrorCopy(
        title: connectivityTitle,
        message: connectivityMessage,
        kind: ErrorFailureKind.connectivity,
      );
    }
    if (!_looksLikeHumanCopy(trimmed) || _containsAny(trimmed, _rawFailureMarkers)) {
      return const ErrorCopy(
        title: genericTitle,
        message: genericMessage,
        kind: ErrorFailureKind.generic,
      );
    }
    return ErrorCopy(
      title: genericTitle,
      message: trimmed,
      kind: ErrorFailureKind.existingCopy,
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

  /// The call site already produced clean human copy; it is shown unchanged.
  existingCopy,
}

/// Banner copy produced by [ErrorCopyMapper.classify].
class ErrorCopy {
  const ErrorCopy({
    required this.title,
    required this.message,
    required this.kind,
  });

  final String title;
  final String message;
  final ErrorFailureKind kind;
}

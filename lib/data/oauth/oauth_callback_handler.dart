// External dependencies
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart' as shelf;

// Internal dependencies
import 'package:unyo/data/oauth/oauth_callback_page.dart';

/// Exchanges one authorization code for a stored account.
typedef OAuthLoginCompletion = Future<void> Function(String authorizationCode);

/// Turns one OAuth redirect request into the browser-facing callback page.
///
/// Both provider repositories serve their callback through this handler, so the
/// success, error and fallback branches exist in exactly one place. The handler
/// only ever forwards the authorization code to [OAuthLoginCompletion]; nothing
/// from the request (code, state, raw provider error) is interpolated into the
/// markup, which is why tokens cannot appear in the page.
class OAuthCallbackHandler {
  OAuthCallbackHandler({
    required this.providerName,
    required this.logger,
    required this.onFinished,
  });

  /// Display name shown on the page; escaped by [OAuthCallbackPage].
  final String providerName;
  final Logger logger;

  /// Runs once the response is decided — the repository closes its callback
  /// server here, matching the old `finally` block.
  final void Function() onFinished;

  Future<shelf.Response> handle(shelf.Request request, OAuthLoginCompletion completeLogin) async {
    final Map<String, String> query = request.requestedUri.queryParameters;
    final String? providerError = query['error'];
    final String? code = query['code'];
    try {
      if (providerError != null && providerError.isNotEmpty) {
        // The provider's error text stays out of both the page and the log:
        // it is user-facing noise at best and debug material at worst.
        logger.i('$providerName sign-in was not completed by the provider');
        return OAuthCallbackPage.error(
          provider: providerName,
          failure: OAuthCallbackFailure.cancelled,
        );
      }
      if (code == null || code.isEmpty) {
        logger.w('$providerName callback was hit without an authorization code');
        return OAuthCallbackPage.fallback(provider: providerName);
      }
      await completeLogin(code);
      return OAuthCallbackPage.success(provider: providerName);
    } catch (error, stackTrace) {
      logger.e('Error handling $providerName login request: $error', stackTrace: stackTrace);
      return OAuthCallbackPage.error(
        provider: providerName,
        failure: OAuthCallbackFailure.exchangeFailed,
      );
    } finally {
      onFinished();
    }
  }
}

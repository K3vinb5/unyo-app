// External dependencies
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;

/// Why a sign-in did not finish, in the page's own words.
///
/// A closed enum on purpose: the page can never echo a provider error code,
/// request parameter or exception message, so nothing debug-worthy — and no
/// token material — can reach markup the browser renders.
enum OAuthCallbackFailure {
  /// The user dismissed the provider's consent screen (`?error=…`).
  cancelled,

  /// The authorization-code exchange or the follow-up profile call failed.
  exchangeFailed,
}

/// The single HTML page served on the localhost OAuth callback.
///
/// Both provider repositories (AniList and Shikimori) answer their callback
/// through this class, so the success, error and fallback states cannot drift
/// apart. The markup is fully self-contained — inline CSS and an inline SVG
/// wordmark, no fonts, scripts, images or URLs — so it still renders with the
/// network blocked right after the loopback request.
class OAuthCallbackPage {
  const OAuthCallbackPage._();

  static const String anilistProviderName = 'AniList';
  static const String shikimoriProviderName = 'Shikimori';

  static const String contentType = 'text/html; charset=utf-8';

  /// Escapes every interpolated value: `& < >` plus both quote characters,
  /// which is a superset of what text content needs, so the same helper stays
  /// safe if a value ever moves into an attribute. Without it a provider name
  /// containing markup would be executed as HTML.
  static const HtmlEscape _escape = HtmlEscape(HtmlEscapeMode.attribute);

  /// The authorization code was exchanged and the account is stored.
  static shelf.Response success({required String provider}) {
    final String escapedProvider = _escape.convert(provider);
    return _respond(
      statusCode: 200,
      html: _document(
        title: 'Signed in · Unyo',
        badgeClass: 'ok',
        badgeIcon: _checkIcon,
        heading: 'Signed in to $escapedProvider',
        message: 'Your account is connected and your lists are ready.',
        guidance: 'You can close this tab and return to Unyo.',
      ),
    );
  }

  /// The sign-in did not complete; [failure] picks a short, non-technical reason.
  static shelf.Response error({
    required String provider,
    required OAuthCallbackFailure failure,
  }) {
    final String escapedProvider = _escape.convert(provider);
    final String title;
    final String badgeClass;
    final String badgeIcon;
    final String heading;
    final String message;
    final String guidance;
    switch (failure) {
      case OAuthCallbackFailure.cancelled:
        title = 'Sign-in cancelled · Unyo';
        badgeClass = 'warn';
        badgeIcon = _warnIcon;
        heading = 'Sign-in was cancelled';
        message = 'Nothing changed — you can try again whenever you like.';
        guidance = 'Close this tab and return to Unyo to pick an account.';
      case OAuthCallbackFailure.exchangeFailed:
        title = 'Sign-in failed · Unyo';
        badgeClass = 'error';
        badgeIcon = _warnIcon;
        heading = "Sign-in to $escapedProvider didn't finish";
        message = "We couldn't complete the connection. Check your internet connection and try again.";
        guidance = 'Close this tab and return to Unyo.';
    }
    return _respond(
      statusCode: 500,
      html: _document(
        title: title,
        badgeClass: badgeClass,
        badgeIcon: badgeIcon,
        heading: heading,
        message: message,
        guidance: guidance,
      ),
    );
  }

  /// The callback was hit without an OAuth result, e.g. the user opened the URL
  /// directly. Nothing failed; there is simply nothing to complete.
  static shelf.Response fallback({required String provider}) {
    final String escapedProvider = _escape.convert(provider);
    return _respond(
      statusCode: 400,
      html: _document(
        title: 'Nothing to do here · Unyo',
        badgeClass: 'info',
        badgeIcon: _infoIcon,
        heading: "This page isn't a sign-in",
        message: 'It only finishes a sign-in you start from the Unyo app with $escapedProvider.',
        guidance: 'Close this tab and return to Unyo.',
      ),
    );
  }

  /// `no-store` because the page is a one-shot answer to a live OAuth redirect:
  /// a cached copy would be served to the next sign-in with the wrong state.
  static shelf.Response _respond({required int statusCode, required String html}) {
    return shelf.Response(
      statusCode,
      body: html,
      headers: const <String, String>{
        'content-type': contentType,
        'cache-control': 'no-store',
      },
    );
  }

  static String _document({
    required String title,
    required String badgeClass,
    required String badgeIcon,
    required String heading,
    required String message,
    required String guidance,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<meta name="robots" content="noindex">
<title>$title</title>
<style>
:root {
  color-scheme: light dark;
  --bg: #f3f3f7;
  --surface: #ffffff;
  --text: #17171c;
  --muted: #5c5c6b;
  --border: rgba(23, 23, 28, 0.10);
  --shadow: rgba(23, 23, 28, 0.12);
  --accent: #6c5ce7;
  --ok-bg: rgba(23, 138, 91, 0.12);
  --ok-fg: #178a5b;
  --warn-bg: rgba(176, 120, 12, 0.14);
  --warn-fg: #a06d05;
  --error-bg: rgba(192, 57, 43, 0.12);
  --error-fg: #c0392b;
  --info-bg: rgba(108, 92, 231, 0.12);
  --info-fg: #6c5ce7;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0c0c11;
    --surface: #17171f;
    --text: #f2f2f6;
    --muted: #a3a3b2;
    --border: rgba(255, 255, 255, 0.10);
    --shadow: rgba(0, 0, 0, 0.55);
    --accent: #9d8cff;
    --ok-bg: rgba(53, 214, 154, 0.16);
    --ok-fg: #35d69a;
    --warn-bg: rgba(240, 190, 70, 0.16);
    --warn-fg: #f0be46;
    --error-bg: rgba(255, 107, 107, 0.16);
    --error-fg: #ff8080;
    --info-bg: rgba(157, 140, 255, 0.16);
    --info-fg: #9d8cff;
  }
}
* { box-sizing: border-box; }
html, body { height: 100%; }
body {
  margin: 0;
  padding: clamp(16px, 5vw, 64px);
  display: grid;
  place-items: center;
  background: var(--bg);
  color: var(--text);
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}
main {
  width: 100%;
  max-width: 34rem;
  padding: clamp(28px, 6vw, 52px);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: clamp(16px, 3vw, 26px);
  box-shadow: 0 24px 64px var(--shadow);
  text-align: center;
}
.mark {
  display: block;
  width: clamp(130px, 42%, 176px);
  height: auto;
  margin: 0 auto clamp(24px, 5vw, 36px);
  color: var(--text);
}
.badge {
  width: 56px;
  height: 56px;
  margin: 0 auto clamp(18px, 4vw, 24px);
  display: grid;
  place-items: center;
  border-radius: 50%;
}
.badge svg { width: 28px; height: 28px; }
.badge.ok { background: var(--ok-bg); color: var(--ok-fg); }
.badge.warn { background: var(--warn-bg); color: var(--warn-fg); }
.badge.error { background: var(--error-bg); color: var(--error-fg); }
.badge.info { background: var(--info-bg); color: var(--info-fg); }
h1 {
  margin: 0 0 clamp(10px, 2vw, 14px);
  font-size: clamp(1.4rem, 1.1rem + 1.5vw, 2rem);
  font-weight: 700;
  letter-spacing: -0.015em;
  line-height: 1.2;
}
p {
  margin: 0;
  color: var(--muted);
  font-size: clamp(1rem, 0.96rem + 0.25vw, 1.1rem);
}
.hint { margin-top: clamp(20px, 4vw, 28px); font-size: 0.95rem; }
@media (prefers-reduced-motion: reduce) {
  * { animation: none !important; transition: none !important; }
}
</style>
</head>
<body>
<main>
  <svg class="mark" viewBox="0 0 176 48" role="img" aria-label="Unyo">
    <rect x="6" y="6" width="36" height="36" rx="11" fill="var(--accent)"/>
    <path d="M17 16v10a7 7 0 0 0 14 0V16" fill="none" stroke="#ffffff" stroke-width="3.4" stroke-linecap="round"/>
    <circle cx="24" cy="35" r="1.9" fill="#ffffff" opacity="0.9"/>
    <text x="54" y="32" font-family="system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif" font-size="27" font-weight="700" letter-spacing="-0.6" fill="currentColor">Unyo</text>
  </svg>
  <div class="badge $badgeClass" aria-hidden="true">
    $badgeIcon
  </div>
  <h1>$heading</h1>
  <p>$message</p>
  <p class="hint">$guidance</p>
</main>
</body>
</html>
''';
  }

  static const String _checkIcon =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12.5l5.5 5.5L20 6.5"/></svg>';

  static const String _warnIcon =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4.5v10"/><circle cx="12" cy="19.5" r="1.6" fill="currentColor" stroke="none"/></svg>';

  static const String _infoIcon =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="7.8" r="1.4" fill="currentColor" stroke="none"/></svg>';
}

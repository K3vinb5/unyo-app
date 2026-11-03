// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/application/cubits/error_copy_mapper.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';

void main() {
  group('ErrorCopyMapper.classify', () {
    /// The classified copy is translation keys, never rendered English: a key
    /// cannot leak developer detail the way a `"$e"` interpolation could, and
    /// the mapper must never hand back the raw call-site text (WP #124, wave 2).
    void expectUserSafe(ErrorCopy copy, {required String message}) {
      for (final String key in <String>[copy.titleKey, copy.messageKey]) {
        expect(RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$').hasMatch(key), isTrue, reason: key);
        expect(key.contains('Exception'), isFalse, reason: key);
        expect(key.contains('Bad state'), isFalse, reason: key);
        expect(key.contains('#0 '), isFalse, reason: key);
        expect(key.contains(message), isFalse, reason: key);
      }
    }

    test('maps an HTTP server failure to connectivity copy with a next step', () {
      final HttpServerException exception = HttpServerException(500, 'Server error');
      final ErrorCopy copy = ErrorCopyMapper.classify(
        message: 'Error fetching Anime details:',
        responseBody: exception.message,
      );

      expect(copy.kind, ErrorFailureKind.connectivity);
      expect(copy.titleKey, ErrorCopyMapper.connectivityTitleKey);
      expect(copy.messageKey, ErrorCopyMapper.connectivityMessageKey);
      expectUserSafe(copy, message: 'Error fetching Anime details:');
    });

    test('maps an interpolated network exception to connectivity copy', () {
      const String message =
          'Error fetching Anime Info: SocketException: Connection refused (OS Error: Connection refused)';
      final ErrorCopy copy = ErrorCopyMapper.classify(message: message);

      expect(copy.kind, ErrorFailureKind.connectivity);
      expect(copy.titleKey, ErrorCopyMapper.connectivityTitleKey);
      expectUserSafe(copy, message: message);
    });

    test('maps Bad state / StateError to the generic copy', () {
      final ErrorCopy badState = ErrorCopyMapper.classify(
        message: 'Error updating Anime Entry: Bad state: Cannot add new events after calling close',
      );
      final ErrorCopy stateError = ErrorCopyMapper.classify(
        message: 'StateError: Cubit/Bloc State must implement HasEffects',
      );

      for (final ErrorCopy copy in <ErrorCopy>[badState, stateError]) {
        expect(copy.kind, ErrorFailureKind.generic);
        expect(copy.titleKey, ErrorCopyMapper.genericTitleKey);
        expect(copy.messageKey, ErrorCopyMapper.genericMessageKey);
        expectUserSafe(copy, message: 'Bad state');
      }
    });

    test('maps parse errors and unknown failures to the generic copy', () {
      final ErrorCopy parseError = ErrorCopyMapper.classify(
        message: 'Error fetching Episodes Details: FormatException: Unexpected character',
      );
      final ErrorCopy unknown = ErrorCopyMapper.classify(message: 'boom');

      for (final ErrorCopy copy in <ErrorCopy>[parseError, unknown]) {
        expect(copy.kind, ErrorFailureKind.generic);
        expect(copy.messageKey, ErrorCopyMapper.genericMessageKey);
        expectUserSafe(copy, message: 'boom');
      }
    });

    test('rewrites a dangling-separator message instead of showing it', () {
      final ErrorCopy copy = ErrorCopyMapper.classify(message: 'Error fetching Alternative Image:');

      expect(copy.kind, ErrorFailureKind.generic);
      expect(copy.messageKey, ErrorCopyMapper.genericMessageKey);
      expectUserSafe(copy, message: 'Alternative Image');
      expect(ErrorCopyMapper.stripDanglingSeparators('Kept:  '), 'Kept');
    });

    test('keeps clean human copy as the call site key + args', () {
      final ErrorCopy copy = ErrorCopyMapper.classify(
        message: 'No update available for TestExtension.',
        copyKey: 'ext_no_update_available',
        copyArgs: <String, String>{'name': 'TestExtension'},
      );

      expect(copy.kind, ErrorFailureKind.existingCopy);
      expect(copy.titleKey, ErrorCopyMapper.genericTitleKey);
      expect(copy.messageKey, 'ext_no_update_available');
      expect(copy.messageArgs, <String, String>{'name': 'TestExtension'});
      expectUserSafe(copy, message: 'TestExtension');
    });

    test('human copy without a key degrades to the generic copy', () {
      // Nothing in `lib/application` may carry English to the banner, so an
      // unkeyed finished sentence cannot be shown as-is any more.
      final ErrorCopy copy = ErrorCopyMapper.classify(
        message: 'No update available for TestExtension.',
      );

      expect(copy.kind, ErrorFailureKind.generic);
      expect(copy.messageKey, ErrorCopyMapper.genericMessageKey);
      expect(copy.messageArgs, isNull);
    });
  });
}

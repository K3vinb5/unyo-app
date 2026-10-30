// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/application/cubits/error_copy_mapper.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';

void main() {
  group('ErrorCopyMapper.classify', () {
    /// The banner string must never leak developer detail and must never
    /// dangle on a separator (WP #92, item 1).
    void expectUserSafe(ErrorCopy copy) {
      final String combined = '${copy.title} ${copy.message}';
      expect(combined.contains('Exception'), isFalse, reason: combined);
      expect(combined.contains('Bad state'), isFalse, reason: combined);
      expect(combined.contains('StateError'), isFalse, reason: combined);
      expect(combined.contains('#0 '), isFalse, reason: combined);
      expect(copy.message.trim().endsWith(':'), isFalse, reason: combined);
      expect(RegExp(r'[\s:;,]$').hasMatch(copy.message), isFalse, reason: combined);
      expect(copy.message.trim(), isNotEmpty, reason: combined);
    }

    test('maps an HTTP server failure to connectivity copy with a next step', () {
      final HttpServerException exception = HttpServerException(500, 'Server error');
      final ErrorCopy copy = ErrorCopyMapper.classify(
        message: 'Error fetching Anime details:',
        responseBody: exception.message,
      );

      expect(copy.kind, ErrorFailureKind.connectivity);
      expect(copy.title, ErrorCopyMapper.connectivityTitle);
      expect(copy.message, ErrorCopyMapper.connectivityMessage);
      expect(copy.message, contains('connection'));
      expectUserSafe(copy);
    });

    test('maps an interpolated network exception to connectivity copy', () {
      final ErrorCopy copy = ErrorCopyMapper.classify(
        message: 'Error fetching Anime Info: SocketException: Connection refused (OS Error: Connection refused)',
      );

      expect(copy.kind, ErrorFailureKind.connectivity);
      expect(copy.title, ErrorCopyMapper.connectivityTitle);
      expectUserSafe(copy);
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
        expect(copy.title, ErrorCopyMapper.genericTitle);
        expect(copy.message, ErrorCopyMapper.genericMessage);
        expectUserSafe(copy);
      }
    });

    test('maps parse errors and unknown failures to the generic copy', () {
      final ErrorCopy parseError = ErrorCopyMapper.classify(
        message: 'Error fetching Episodes Details: FormatException: Unexpected character',
      );
      final ErrorCopy unknown = ErrorCopyMapper.classify(message: 'boom');

      for (final ErrorCopy copy in <ErrorCopy>[parseError, unknown]) {
        expect(copy.kind, ErrorFailureKind.generic);
        expect(copy.message, ErrorCopyMapper.genericMessage);
        expectUserSafe(copy);
      }
    });

    test('rewrites a dangling-separator message instead of showing it', () {
      final ErrorCopy copy = ErrorCopyMapper.classify(message: 'Error fetching Alternative Image:');

      expect(copy.kind, ErrorFailureKind.generic);
      expect(copy.message, ErrorCopyMapper.genericMessage);
      expectUserSafe(copy);
      expect(ErrorCopyMapper.stripDanglingSeparators('Kept:  '), 'Kept');
    });

    test('keeps clean human copy untouched', () {
      final ErrorCopy copy = ErrorCopyMapper.classify(message: 'No update available for TestExtension.');

      expect(copy.kind, ErrorFailureKind.existingCopy);
      expect(copy.title, ErrorCopyMapper.genericTitle);
      expect(copy.message, 'No update available for TestExtension.');
      expectUserSafe(copy);
    });
  });
}

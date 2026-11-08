// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/http/response_cache_scope.dart';

void main() {
  test('each invalidation advances the revision exactly once', () {
    final ResponseCacheScope scope = ResponseCacheScope();
    expect(scope.revision, 0);

    scope.invalidate();
    expect(scope.revision, 1);

    scope.invalidate();
    scope.invalidate();
    expect(scope.revision, 3);
  });
}

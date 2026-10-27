// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/update/version_comparator.dart';

void main() {
  group('compareVersions', () {
    final cases = <(String, String, int)>[
      // (a, b, expected sign)
      ('1.0.0', '1.0.0', 0),
      ('v1.0.0', '1.0.0', 0),
      ('1.0.0', 'v1.0.0', 0),
      ('V1.2.3', 'v1.2.3', 0),
      ('1.0.0', '1.0.1', -1),
      ('1.0.1', '1.0.0', 1),
      ('1.9.0', '1.10.0', -1),
      ('1.10.0', '1.9.0', 1),
      ('2.0.0', '1.99.99', 1),
      ('1.0.0-beta', '1.0.0', -1),
      ('1.0.0', '1.0.0-beta', 1),
      ('1.0.0-beta', '1.0.0-beta', 0),
      ('1.0.0-alpha', '1.0.0-beta', -1),
      ('1.0.0-beta.2', '1.0.0-beta.10', -1),
      ('1.0.0-alpha', '1.0.0-alpha.1', -1),
      ('1.0.0-rc.1', '1.0.0-beta.2', 1),
      ('1.0.0+build.5', '1.0.0', 0),
      ('1.0.0+42', '1.0.0+43', 0),
      ('1.0.0-beta+7', '1.0.0-beta', 0),
      ('1.2', '1.2.0', 0),
      ('1.2', '1.2.1', -1),
      ('v1.0.0', 'v1.0.1', -1),
    ];

    for (final (a, b, expectedSign) in cases) {
      test('$a vs $b -> ${expectedSign < 0 ? 'older' : expectedSign > 0 ? 'newer' : 'equal'}', () {
        expect(compareVersions(a, b).sign, expectedSign, reason: '$a compared to $b');
      });
    }
  });

  group('isVersionNewer', () {
    test('treats a v-prefixed tag as equal to the plain version', () {
      expect(isVersionNewer('v1.0.0', '1.0.0'), isFalse);
    });

    test('detects a newer minor', () {
      expect(isVersionNewer('1.10.0', '1.9.0'), isTrue);
    });

    test('detects a newer patch', () {
      expect(isVersionNewer('1.0.1', '1.0.0'), isTrue);
    });

    test('does not treat an older release as newer', () {
      expect(isVersionNewer('1.0.0', '1.0.1'), isFalse);
    });

    test('ignores build metadata', () {
      expect(isVersionNewer('1.0.0+9', '1.0.0'), isFalse);
    });

    test('treats a pre-release as older than its release', () {
      expect(isVersionNewer('1.0.0-beta', '1.0.0'), isFalse);
    });

    test('treats the release as newer than its pre-release', () {
      expect(isVersionNewer('1.0.0', '1.0.0-beta'), isTrue);
    });
  });
}

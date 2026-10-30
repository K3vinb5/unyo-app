// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/data/models/shikimori/media/shikimori_list_status_policy.dart';

/// WP #64 subpart (c), decision 5: the status table is policy, so it is pinned
/// in both directions and for every one of the six Shikimori statuses.
void main() {
  group('ShikimoriListStatusPolicy read direction', () {
    test('watching and rewatching fold into CURRENT', () {
      expect(ShikimoriListStatusPolicy.toUnified('watching'), ShikimoriListStatusPolicy.current);
      expect(ShikimoriListStatusPolicy.toUnified('rewatching'), ShikimoriListStatusPolicy.current);
    });

    test('the remaining four statuses map one to one', () {
      expect(ShikimoriListStatusPolicy.toUnified('planned'), ShikimoriListStatusPolicy.planning);
      expect(ShikimoriListStatusPolicy.toUnified('completed'), ShikimoriListStatusPolicy.completed);
      expect(ShikimoriListStatusPolicy.toUnified('dropped'), ShikimoriListStatusPolicy.dropped);
      expect(ShikimoriListStatusPolicy.toUnified('on_hold'), ShikimoriListStatusPolicy.paused);
    });

    test('every Shikimori status maps to a known unified status', () {
      const Set<String> known = <String>{
        'CURRENT',
        'PLANNING',
        'COMPLETED',
        'DROPPED',
        'PAUSED',
        'REPEATING',
      };
      expect(ShikimoriListStatusPolicy.shikimoriStatuses, hasLength(6));
      for (final String status in ShikimoriListStatusPolicy.shikimoriStatuses) {
        expect(
          known,
          contains(ShikimoriListStatusPolicy.toUnified(status)),
          reason: '$status must go through the table, not fall through',
        );
      }
    });

    test('an unknown status is upper-cased verbatim instead of invented', () {
      expect(ShikimoriListStatusPolicy.toUnified('custom_status'), 'CUSTOM STATUS');
    });
  });

  group('ShikimoriListStatusPolicy write direction', () {
    test('the six unified statuses reverse the table', () {
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.current), 'watching');
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.planning), 'planned');
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.completed), 'completed');
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.dropped), 'dropped');
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.paused), 'on_hold');
      expect(ShikimoriListStatusPolicy.toShikimori(ShikimoriListStatusPolicy.repeating), 'rewatching');
    });

    test('the UI display spelling is accepted too', () {
      expect(ShikimoriListStatusPolicy.toShikimori('Current'), 'watching');
      expect(ShikimoriListStatusPolicy.toShikimori('Paused'), 'on_hold');
    });

    test('an unknown or empty status means "no status" (a delete, not an update)', () {
      expect(ShikimoriListStatusPolicy.toShikimori('ADD TO LIST'), isEmpty);
      expect(ShikimoriListStatusPolicy.toShikimori(''), isEmpty);
    });

    test('round trip: read then write returns the stored status for five of six', () {
      for (final String status in ShikimoriListStatusPolicy.shikimoriStatuses) {
        final String unified = ShikimoriListStatusPolicy.toUnified(status);
        final String written = ShikimoriListStatusPolicy.toShikimori(unified);
        if (status == 'rewatching') {
          // The fold is intentionally lossy in one direction: `rewatching` reads
          // as CURRENT, so writing it back lands on `watching`.
          expect(written, 'watching');
          continue;
        }
        expect(written, status, reason: 'status $status must round trip');
      }
    });
  });

  group('ShikimoriListStatusPolicy repeat', () {
    test('rewatching feeds repeat from its own rewatches counter', () {
      expect(
        ShikimoriListStatusPolicy.repeatFor(shikimoriStatus: 'rewatching', rewatches: 3),
        3,
      );
    });

    test('rewatching does not add one, so a write cannot inflate the count', () {
      final int repeat = ShikimoriListStatusPolicy.repeatFor(shikimoriStatus: 'rewatching', rewatches: 2);
      expect(ShikimoriListStatusPolicy.rewatchesFor(unifiedStatus: 'CURRENT', repeat: repeat), 2);
    });

    test('negative counters are clamped to zero', () {
      expect(ShikimoriListStatusPolicy.repeatFor(shikimoriStatus: 'watching', rewatches: -4), 0);
      expect(ShikimoriListStatusPolicy.rewatchesFor(unifiedStatus: 'CURRENT', repeat: -4), 0);
    });
  });

  group('ShikimoriListStatusPolicy buckets', () {
    test('CURRENT is fed by watching and rewatching, REPEATING by nothing', () {
      expect(
        ShikimoriListStatusPolicy.shikimoriStatusesFor(ShikimoriListStatusPolicy.current),
        <String>['watching', 'rewatching'],
      );
      expect(
        ShikimoriListStatusPolicy.shikimoriStatusesFor(ShikimoriListStatusPolicy.repeating),
        isEmpty,
      );
    });

    test('bucket names use the AniList vocabulary for provider-agnostic tabs', () {
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.current), 'Watching');
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.planning), 'Planning');
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.completed), 'Completed');
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.dropped), 'Dropped');
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.paused), 'Paused');
      expect(ShikimoriListStatusPolicy.displayName(ShikimoriListStatusPolicy.repeating), 'Repeating');
    });
  });
}

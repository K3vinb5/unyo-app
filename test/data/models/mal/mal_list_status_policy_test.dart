// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';

/// WP #156: the status table is policy, so it is pinned in both directions and
/// for **both** MAL vocabularies (anime `watching`/`plan_to_watch`, manga
/// `reading`/`plan_to_read`).
void main() {
  group('MalListStatusPolicy read direction', () {
    test('watching and reading fold into CURRENT', () {
      expect(MalListStatusPolicy.toUnified('watching'), MalListStatusPolicy.current);
      expect(MalListStatusPolicy.toUnified('reading'), MalListStatusPolicy.current);
    });

    test('plan_to_watch and plan_to_read fold into PLANNING', () {
      expect(MalListStatusPolicy.toUnified('plan_to_watch'), MalListStatusPolicy.planning);
      expect(MalListStatusPolicy.toUnified('plan_to_read'), MalListStatusPolicy.planning);
    });

    test('the remaining three statuses map one to one', () {
      expect(MalListStatusPolicy.toUnified('completed'), MalListStatusPolicy.completed);
      expect(MalListStatusPolicy.toUnified('dropped'), MalListStatusPolicy.dropped);
      expect(MalListStatusPolicy.toUnified('on_hold'), MalListStatusPolicy.paused);
    });

    test('every MAL status of both kinds maps to a known unified status', () {
      const Set<String> known = <String>{
        'CURRENT',
        'PLANNING',
        'COMPLETED',
        'DROPPED',
        'PAUSED',
        'REPEATING',
      };
      expect(MalListStatusPolicy.animeStatuses, hasLength(5));
      expect(MalListStatusPolicy.mangaStatuses, hasLength(5));
      for (final String status in <String>[
        ...MalListStatusPolicy.animeStatuses,
        ...MalListStatusPolicy.mangaStatuses,
      ]) {
        expect(
          known,
          contains(MalListStatusPolicy.toUnified(status)),
          reason: '$status must go through the table, not fall through',
        );
      }
    });

    test('an unknown status is upper-cased verbatim instead of invented', () {
      expect(MalListStatusPolicy.toUnified('custom_status'), 'CUSTOM STATUS');
    });
  });

  group('MalListStatusPolicy write direction', () {
    test('the unified statuses reverse the table per kind', () {
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.current, target: MalListTarget.anime),
        'watching',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.current, target: MalListTarget.manga),
        'reading',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.planning, target: MalListTarget.anime),
        'plan_to_watch',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.planning, target: MalListTarget.manga),
        'plan_to_read',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.completed, target: MalListTarget.anime),
        'completed',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.dropped, target: MalListTarget.manga),
        'dropped',
      );
      expect(
        MalListStatusPolicy.toMal(MalListStatusPolicy.paused, target: MalListTarget.anime),
        'on_hold',
      );
    });

    test('the UI display spelling is accepted too', () {
      expect(MalListStatusPolicy.toMal('Current', target: MalListTarget.anime), 'watching');
      expect(MalListStatusPolicy.toMal('Paused', target: MalListTarget.manga), 'on_hold');
    });

    test('REPEATING lands on the current bucket and owns the rewatch flag', () {
      expect(MalListStatusPolicy.toMal(MalListStatusPolicy.repeating, target: MalListTarget.anime), 'watching');
      expect(MalListStatusPolicy.toMal(MalListStatusPolicy.repeating, target: MalListTarget.manga), 'reading');
      expect(MalListStatusPolicy.isRewatchingFor(MalListStatusPolicy.repeating), isTrue);
      expect(MalListStatusPolicy.isRewatchingFor(MalListStatusPolicy.current), isFalse);
    });

    test('an unknown or empty status means "no status" (a delete, not an update)', () {
      expect(MalListStatusPolicy.toMal('ADD TO LIST', target: MalListTarget.anime), isEmpty);
      expect(MalListStatusPolicy.toMal('', target: MalListTarget.manga), isEmpty);
    });

    test('round trip: read then write returns the stored status for both kinds', () {
      for (final String status in MalListStatusPolicy.animeStatuses) {
        final String unified = MalListStatusPolicy.toUnified(status);
        expect(
          MalListStatusPolicy.toMal(unified, target: MalListTarget.anime),
          status,
          reason: 'anime status $status must round trip',
        );
      }
      for (final String status in MalListStatusPolicy.mangaStatuses) {
        final String unified = MalListStatusPolicy.toUnified(status);
        expect(
          MalListStatusPolicy.toMal(unified, target: MalListTarget.manga),
          status,
          reason: 'manga status $status must round trip',
        );
      }
    });
  });

  group('MalListStatusPolicy repeat', () {
    test('num_times_rewatched/reread feeds repeat without adding one', () {
      expect(MalListStatusPolicy.repeatFor(3), 3);
      final int repeat = MalListStatusPolicy.repeatFor(2);
      expect(
        MalListStatusPolicy.rewatchCountFor(unifiedStatus: 'CURRENT', repeat: repeat),
        2,
        reason: 'a write must not inflate the counter the read produced',
      );
    });

    test('negative counters clamp to zero', () {
      expect(MalListStatusPolicy.repeatFor(-4), 0);
      expect(MalListStatusPolicy.rewatchCountFor(unifiedStatus: 'CURRENT', repeat: -4), 0);
    });
  });

  group('MalListStatusPolicy buckets', () {
    test('CURRENT is fed by the kind\'s current status, REPEATING by nothing', () {
      expect(
        MalListStatusPolicy.malStatusesFor(MalListStatusPolicy.current, target: MalListTarget.anime),
        <String>['watching'],
      );
      expect(
        MalListStatusPolicy.malStatusesFor(MalListStatusPolicy.current, target: MalListTarget.manga),
        <String>['reading'],
      );
      expect(
        MalListStatusPolicy.malStatusesFor(MalListStatusPolicy.repeating, target: MalListTarget.anime),
        isEmpty,
      );
    });

    test('bucket names use the AniList vocabulary for provider-agnostic tabs', () {
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.current), 'Watching');
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.planning), 'Planning');
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.completed), 'Completed');
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.dropped), 'Dropped');
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.paused), 'Paused');
      expect(MalListStatusPolicy.displayName(MalListStatusPolicy.repeating), 'Repeating');
      expect(
        MalListStatusPolicy.displayOrder,
        <String>['CURRENT', 'PLANNING', 'COMPLETED', 'REPEATING', 'PAUSED', 'DROPPED'],
      );
    });
  });
}

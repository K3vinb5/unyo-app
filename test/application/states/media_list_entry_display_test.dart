// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/application/states/media_list_entry_display.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';

/// WP #167: a list entry is a patch-shaped value, so its `-1` progress/volumes
/// and `-1.0` score sentinels — and the `ADD TO LIST` status — must never reach
/// a widget. Every display surface maps them through [MediaListEntryDisplay].
void main() {
  group('MediaListEntryDisplay sentinel mapping', () {
    test('a fresh entry scores 0 instead of the -1 sentinel', () {
      expect(MediaListEntryDisplay.score(MediaListEntryModel.empty().score), 0);
    });

    test('a stored score is passed through untouched', () {
      expect(MediaListEntryDisplay.score(8.0), 8);
    });

    test('a fractional score rounds to the nearest slider step', () {
      expect(MediaListEntryDisplay.score(6.5), 7);
      expect(MediaListEntryDisplay.score(0), 0);
    });
  });

  group('MediaListEntryDisplay status vocabulary', () {
    test('the ADD TO LIST sentinel is not on a list and has no label', () {
      expect(MediaListEntryDisplay.isOnList(MediaListEntryModel.noStatus), isFalse);
      expect(MediaListEntryDisplay.isOnList(''), isFalse);
      expect(MediaListEntryDisplay.statusLabel(MediaListEntryModel.noStatus), isNull);
    });

    test('provider spellings fold onto the editor vocabulary', () {
      expect(MediaListEntryDisplay.statusLabel('CURRENT'), 'Current');
      expect(MediaListEntryDisplay.statusLabel('WATCHING'), 'Current');
      expect(MediaListEntryDisplay.statusLabel('PLANNING'), 'Planning');
      expect(MediaListEntryDisplay.statusLabel('REPEATING'), 'Repeating');
      expect(MediaListEntryDisplay.statusLabel('PAUSED'), 'Paused');
      expect(MediaListEntryDisplay.statusLabel('DROPPED'), 'Dropped');
    });

    test('every editor option round-trips through the label table', () {
      for (final String option in MediaListEntryDisplay.statusOptions) {
        expect(
          MediaListEntryDisplay.statusLabel(option),
          option,
          reason: 'a status chosen in the dropdown must read back identically',
        );
        expect(MediaListEntryDisplay.isOnList(option), isTrue);
      }
    });

    test('an unknown status renders verbatim instead of being invented', () {
      expect(MediaListEntryDisplay.statusLabel('CUSTOM_STATUS'), 'CUSTOM STATUS');
    });
  });
}

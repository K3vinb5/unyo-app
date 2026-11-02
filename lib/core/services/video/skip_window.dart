// Internal dependencies
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';

/// Which AniSkip window the playhead is currently inside.
enum SkipWindowKind { none, opening, ending }

/// The AniSkip window the playhead is in, or [SkipWindowKind.none].
///
/// Pure so the skip pill's visibility (WP #113 B) and the cubit's
/// label/action (`getSkipTimeText` / `performSkipActin`) can never disagree:
/// they all read this one predicate instead of re-deriving the comparison.
///
/// An unset window is `startTime == -1` / `endTime == -1` (the DTO default), so
/// a non-positive `endTime` means "no data".
SkipWindowKind activeSkipWindow({
  required Duration position,
  required AniskipTimesResults opening,
  required AniskipTimesResults ending,
}) {
  final seconds = position.inSeconds;
  if (opening.interval.endTime > 0 &&
      seconds > opening.interval.startTime &&
      opening.interval.endTime > seconds) {
    return SkipWindowKind.opening;
  }
  if (ending.interval.endTime > 0 &&
      seconds > ending.interval.startTime &&
      ending.interval.endTime > seconds) {
    return SkipWindowKind.ending;
  }
  return SkipWindowKind.none;
}

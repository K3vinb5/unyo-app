import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';

/// Cache/dedup key for one entry of one provider pair: prompting is gated per
/// entry, per app session.
String mediaLinkEntryKey({
  required Service source,
  required String nativeId,
  required Service target,
}) =>
    '${source.name}:$nativeId->${target.name}';

/// A pending "which of these is it?" question for the link-confirmation dialog.
///
/// Only produced by the heuristic title-search stage of the resolution chain;
/// provider-field and AniZip hits are applied silently.
class MediaLinkProposal {
  /// Provider that owns the account/lists (why the mismatch exists).
  final Service userService;

  /// Provider the details are supposed to come from.
  final Service metadataService;

  /// Provider that produced the record the user opened.
  final Service sourceService;

  final String sourceNativeId;
  final List<MediaLinkCandidate> candidates;

  const MediaLinkProposal({
    required this.userService,
    required this.metadataService,
    required this.sourceService,
    required this.sourceNativeId,
    required this.candidates,
  });

  String get entryKey => mediaLinkEntryKey(
        source: sourceService,
        nativeId: sourceNativeId,
        target: metadataService,
      );
}

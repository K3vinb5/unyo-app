// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';

/// One leg of the mapping chain, answering only its own [Service] target —
/// exactly how `MediaMappingRepositoryShikimori` and `MediaMappingRepositoryMal`
/// self-select (WP #61 / WP #156).
class FakeLeg implements MediaMappingLookup {
  final Service owner;
  final MediaLinkCandidate? probe;
  final List<MediaLinkCandidate> candidates;
  int probeCalls = 0;
  int searchCalls = 0;

  FakeLeg(this.owner, {this.probe, this.candidates = const <MediaLinkCandidate>[]});

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    probeCalls++;
    return target == owner ? probe : null;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    searchCalls++;
    return target == owner ? candidates : const <MediaLinkCandidate>[];
  }
}

/// WP #156: the chain's single [MediaMappingLookup] slot dispatches to the leg
/// that owns the target, so Shikimori's and MAL's legs can coexist.
void main() {
  const MediaLinkCandidate shikimoriHit = MediaLinkCandidate(
    service: Service.shikimori,
    nativeId: '65261',
    malId: 58514,
    title: 'Kusuriya no Hitorigoto',
  );
  const MediaLinkCandidate malHit = MediaLinkCandidate(
    service: Service.mal,
    nativeId: '58514',
    malId: 58514,
    title: 'Kusuriya no Hitorigoto',
  );

  test('the probe reaches the leg that owns the target', () async {
    final FakeLeg shikimori = FakeLeg(Service.shikimori, probe: shikimoriHit);
    final FakeLeg mal = FakeLeg(Service.mal, probe: malHit);
    final CompositeMediaMappingLookup composite = CompositeMediaMappingLookup(<MediaMappingLookup>[shikimori, mal]);

    expect(await composite.lookupByMalId(Service.mal, 58514), malHit);
    expect(mal.probeCalls, 1);
    expect(shikimori.probeCalls, 1, reason: 'the first leg is asked first and refuses the foreign target');

    expect(await composite.lookupByMalId(Service.shikimori, 58514), shikimoriHit);
  });

  test('a target no leg owns returns no probe result', () async {
    final FakeLeg mal = FakeLeg(Service.mal, probe: malHit);
    final CompositeMediaMappingLookup composite = CompositeMediaMappingLookup(<MediaMappingLookup>[mal]);

    expect(await composite.lookupByMalId(Service.anilist, 58514), isNull);
  });

  test('search candidates are gathered leg by leg in registration order', () async {
    final FakeLeg shikimori = FakeLeg(Service.shikimori, candidates: <MediaLinkCandidate>[shikimoriHit]);
    final FakeLeg mal = FakeLeg(Service.mal);
    final CompositeMediaMappingLookup composite = CompositeMediaMappingLookup(<MediaMappingLookup>[shikimori, mal]);

    expect(await composite.searchCandidates(Service.shikimori, 'Kusuriya'), <MediaLinkCandidate>[shikimoriHit]);
    expect(await composite.searchCandidates(Service.mal, 'Kusuriya'), isEmpty);
  });
}

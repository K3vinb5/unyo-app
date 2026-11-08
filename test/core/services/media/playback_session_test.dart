// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/media/playback_session.dart';

void main() {
  group('PlaybackMetadata', () {
    test('copyWithDuration keeps the identity of the playing item', () {
      final PlaybackMetadata metadata = PlaybackMetadata(
        id: 'unyo-1-ep2',
        title: 'Episode 2',
        artist: 'Anime',
        album: 'Anime',
        artUri: Uri.parse('https://example.test/cover.png'),
      );

      final PlaybackMetadata withDuration = metadata.copyWithDuration(
        const Duration(minutes: 24),
      );

      expect(withDuration.id, metadata.id);
      expect(withDuration.title, metadata.title);
      expect(withDuration.artist, metadata.artist);
      expect(withDuration.artUri, metadata.artUri);
      expect(withDuration.duration, const Duration(minutes: 24));
      expect(metadata.duration, isNull, reason: 'the source is immutable');
    });
  });

  group('NoopPlaybackSession', () {
    test('tracks activation and survives every publish call', () async {
      final NoopPlaybackSession session = NoopPlaybackSession();
      expect(session.isActive, isFalse);

      await session.activate(_NoopCommands());
      expect(session.isActive, isTrue);

      await session.publishMetadata(
        const PlaybackMetadata(id: 'id', title: 'Episode 1', artist: 'Anime'),
      );
      await session.publishState(
        status: PlaybackStatus.playing,
        position: const Duration(seconds: 12),
        speed: 1.25,
      );

      await session.deactivate();
      expect(session.isActive, isFalse);
    });
  });
}

class _NoopCommands implements PlaybackCommandHandler {
  @override
  Future<void> onNext() async {}

  @override
  Future<void> onPause() async {}

  @override
  Future<void> onPlay() async {}

  @override
  Future<void> onPrevious() async {}

  @override
  Future<void> onSeek(Duration position) async {}

  @override
  Future<void> onStop() async {}

  @override
  Future<void> onTogglePlayPause() async {}
}

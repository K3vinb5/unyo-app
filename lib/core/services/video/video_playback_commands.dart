/// The command surface the keyboard shortcuts drive.
///
/// `VideoService` implements it, so the shortcut layer dispatches to exactly the
/// same calls the on-screen controls make — buttons and keys cannot drift. Kept
/// in `core` (not `presentation`) so the service never has to import the UI.
abstract class VideoPlaybackCommands {
  bool get isPlaying;
  double get volume;
  double get playbackSpeed;
  Duration get position;
  Duration get duration;
  bool get isFullscreen;
  bool get subtitlesEnabled;

  void play();
  void pause();
  void togglePlay();
  void seekTo(Duration position);
  void setVolume(double volume);
  void setPlaybackSpeed(double speed);
  void setFullscreen(bool fullscreen);
  bool toggleSubtitles();
}

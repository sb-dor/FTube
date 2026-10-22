import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:l/l.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';

/// Owns the screen's video player: quality, controls visibility, and handing the sound to the
/// background player while the app is in the background.
class VideoPlaybackController with ChangeNotifier {
  VideoPlaybackController({required this._backgroundAudio});

  final BackgroundAudio _backgroundAudio;

  VideoStreams? _streams;
  PlayableStream? _quality;
  VideoPlayerController? _player;
  bool _failed = false;
  bool _controlsVisible = false;
  bool _audioInBackground = false;
  bool _disposed = false;
  Timer? _hideTimer;

  VideoPlayerController? get player => _player;

  bool get isReady => _player?.value.isInitialized ?? false;

  bool get failed => _failed;

  bool get controlsVisible => _controlsVisible;

  List<PlayableStream> get qualities => _streams?.playable ?? const [];

  PlayableStream? get quality => _quality;

  StreamSource? _source;

  /// URL of what is playing (for the mini player).
  Uri? get url => _source?.url ?? _streams?.hlsUrl;

  /// Headers the playing URL needs.
  Map<String, String> get headers => _source?.headers ?? const {};

  Duration get position => _player?.value.position ?? Duration.zero;

  /// Starts playing [streams] from [startAt].
  Future<void> open(VideoStreams streams, {Duration startAt = Duration.zero}) {
    _streams = streams;
    _quality = streams.initial;
    final sources =
        _quality?.sources ??
        [if (streams.hlsUrl case final hls?) StreamSource(url: hls, client: 'HLS')];
    if (sources.isEmpty) {
      _failed = true;
      notifyListeners();
      return Future.value();
    }
    return _play(sources, startAt);
  }

  /// Switches to [quality] and continues from the current position.
  Future<void> changeQuality(PlayableStream quality) {
    if (quality.url == _quality?.url) return Future.value();
    _quality = quality;
    return _play(quality.sources, position);
  }

  /// Plays the first of [sources] that YouTube serves.
  Future<void> _play(List<StreamSource> sources, Duration startAt) async {
    final previous = _player;
    _player = null;
    _failed = false;
    notifyListeners();
    await previous?.dispose();
    for (final source in sources) {
      final player = VideoPlayerController.networkUrl(
        source.url,
        httpHeaders: source.headers,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false),
      );
      _player = player;
      _source = source;
      notifyListeners();
      try {
        await player.initialize();
        l.d('Playback | playing from ${source.client}');
        if (_disposed || !identical(_player, player)) return;
        if (startAt > Duration.zero) await player.seekTo(startAt);
        await player.play();
        player.addListener(_onPlayer);
        notifyListeners();
        return;
      } on Object {
        if (_disposed || !identical(_player, player)) return;
        await player.dispose();
      }
    }
    _player = null;
    _failed = true;
    if (!_disposed) notifyListeners();
  }

  bool _wasPlaying = false;

  void _onPlayer() {
    final playing = _player?.value.isPlaying ?? false;
    if (playing == _wasPlaying) return;
    _wasPlaying = playing;
    // Paused or finished: keep the controls on screen.
    if (!playing) {
      _hideTimer?.cancel();
      _controlsVisible = true;
    }
    notifyListeners();
  }

  void togglePlay() {
    final player = _player;
    if (player == null || !player.value.isInitialized) return;
    if (player.value.isPlaying) {
      player.pause();
    } else {
      if (player.value.isCompleted) player.seekTo(Duration.zero);
      player.play();
    }
    showControls();
  }

  void toggleControls() => _controlsVisible ? hideControls() : showControls();

  /// Shows the controls; they hide again after 5 seconds of playback.
  void showControls() {
    _hideTimer?.cancel();
    _controlsVisible = true;
    notifyListeners();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (_player?.value.isPlaying ?? false) hideControls();
    });
  }

  void hideControls() {
    _hideTimer?.cancel();
    _controlsVisible = false;
    notifyListeners();
  }

  /// The app went to the background: continue the sound through the background player.
  Future<void> moveToBackground(MediaItem item) async {
    final player = _player;
    final audio = _streams?.audio;
    final audioUrl = audio?.url ?? url;
    if (player == null || !player.value.isPlaying || audioUrl == null) return;
    final position = player.value.position;
    await player.pause();
    _audioInBackground = true;
    await _backgroundAudio.play(
      audioUrl,
      headers: audio?.headers ?? headers,
      item: item,
      position: position,
    );
  }

  /// The app is back: continue the video where the sound got to.
  Future<void> returnFromBackground() async {
    if (!_audioInBackground) return;
    _audioInBackground = false;
    final position = _backgroundAudio.player.position;
    final wasPlaying = _backgroundAudio.player.playing;
    await _backgroundAudio.stop();
    await _player?.seekTo(position);
    if (wasPlaying) await _player?.play();
  }

  /// Stops playback without releasing the player (another video takes over the sheet).
  Future<void> pause() async => _player?.pause();

  @override
  void dispose() {
    _disposed = true;
    _hideTimer?.cancel();
    if (_audioInBackground) _backgroundAudio.stop().ignore();
    _player?.dispose();
    super.dispose();
  }
}

import 'dart:async';

import 'package:l/l.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/media_stream.dart';

/// Plays the video of the video screen; hands the sound over to [BackgroundAudio] while the app
/// is in the background.
abstract interface class IVideoPlaybackRepository {
  /// Releases the open player, then plays the first of [sources] that YouTube serves, from
  /// [startAt]. Throws when none of them plays.
  Future<void> open(List<StreamSource> sources, {Duration startAt = Duration.zero});

  /// The open player; null until [open] succeeds.
  VideoPlayerController? get video;

  /// Where [video] plays from.
  StreamSource? get source;

  /// Position of [video]; zero when nothing is open.
  Duration get position;

  /// Whether [video] is playing, on every change; ends when the subscription is cancelled.
  Stream<bool> watchPlaying();

  /// Plays [video], from the start when it has finished.
  Future<void> play();

  Future<void> pause();

  /// Continues the sound of a playing [video] through the background audio player (with its
  /// media notification) from the current position. [audio] is the audio-only stream; the
  /// playing source is used when there is none.
  Future<void> continueInBackground({required MediaItem item, StreamSource? audio});

  /// Back from [continueInBackground]: moves the video to where the sound got to and stops the
  /// background audio.
  Future<void> returnToForeground();

  /// Stops playback and releases the player; the repository is not used afterwards.
  Future<void> close();
}

final class VideoPlaybackRepositoryImpl implements IVideoPlaybackRepository {
  VideoPlaybackRepositoryImpl({
    required this._backgroundAudio,
    VideoPlayerController Function(StreamSource source)? createController,
  }) : _createController = createController ?? _defaultController;

  final BackgroundAudio _backgroundAudio;
  final VideoPlayerController Function(StreamSource source) _createController;
  VideoPlayerController? _video;
  StreamSource? _source;
  bool _inBackground = false;
  bool _closed = false;

  static VideoPlayerController _defaultController(StreamSource source) =>
      VideoPlayerController.networkUrl(
        source.url,
        httpHeaders: source.headers,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false),
      );

  @override
  VideoPlayerController? get video => _video;

  @override
  StreamSource? get source => _source;

  @override
  Duration get position => _video?.value.position ?? Duration.zero;

  @override
  Future<void> open(List<StreamSource> sources, {Duration startAt = Duration.zero}) async {
    final previous = _video;
    _video = null;
    _source = null;
    await previous?.dispose();
    for (final source in sources) {
      if (_closed) return;
      final video = _createController(source);
      try {
        await video.initialize();
        l.d('Playback | playing from ${source.client}');
        // Closed while starting: nobody will release this player.
        if (_closed) {
          await video.dispose();
          return;
        }
        if (startAt > Duration.zero) await video.seekTo(startAt);
        await video.play();
        _video = video;
        _source = source;
        return;
      } on Object {
        // YouTube refused this source: try the next one.
        await video.dispose();
      }
    }
    if (!_closed) throw StateError('None of the ${sources.length} sources could be played');
  }

  @override
  Stream<bool> watchPlaying() {
    final video = _video;
    if (video == null) return const Stream.empty();
    final controller = StreamController<bool>();
    var playing = video.value.isPlaying;
    void listener() {
      if (controller.isClosed || video.value.isPlaying == playing) return;
      playing = video.value.isPlaying;
      controller.add(playing);
    }

    controller
      ..onListen = () {
        video.addListener(listener);
      }
      ..onCancel = () {
        video.removeListener(listener);
        if (!controller.isClosed) controller.close();
      };
    return controller.stream;
  }

  @override
  Future<void> play() async {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    if (video.value.isCompleted) await video.seekTo(Duration.zero);
    await video.play();
  }

  @override
  Future<void> pause() async => _video?.pause();

  @override
  Future<void> continueInBackground({required MediaItem item, StreamSource? audio}) async {
    final video = _video;
    final sound = audio ?? _source;
    if (video == null || sound == null || _inBackground || !video.value.isPlaying) return;
    final position = video.value.position;
    await video.pause();
    _inBackground = true;
    await _backgroundAudio.play(sound.url, headers: sound.headers, item: item, position: position);
  }

  @override
  Future<void> returnToForeground() async {
    if (!_inBackground) return;
    _inBackground = false;
    final player = _backgroundAudio.player;
    final position = player.position;
    final wasPlaying = player.playing;
    await _backgroundAudio.stop();
    final video = _video;
    if (video == null) return;
    await video.seekTo(position);
    if (wasPlaying) await video.play();
  }

  @override
  Future<void> close() async {
    _closed = true;
    final video = _video;
    _video = null;
    _source = null;
    if (_inBackground) {
      _inBackground = false;
      await _backgroundAudio.stop();
    }
    await video?.dispose();
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

/// Where playback of the open file is.
@immutable
class DownloadPlayback {
  const DownloadPlayback({required this.position, required this.duration, required this.isPlaying});

  static const empty = DownloadPlayback(
    position: Duration.zero,
    duration: Duration.zero,
    isPlaying: false,
  );

  final Duration position;
  final Duration duration;
  final bool isPlaying;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadPlayback &&
          other.position == position &&
          other.duration == duration &&
          other.isPlaying == isPlaying;

  @override
  int get hashCode => Object.hash(position, duration, isPlaying);

  @override
  String toString() => 'DownloadPlayback($position / $duration, playing: $isPlaying)';
}

/// Plays one downloaded file, looping.
abstract interface class IDownloadPlayerRepository {
  /// Opens [file] and starts playing it in a loop. Throws when it cannot be played.
  Future<void> open(DownloadedFile file);

  /// The current playback of the open file.
  DownloadPlayback get playback;

  /// Playback changes of the open file; ends when the subscription is cancelled.
  Stream<DownloadPlayback> watchPlayback();

  /// The picture of an open video file; null for audio.
  VideoPlayerController? get video;

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  /// Video files: keeps the sound going through the background audio player (with its media
  /// notification) from the current position while the app is in the background.
  /// Does nothing for audio files, which already play there.
  Future<void> continueInBackground();

  /// Video files: back from [continueInBackground] — moves the picture to where the sound got to
  /// and stops the background audio.
  Future<void> returnToForeground();

  /// Stops playback and releases the player.
  Future<void> close();
}

MediaItem _mediaItem(DownloadedFile file) => MediaItem(
  id: file.path,
  title: file.title,
  artist: file.channelName,
  artUri: switch (file.thumbnailUrl) {
    final url? when url.isNotEmpty => Uri.tryParse(url),
    _ => null,
  },
  duration: file.duration,
);

/// Starts [file] on the app's background audio player at [position] and completes once it plays.
///
/// `BackgroundAudio.play` completes only when playback stops, so it is not awaited directly.
Future<void> _playInBackground(
  BackgroundAudio audio,
  DownloadedFile file, {
  Duration position = Duration.zero,
}) async {
  // Stopping first resets the player state, so the readiness check below cannot be satisfied
  // by whatever was playing before.
  await audio.stop();
  final started = Completer<void>();
  final subscription = audio.player.playerStateStream.listen(
    (state) {
      if (state.playing && state.processingState == ProcessingState.ready && !started.isCompleted) {
        started.complete();
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!started.isCompleted) started.completeError(error, stackTrace);
    },
  );
  audio
      .play(Uri.file(file.path), item: _mediaItem(file), position: position, loopMode: LoopMode.one)
      .then(
        (_) {
          if (!started.isCompleted) started.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!started.isCompleted) started.completeError(error, stackTrace);
        },
      );
  try {
    await started.future;
  } finally {
    await subscription.cancel();
  }
}

/// Plays a downloaded video with `video_player`; hands the sound over to [BackgroundAudio]
/// while the app is in the background.
final class VideoFilePlayerRepository implements IDownloadPlayerRepository {
  VideoFilePlayerRepository({
    required this._backgroundAudio,
    VideoPlayerController Function(File file)? createController,
  }) : _createController = createController ?? _defaultController;

  final BackgroundAudio _backgroundAudio;
  final VideoPlayerController Function(File file) _createController;
  VideoPlayerController? _video;
  DownloadedFile? _file;
  bool _inBackground = false;

  // Background playback is allowed so video_player does not pause and resume the video by
  // itself on lifecycle changes; the hand-over to the audio player is done here instead.
  static VideoPlayerController _defaultController(File file) => VideoPlayerController.file(
    file,
    videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
  );

  @override
  VideoPlayerController? get video => _video;

  @override
  DownloadPlayback get playback => switch (_video) {
    final video? => _snapshot(video.value),
    null => DownloadPlayback.empty,
  };

  static DownloadPlayback _snapshot(VideoPlayerValue value) => DownloadPlayback(
    position: value.position,
    duration: value.duration,
    isPlaying: value.isPlaying,
  );

  @override
  Future<void> open(DownloadedFile file) async {
    await close();
    final video = _createController(File(file.path));
    _video = video;
    _file = file;
    await video.initialize();
    await video.setLooping(true);
    await video.play();
  }

  @override
  Stream<DownloadPlayback> watchPlayback() {
    final video = _video;
    if (video == null) return const Stream.empty();
    final controller = StreamController<DownloadPlayback>();
    void listener() {
      if (controller.isClosed) return;
      final value = video.value;
      if (value.hasError) {
        controller.addError(StateError(value.errorDescription ?? 'Video playback failed'));
      } else {
        controller.add(_snapshot(value));
      }
    }

    controller
      ..onListen = () {
        video.addListener(listener);
        listener();
      }
      ..onCancel = () {
        video.removeListener(listener);
        if (!controller.isClosed) controller.close();
      };
    return controller.stream;
  }

  @override
  Future<void> play() async => _video?.play();

  @override
  Future<void> pause() async => _video?.pause();

  @override
  Future<void> seek(Duration position) async => _video?.seekTo(position);

  @override
  Future<void> continueInBackground() async {
    final video = _video, file = _file;
    if (video == null || file == null || _inBackground || !video.value.isPlaying) return;
    _inBackground = true;
    // The audio starts before the video pauses, so the app keeps an active audio session while
    // it goes to the background; the video is muted meanwhile to avoid hearing both.
    final volume = video.value.volume;
    await video.setVolume(0);
    try {
      await _playInBackground(_backgroundAudio, file, position: video.value.position);
    } on Object {
      // The video keeps playing (background playback is allowed) when the hand-over fails.
      _inBackground = false;
      await video.setVolume(volume);
      rethrow;
    }
    await video.pause();
    await video.setVolume(volume);
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
    final video = _video;
    _video = null;
    _file = null;
    if (_inBackground) {
      _inBackground = false;
      await _backgroundAudio.stop();
    }
    await video?.dispose();
  }
}

/// Plays a downloaded audio file through the app's background audio player, so it has the
/// media notification and keeps playing in the background.
final class AudioFilePlayerRepository implements IDownloadPlayerRepository {
  AudioFilePlayerRepository({required this._backgroundAudio});

  final BackgroundAudio _backgroundAudio;
  bool _open = false;

  AudioPlayer get _player => _backgroundAudio.player;

  @override
  VideoPlayerController? get video => null;

  @override
  DownloadPlayback get playback => _open
      ? DownloadPlayback(
          position: _player.position,
          duration: _player.duration ?? Duration.zero,
          isPlaying: _player.playing,
        )
      : DownloadPlayback.empty;

  @override
  Future<void> open(DownloadedFile file) async {
    _open = true;
    await _playInBackground(_backgroundAudio, file);
    // Closed while starting: the start may have outrun the stop in close().
    if (!_open) await _backgroundAudio.stop();
  }

  @override
  Stream<DownloadPlayback> watchPlayback() {
    final controller = StreamController<DownloadPlayback>();
    final subscriptions = <StreamSubscription<Object?>>[];
    void emit(Object? _) {
      if (!controller.isClosed) controller.add(playback);
    }

    void fail(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }

    controller
      ..onListen = () {
        subscriptions.addAll([
          _player.positionStream.listen(emit, onError: fail),
          _player.durationStream.listen(emit, onError: fail),
          _player.playingStream.listen(emit, onError: fail),
          _player.playbackEventStream.listen(emit, onError: fail),
        ]);
      }
      ..onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        if (!controller.isClosed) await controller.close();
      };
    return controller.stream;
  }

  @override
  Future<void> play() async {
    // AudioPlayer.play completes only when playback pauses; its errors reach
    // playbackEventStream, which watchPlayback reports.
    _player.play().ignore();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> continueInBackground() async {}

  @override
  Future<void> returnToForeground() async {}

  @override
  Future<void> close() async {
    if (!_open) return;
    _open = false;
    await _backgroundAudio.stop();
  }
}

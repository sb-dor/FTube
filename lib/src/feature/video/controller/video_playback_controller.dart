import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video/data/video_playback_repository.dart';

part 'video_playback_controller.freezed.dart';

@freezed
sealed class VideoPlaybackState with _$VideoPlaybackState {
  const factory VideoPlaybackState.initial() = VideoPlayback$InitialState;

  /// Looking for a source YouTube serves.
  const factory VideoPlaybackState.inProgress() = VideoPlayback$InProgressState;

  /// None of the sources could be played.
  const factory VideoPlaybackState.error({Object? error}) = VideoPlayback$ErrorState;

  /// [video] plays from [source].
  const factory VideoPlaybackState.completed({
    required VideoPlayerController video,
    required StreamSource source,
    required bool isPlaying,
  }) = VideoPlayback$CompletedState;
}

/// Plays the video of the video screen, falling back between the sources of a stream, and hands
/// the sound over to the background audio player while the app is in the background.
final class VideoPlaybackController extends StateController<VideoPlaybackState>
    with SequentialControllerHandler {
  VideoPlaybackController({
    required this._videoPlaybackRepository,
    super.initialState = const VideoPlaybackState.initial(),
  });

  final IVideoPlaybackRepository _videoPlaybackRepository;
  StreamSubscription<bool>? _subscription;

  /// Plays the first of [sources] that YouTube serves, from [startAt].
  void open(List<StreamSource> sources, {Duration startAt = Duration.zero}) => handle(
    () => _open(sources, startAt),
    error: (error, stackTrace) async => setState(VideoPlaybackState.error(error: error)),
    name: 'open',
  );

  /// Switches to [sources] (another quality) and continues from the current position.
  void switchSources(List<StreamSource> sources) => handle(
    () => _open(sources, _videoPlaybackRepository.position),
    error: (error, stackTrace) async => setState(VideoPlaybackState.error(error: error)),
    name: 'switchSources',
  );

  Future<void> _open(List<StreamSource> sources, Duration startAt) async {
    await _subscription?.cancel();
    _subscription = null;
    setState(const VideoPlaybackState.inProgress());
    await _videoPlaybackRepository.open(sources, startAt: startAt);
    final video = _videoPlaybackRepository.video;
    final source = _videoPlaybackRepository.source;
    // Disposed while opening.
    if (video == null || source == null || isDisposed) return;
    setState(
      VideoPlaybackState.completed(video: video, source: source, isPlaying: video.value.isPlaying),
    );
    _subscription = _videoPlaybackRepository.watchPlaying().listen((isPlaying) {
      final current = state;
      if (isDisposed || current is! VideoPlayback$CompletedState) return;
      setState(current.copyWith(isPlaying: isPlaying));
    });
  }

  void togglePlay() => handle(() async {
    final current = state;
    if (current is! VideoPlayback$CompletedState) return;
    setState(current.copyWith(isPlaying: !current.isPlaying));
    if (current.isPlaying) {
      await _videoPlaybackRepository.pause();
    } else {
      await _videoPlaybackRepository.play();
    }
  }, name: 'togglePlay');

  /// Stops playback without releasing the player (another video takes over the screen).
  void pause() => handle(() async {
    final current = state;
    if (current is VideoPlayback$CompletedState) setState(current.copyWith(isPlaying: false));
    await _videoPlaybackRepository.pause();
  }, name: 'pause');

  /// The app went to the background: a playing video continues as background audio, from
  /// [audio] when the video has an audio-only stream.
  void appPaused({required MediaItem item, StreamSource? audio}) => handle(
    () => _videoPlaybackRepository.continueInBackground(item: item, audio: audio),
    name: 'appPaused',
  );

  /// The app is back: the video continues from where the background audio got to.
  void appResumed() => handle(_videoPlaybackRepository.returnToForeground, name: 'appResumed');

  /// Stops playback and releases the player.
  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    _videoPlaybackRepository.close().ignore();
    super.dispose();
  }
}

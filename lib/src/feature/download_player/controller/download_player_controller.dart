import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/feature/download_player/data/download_player_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

part 'download_player_controller.freezed.dart';

@freezed
sealed class DownloadPlayerState with _$DownloadPlayerState {
  const DownloadPlayerState._();

  const factory DownloadPlayerState.initial() = DownloadPlayer$InitialState;

  const factory DownloadPlayerState.inProgress() = DownloadPlayer$InProgressState;

  const factory DownloadPlayerState.error({Object? error}) = DownloadPlayer$ErrorState;

  /// The file is open. [video] is the picture of a video file; null for audio.
  const factory DownloadPlayerState.completed({
    required Duration position,
    required Duration duration,
    required bool isPlaying,
    VideoPlayerController? video,
  }) = DownloadPlayer$CompletedState;
}

/// Plays one downloaded file in a loop; for video files, hands the sound over to the background
/// audio player while the app is in the background.
final class DownloadPlayerController extends StateController<DownloadPlayerState>
    with SequentialControllerHandler {
  DownloadPlayerController({
    required this._downloadPlayerRepository,
    super.initialState = const DownloadPlayerState.initial(),
  });

  final IDownloadPlayerRepository _downloadPlayerRepository;
  StreamSubscription<DownloadPlayback>? _subscription;

  /// Opens [file] and starts playing it.
  void open(DownloadedFile file) => handle(
    () async {
      await _subscription?.cancel();
      _subscription = null;
      setState(const DownloadPlayerState.inProgress());
      await _downloadPlayerRepository.open(file);
      _update(_downloadPlayerRepository.playback);
      _subscription = _downloadPlayerRepository.watchPlayback().listen(
        _update,
        onError: (Object error, StackTrace stackTrace) {
          if (!isDisposed) setState(DownloadPlayerState.error(error: error));
        },
      );
    },
    error: (error, stackTrace) async => setState(DownloadPlayerState.error(error: error)),
    name: 'open',
  );

  void _update(DownloadPlayback playback) {
    if (isDisposed) return;
    setState(
      DownloadPlayerState.completed(
        position: playback.position,
        duration: playback.duration,
        isPlaying: playback.isPlaying,
        video: _downloadPlayerRepository.video,
      ),
    );
  }

  void play() => handle(() async {
    final current = state;
    if (current is! DownloadPlayer$CompletedState) return;
    setState(current.copyWith(isPlaying: true));
    await _downloadPlayerRepository.play();
  }, name: 'play');

  void pause() => handle(() async {
    final current = state;
    if (current is! DownloadPlayer$CompletedState) return;
    setState(current.copyWith(isPlaying: false));
    await _downloadPlayerRepository.pause();
  }, name: 'pause');

  void togglePlay() => switch (state) {
    DownloadPlayer$CompletedState(isPlaying: true) => pause(),
    DownloadPlayer$CompletedState() => play(),
    _ => null,
  };

  /// The user started dragging the seek bar: playback pauses until [seekEnd].
  void seekStart() => pause();

  /// The user released the seek bar at [position]: playback continues from there.
  void seekEnd(Duration position) => handle(() async {
    final current = state;
    if (current is! DownloadPlayer$CompletedState) return;
    final target = position < Duration.zero
        ? Duration.zero
        : (current.duration > Duration.zero && position > current.duration
              ? current.duration
              : position);
    setState(current.copyWith(position: target, isPlaying: true));
    await _downloadPlayerRepository.seek(target);
    await _downloadPlayerRepository.play();
  }, name: 'seekEnd');

  /// The app went to the background: a playing video continues as background audio.
  void appPaused() => handle(() async {
    final current = state;
    if (current is! DownloadPlayer$CompletedState || !current.isPlaying) return;
    await _downloadPlayerRepository.continueInBackground();
  }, name: 'appPaused');

  /// The app is back: the video continues from where the background audio got to.
  void appResumed() => handle(_downloadPlayerRepository.returnToForeground, name: 'appResumed');

  /// Stops playback and releases the player.
  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    _downloadPlayerRepository.close().ignore();
    super.dispose();
  }
}

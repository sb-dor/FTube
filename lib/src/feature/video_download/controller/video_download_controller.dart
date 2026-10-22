import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';

part 'video_download_controller.freezed.dart';

@freezed
sealed class VideoDownloadState with _$VideoDownloadState {
  const VideoDownloadState._();

  const factory VideoDownloadState.idle() = VideoDownload$IdleState;

  const factory VideoDownloadState.inProgress({
    required DownloadRequest request,
    required DownloadProgress progress,
  }) = VideoDownload$InProgressState;

  const factory VideoDownloadState.completed({required DownloadRequest request}) =
      VideoDownload$CompletedState;

  const factory VideoDownloadState.error({required DownloadRequest request, Object? error}) =
      VideoDownload$ErrorState;

  /// The request this state is about; null when idle.
  DownloadRequest? get activeRequest => switch (this) {
    VideoDownload$IdleState() => null,
    VideoDownload$InProgressState(:final request) ||
    VideoDownload$CompletedState(:final request) ||
    VideoDownload$ErrorState(:final request) => request,
  };

  bool get isDownloading => this is VideoDownload$InProgressState;
}

/// The app-wide download. One download runs at a time and keeps running while the user moves
/// around the app.
final class VideoDownloadController extends StateController<VideoDownloadState>
    with DroppableControllerHandler {
  VideoDownloadController({
    required this._repository,
    super.initialState = const VideoDownloadState.idle(),
  });

  final IVideoDownloadRepository _repository;
  StreamSubscription<DownloadProgress>? _subscription;
  Completer<bool>? _finished;

  /// Starts [request]. Returns false (and does nothing) while another download is running.
  bool start(DownloadRequest request) {
    if (state.isDownloading) return false;
    handle(
      () async {
        setState(
          VideoDownloadState.inProgress(
            request: request,
            progress: const DownloadProgress(phase: DownloadPhase.downloading),
          ),
        );
        // Completes with true when the download finished, false when cancelled.
        final finished = _finished = Completer<bool>();
        _subscription = _repository
            .download(request)
            .listen(
              (progress) =>
                  setState(VideoDownloadState.inProgress(request: request, progress: progress)),
              onError: (Object error, StackTrace stackTrace) {
                if (!finished.isCompleted) finished.completeError(error, stackTrace);
              },
              onDone: () {
                if (!finished.isCompleted) finished.complete(true);
              },
            );
        try {
          if (await finished.future) setState(VideoDownloadState.completed(request: request));
        } finally {
          _subscription = null;
          _finished = null;
        }
      },
      error: (error, stackTrace) async =>
          setState(VideoDownloadState.error(request: request, error: error)),
      name: 'start',
    );
    return true;
  }

  /// Stops the running download and deletes its partial files.
  void cancel() {
    final subscription = _subscription;
    final finished = _finished;
    if (subscription == null || finished == null) return;
    subscription.cancel().ignore();
    if (!finished.isCompleted) finished.complete(false);
    setState(const VideoDownloadState.idle());
  }

  /// Clears a finished or failed download.
  void reset() {
    if (state.isDownloading) return;
    setState(const VideoDownloadState.idle());
  }

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}

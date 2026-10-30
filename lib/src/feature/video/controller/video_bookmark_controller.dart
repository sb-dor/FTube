import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

part 'video_bookmark_controller.freezed.dart';

@freezed
sealed class VideoBookmarkState with _$VideoBookmarkState {
  const VideoBookmarkState._();

  const factory VideoBookmarkState.initial() = VideoBookmark$InitialState;

  const factory VideoBookmarkState.inProgress() = VideoBookmark$InProgressState;

  const factory VideoBookmarkState.error({Object? error}) = VideoBookmark$ErrorState;

  /// [saved]: the video is in at least one playlist.
  const factory VideoBookmarkState.completed({required bool saved}) = VideoBookmark$CompletedState;

  /// False until it is known.
  bool get isSaved => switch (this) {
    VideoBookmark$CompletedState(:final saved) => saved,
    _ => false,
  };
}

/// Follows whether the video is saved in any playlist.
final class VideoBookmarkController extends StateController<VideoBookmarkState>
    with SequentialControllerHandler {
  VideoBookmarkController({
    required this._videoLibraryRepository,
    super.initialState = const VideoBookmarkState.initial(),
  });

  final IVideoLibraryRepository _videoLibraryRepository;
  StreamSubscription<bool>? _subscription;

  /// Follows the saved state of [videoId].
  void watch(String videoId) => handle(
    () async {
      await _subscription?.cancel();
      _subscription = null;
      setState(const VideoBookmarkState.inProgress());
      _subscription = _videoLibraryRepository
          .watchInPlaylist(videoId)
          .listen(
            (saved) {
              if (!isDisposed) setState(VideoBookmarkState.completed(saved: saved));
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!isDisposed) setState(VideoBookmarkState.error(error: error));
            },
          );
    },
    error: (error, stackTrace) async => setState(VideoBookmarkState.error(error: error)),
    name: 'watch',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    super.dispose();
  }
}

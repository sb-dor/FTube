import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

part 'video_like_controller.freezed.dart';

@freezed
sealed class VideoLikeState with _$VideoLikeState {
  const VideoLikeState._();

  const factory VideoLikeState.initial() = VideoLike$InitialState;

  const factory VideoLikeState.inProgress() = VideoLike$InProgressState;

  const factory VideoLikeState.error({Object? error}) = VideoLike$ErrorState;

  const factory VideoLikeState.completed({required bool liked}) = VideoLike$CompletedState;

  /// False until the liked state is known.
  bool get isLiked => switch (this) {
    VideoLike$CompletedState(:final liked) => liked,
    _ => false,
  };
}

/// Follows whether the video is liked. Toggling it is [VideoLikeToggleController]'s job.
final class VideoLikeController extends StateController<VideoLikeState>
    with SequentialControllerHandler {
  VideoLikeController({
    required this._videoLibraryRepository,
    super.initialState = const VideoLikeState.initial(),
  });

  final IVideoLibraryRepository _videoLibraryRepository;
  StreamSubscription<bool>? _subscription;

  /// Follows the liked state of [videoId].
  void watch(String videoId) => handle(
    () async {
      await _subscription?.cancel();
      _subscription = null;
      setState(const VideoLikeState.inProgress());
      _subscription = _videoLibraryRepository
          .watchLiked(videoId)
          .listen(
            (liked) {
              if (!isDisposed) setState(VideoLikeState.completed(liked: liked));
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!isDisposed) setState(VideoLikeState.error(error: error));
            },
          );
    },
    error: (error, stackTrace) async => setState(VideoLikeState.error(error: error)),
    name: 'watch',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    super.dispose();
  }
}

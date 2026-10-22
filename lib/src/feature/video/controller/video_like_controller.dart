import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

part 'video_like_controller.freezed.dart';

@freezed
sealed class VideoLikeState with _$VideoLikeState {
  const factory VideoLikeState.unknown() = VideoLike$UnknownState;

  const factory VideoLikeState.ready({required bool liked}) = VideoLike$ReadyState;
}

/// Whether the video is liked, and toggling it.
final class VideoLikeController extends StateController<VideoLikeState>
    with DroppableControllerHandler {
  VideoLikeController({
    required this._repository,
    super.initialState = const VideoLikeState.unknown(),
  });

  final IVideoLibraryRepository _repository;
  StreamSubscription<bool>? _subscription;

  /// Follows the liked state of [videoId].
  void watch(String videoId) {
    _subscription?.cancel().ignore();
    _subscription = _repository
        .watchLiked(videoId)
        .listen((liked) => setState(VideoLikeState.ready(liked: liked)), onError: onError);
  }

  void toggle(VideoItem video) => handle(() async {
    final current = state;
    if (current is! VideoLike$ReadyState) return;
    await _repository.setLiked(video, liked: !current.liked);
  }, name: 'toggle');

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}

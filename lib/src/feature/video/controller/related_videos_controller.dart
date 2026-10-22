import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/feature/video/data/video_repository.dart';

part 'related_videos_controller.freezed.dart';

@freezed
sealed class RelatedVideosState with _$RelatedVideosState {
  const RelatedVideosState._();

  const factory RelatedVideosState.initial() = RelatedVideos$InitialState;

  const factory RelatedVideosState.error({Object? error}) = RelatedVideos$ErrorState;

  /// [continuation] requests the next page; null when there is none.
  const factory RelatedVideosState.completed({
    required List<VideoItem> videos,
    required String? continuation,
  }) = RelatedVideos$CompletedState;

  bool get hasMore => switch (this) {
    RelatedVideos$CompletedState(:final continuation) => continuation != null,
    _ => false,
  };
}

/// Related ("similar") videos under the player. The first page arrives with the video
/// details; further pages load on scroll.
final class RelatedVideosController extends StateController<RelatedVideosState>
    with SequentialControllerHandler {
  RelatedVideosController({
    required this._repository,
    super.initialState = const RelatedVideosState.initial(),
  });

  final IVideoRepository _repository;

  /// Shows the first page delivered with the video details.
  void show(VideoPage page) =>
      setState(RelatedVideosState.completed(videos: page.videos, continuation: page.continuation));

  void fail(Object? error) => setState(RelatedVideosState.error(error: error));

  void paginate() => handle(
    () async {
      final current = state;
      if (current is! RelatedVideos$CompletedState) return;
      final continuation = current.continuation;
      if (continuation == null) return;
      final page = await _repository.related(continuation);
      final known = {for (final video in current.videos) video.id};
      setState(
        RelatedVideosState.completed(
          videos: [...current.videos, ...page.videos.where((v) => !known.contains(v.id))],
          continuation: page.continuation,
        ),
      );
    },
    error: (error, stackTrace) async => setState(RelatedVideosState.error(error: error)),
    name: 'paginate',
  );
}

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/feed/data/feed_repository.dart';

part 'feed_controller.freezed.dart';

@freezed
sealed class FeedState with _$FeedState {
  const FeedState._();

  const factory FeedState.initial() = Feed$InitialState;

  const factory FeedState.inProgress() = Feed$InProgressState;

  const factory FeedState.error({Object? error}) = Feed$ErrorState;

  /// [continuation] requests the next page; null when there is none.
  const factory FeedState.completed({
    required List<VideoItem> videos,
    required String? continuation,
  }) = Feed$CompletedState;

  /// Whether another page can be requested.
  bool get hasMore => switch (this) {
    Feed$CompletedState(:final continuation) => continuation != null,
    _ => false,
  };
}

/// Loads the home feed and its next pages.
final class FeedController extends StateController<FeedState> with SequentialControllerHandler {
  FeedController({required this._feedRepository, super.initialState = const FeedState.initial()});

  final IFeedRepository _feedRepository;

  void load({required String query, String? filter}) => handle(
    () async {
      setState(const FeedState.inProgress());
      final page = await _feedRepository.videos(query: query, filter: filter);
      setState(FeedState.completed(videos: page.videos, continuation: page.continuation));
    },
    error: (error, stackTrace) async => setState(FeedState.error(error: error)),
    name: 'load',
  );

  void paginate({required String query, String? filter}) => handle(
    () async {
      final current = state;
      if (current is! Feed$CompletedState) return;
      final continuation = current.continuation;
      if (continuation == null) return;
      final page = await _feedRepository.videos(
        query: query,
        filter: filter,
        continuation: continuation,
      );
      final known = {for (final video in current.videos) video.id};
      setState(
        FeedState.completed(
          videos: [...current.videos, ...page.videos.where((video) => !known.contains(video.id))],
          continuation: page.continuation,
        ),
      );
    },
    error: (error, stackTrace) async => setState(FeedState.error(error: error)),
    name: 'paginate',
  );
}

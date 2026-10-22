import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/trending/data/trending_repository.dart';

part 'trending_controller.freezed.dart';

@freezed
sealed class TrendingState with _$TrendingState {
  const TrendingState._();

  const factory TrendingState.initial() = Trending$InitialState;

  const factory TrendingState.inProgress() = Trending$InProgressState;

  const factory TrendingState.error({Object? error}) = Trending$ErrorState;

  /// [continuation] requests the next page; null when there is none.
  const factory TrendingState.completed({
    required List<VideoItem> videos,
    required String? continuation,
  }) = Trending$CompletedState;

  /// Whether another page can be requested.
  bool get hasMore => switch (this) {
    Trending$CompletedState(:final continuation) => continuation != null,
    _ => false,
  };
}

/// Loads the trending videos of the selected category and their next pages.
final class TrendingController extends StateController<TrendingState>
    with SequentialControllerHandler {
  TrendingController({
    required this._trendingRepository,
    super.initialState = const TrendingState.initial(),
  });

  final ITrendingRepository _trendingRepository;

  void load({required String query, required String filter}) => handle(
    () async {
      setState(const TrendingState.inProgress());
      final page = await _trendingRepository.videos(query: query, filter: filter);
      setState(TrendingState.completed(videos: page.videos, continuation: page.continuation));
    },
    error: (error, stackTrace) async => setState(TrendingState.error(error: error)),
    name: 'load',
  );

  void paginate({required String query, required String filter}) => handle(
    () async {
      final current = state;
      if (current is! Trending$CompletedState) return;
      final continuation = current.continuation;
      if (continuation == null) return;
      final page = await _trendingRepository.videos(
        query: query,
        filter: filter,
        continuation: continuation,
      );
      final known = {for (final video in current.videos) video.id};
      setState(
        TrendingState.completed(
          videos: [...current.videos, ...page.videos.where((video) => !known.contains(video.id))],
          continuation: page.continuation,
        ),
      );
    },
    error: (error, stackTrace) async => setState(TrendingState.error(error: error)),
    name: 'paginate',
  );
}

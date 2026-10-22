import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlist_videos/data/playlist_videos_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

part 'playlist_videos_controller.freezed.dart';

@freezed
sealed class PlaylistVideosState with _$PlaylistVideosState {
  const PlaylistVideosState._();

  const factory PlaylistVideosState.initial() = PlaylistVideos$InitialState;

  const factory PlaylistVideosState.inProgress() = PlaylistVideos$InProgressState;

  const factory PlaylistVideosState.error({Object? error}) = PlaylistVideos$ErrorState;

  /// [limit] is how many of the newest videos are watched; the next page watches
  /// `limit + pageSize`.
  const factory PlaylistVideosState.completed({
    required List<VideoItem> videos,
    required int limit,
    required bool hasMore,
  }) = PlaylistVideos$CompletedState;

  /// Whether another page can be requested.
  bool get canLoadMore => switch (this) {
    PlaylistVideos$CompletedState(:final hasMore) => hasMore,
    _ => false,
  };
}

/// Watches the videos of one playlist (or the liked videos) page by page, newest first.
final class PlaylistVideosController extends StateController<PlaylistVideosState>
    with SequentialControllerHandler {
  PlaylistVideosController({
    required this._playlistVideosRepository,
    this._pageSize = 15,
    super.initialState = const PlaylistVideosState.initial(),
  });

  final IPlaylistVideosRepository _playlistVideosRepository;
  final int _pageSize;
  StreamSubscription<PlaylistVideosPage>? _subscription;
  Completer<void>? _firstPage;

  /// Watches the first page of [playlist].
  void load({required PlaylistSummary playlist}) => handle(
    () async {
      setState(const PlaylistVideosState.inProgress());
      await _watch(playlist, _pageSize);
    },
    error: (error, stackTrace) async => setState(PlaylistVideosState.error(error: error)),
    name: 'load',
  );

  /// Widens the watched window by one page.
  void paginate({required PlaylistSummary playlist}) => handle(
    () async {
      final current = state;
      if (current is! PlaylistVideos$CompletedState || !current.hasMore) return;
      await _watch(playlist, current.limit + _pageSize);
    },
    error: (error, stackTrace) async => setState(PlaylistVideosState.error(error: error)),
    name: 'paginate',
  );

  /// Replaces the subscription and waits for its first value.
  Future<void> _watch(PlaylistSummary playlist, int limit) async {
    await _subscription?.cancel();
    final firstPage = _firstPage = Completer<void>();
    _subscription = _playlistVideosRepository
        .watchVideos(playlist: playlist, limit: limit)
        .listen(
          (page) {
            setState(
              PlaylistVideosState.completed(
                videos: page.videos,
                limit: limit,
                hasMore: page.hasMore,
              ),
            );
            if (!firstPage.isCompleted) firstPage.complete();
          },
          onError: (Object error, StackTrace stackTrace) {
            setState(PlaylistVideosState.error(error: error));
            if (!firstPage.isCompleted) firstPage.complete();
          },
        );
    await firstPage.future;
  }

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    if (_firstPage case final firstPage? when !firstPage.isCompleted) firstPage.complete();
    super.dispose();
  }
}

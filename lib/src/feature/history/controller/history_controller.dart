import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/history/data/history_repository.dart';

part 'history_controller.freezed.dart';

@freezed
sealed class HistoryState with _$HistoryState {
  const HistoryState._();

  const factory HistoryState.initial() = History$InitialState;

  const factory HistoryState.inProgress() = History$InProgressState;

  const factory HistoryState.error({Object? error}) = History$ErrorState;

  /// [limit] is how many of the newest videos are watched; the next page watches
  /// `limit + pageSize`.
  const factory HistoryState.completed({
    required List<VideoItem> videos,
    required int limit,
    required bool hasMore,
  }) = History$CompletedState;

  /// Whether another page can be requested.
  bool get canLoadMore => switch (this) {
    History$CompletedState(:final hasMore) => hasMore,
    _ => false,
  };
}

/// Watches the watch history page by page, newest first.
///
/// Each page widens the watched window, so removals, clears and newly watched videos show up
/// without a reload.
final class HistoryController extends StateController<HistoryState>
    with SequentialControllerHandler {
  HistoryController({
    required this._historyRepository,
    this._pageSize = 15,
    super.initialState = const HistoryState.initial(),
  });

  final IHistoryRepository _historyRepository;
  final int _pageSize;
  StreamSubscription<VideoListPage>? _subscription;
  Completer<void>? _firstPage;

  /// Watches the first page.
  void load() => handle(
    () async {
      setState(const HistoryState.inProgress());
      await _watch(_pageSize);
    },
    error: (error, stackTrace) async => setState(HistoryState.error(error: error)),
    name: 'load',
  );

  /// Widens the watched window by one page.
  void paginate() => handle(
    () async {
      final current = state;
      if (current is! History$CompletedState || !current.hasMore) return;
      await _watch(current.limit + _pageSize);
    },
    error: (error, stackTrace) async => setState(HistoryState.error(error: error)),
    name: 'paginate',
  );

  /// Replaces the subscription and waits for its first value, so the handler stays busy until
  /// the page is on screen.
  Future<void> _watch(int limit) async {
    await _subscription?.cancel();
    final firstPage = _firstPage = Completer<void>();
    _subscription = _historyRepository
        .watchHistory(limit: limit)
        .listen(
          (page) {
            setState(
              HistoryState.completed(videos: page.videos, limit: limit, hasMore: page.hasMore),
            );
            if (!firstPage.isCompleted) firstPage.complete();
          },
          onError: (Object error, StackTrace stackTrace) {
            setState(HistoryState.error(error: error));
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

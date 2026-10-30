import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/downloads/data/downloads_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

part 'downloads_controller.freezed.dart';

@freezed
sealed class DownloadsState with _$DownloadsState {
  const DownloadsState._();

  const factory DownloadsState.initial() = Downloads$InitialState;

  const factory DownloadsState.inProgress() = Downloads$InProgressState;

  const factory DownloadsState.error({Object? error}) = Downloads$ErrorState;

  /// [downloads] newest first. [limit] is how many of the newest files are watched; the next
  /// page watches `limit + pageSize`.
  const factory DownloadsState.completed({
    required List<DownloadedFile> downloads,
    required int limit,
    required bool hasMore,
  }) = Downloads$CompletedState;

  /// Whether another page can be requested.
  bool get canLoadMore => switch (this) {
    Downloads$CompletedState(:final hasMore) => hasMore,
    _ => false,
  };
}

/// Watches the downloaded files page by page, newest first.
///
/// Each page widens the watched window, so added and deleted downloads show up without a
/// reload.
final class DownloadsController extends StateController<DownloadsState>
    with SequentialControllerHandler {
  DownloadsController({
    required this._downloadsRepository,
    this._pageSize = 20,
    super.initialState = const DownloadsState.initial(),
  });

  final IDownloadsRepository _downloadsRepository;
  final int _pageSize;
  StreamSubscription<DownloadsPage>? _subscription;
  Completer<void>? _firstPage;

  /// Watches the first page.
  void load() => handle(
    () async {
      setState(const DownloadsState.inProgress());
      await _watch(_pageSize);
    },
    error: (error, stackTrace) async => setState(DownloadsState.error(error: error)),
    name: 'load',
  );

  /// Widens the watched window by one page.
  void paginate() => handle(
    () async {
      final current = state;
      if (current is! Downloads$CompletedState || !current.hasMore) return;
      await _watch(current.limit + _pageSize);
    },
    error: (error, stackTrace) async => setState(DownloadsState.error(error: error)),
    name: 'paginate',
  );

  /// Replaces the subscription and waits for its first value, so the handler stays busy until
  /// the page is on screen.
  Future<void> _watch(int limit) async {
    await _subscription?.cancel();
    final firstPage = _firstPage = Completer<void>();
    _subscription = _downloadsRepository
        .watchDownloads(limit: limit)
        .listen(
          (page) {
            setState(
              DownloadsState.completed(
                downloads: page.downloads,
                limit: limit,
                hasMore: page.hasMore,
              ),
            );
            if (!firstPage.isCompleted) firstPage.complete();
          },
          onError: (Object error, StackTrace stackTrace) {
            setState(DownloadsState.error(error: error));
            if (!firstPage.isCompleted) firstPage.complete();
          },
        );
    await firstPage.future;
  }

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    if (_firstPage case final firstPage? when !firstPage.isCompleted) firstPage.complete();
    super.dispose();
  }
}

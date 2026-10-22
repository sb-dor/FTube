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

  /// [downloads] newest first.
  const factory DownloadsState.completed({required List<DownloadedFile> downloads}) =
      Downloads$CompletedState;
}

/// Watches the downloaded files; the list updates whenever a download is added or deleted.
final class DownloadsController extends StateController<DownloadsState>
    with SequentialControllerHandler {
  DownloadsController({
    required this._downloadsRepository,
    super.initialState = const DownloadsState.initial(),
  });

  final IDownloadsRepository _downloadsRepository;
  StreamSubscription<List<DownloadedFile>>? _subscription;

  /// Starts (or restarts) watching the downloads table.
  void watch() => handle(
    () async {
      await _subscription?.cancel();
      _subscription = null;
      setState(const DownloadsState.inProgress());
      _subscription = _downloadsRepository.watchDownloads().listen(
        (downloads) {
          if (!isDisposed) setState(DownloadsState.completed(downloads: downloads));
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!isDisposed) setState(DownloadsState.error(error: error));
        },
      );
    },
    error: (error, stackTrace) async => setState(DownloadsState.error(error: error)),
    name: 'watch',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    _subscription = null;
    super.dispose();
  }
}

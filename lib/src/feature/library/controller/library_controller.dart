import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/library/data/library_repository.dart';
import 'package:youtube/src/feature/library/models/library_overview.dart';

part 'library_controller.freezed.dart';

@freezed
sealed class LibraryState with _$LibraryState {
  const LibraryState._();

  const factory LibraryState.initial() = Library$InitialState;

  const factory LibraryState.inProgress() = Library$InProgressState;

  const factory LibraryState.error({Object? error}) = Library$ErrorState;

  const factory LibraryState.completed({required LibraryOverview overview}) =
      Library$CompletedState;
}

/// Watches the library overview: recent history, playlists and the downloads count.
final class LibraryController extends StateController<LibraryState>
    with SequentialControllerHandler {
  LibraryController({
    required this._libraryRepository,
    super.initialState = const LibraryState.initial(),
  });

  final ILibraryRepository _libraryRepository;
  StreamSubscription<LibraryOverview>? _subscription;

  /// Starts (or restarts) watching the overview.
  void watch() => handle(
    () async {
      setState(const LibraryState.inProgress());
      await _subscription?.cancel();
      _subscription = _libraryRepository.watchOverview().listen(
        (overview) => setState(LibraryState.completed(overview: overview)),
        onError: (Object error, StackTrace stackTrace) =>
            setState(LibraryState.error(error: error)),
      );
    },
    error: (error, stackTrace) async => setState(LibraryState.error(error: error)),
    name: 'watch',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}

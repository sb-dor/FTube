import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/playlists/data/playlists_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

part 'playlists_controller.freezed.dart';

@freezed
sealed class PlaylistsState with _$PlaylistsState {
  const PlaylistsState._();

  const factory PlaylistsState.initial() = Playlists$InitialState;

  const factory PlaylistsState.inProgress() = Playlists$InProgressState;

  const factory PlaylistsState.error({Object? error}) = Playlists$ErrorState;

  const factory PlaylistsState.completed({required List<PlaylistSummary> playlists}) =
      Playlists$CompletedState;
}

/// Watches all playlists, including the virtual "Liked videos" one.
final class PlaylistsController extends StateController<PlaylistsState>
    with SequentialControllerHandler {
  PlaylistsController({
    required this._playlistsRepository,
    super.initialState = const PlaylistsState.initial(),
  });

  final IPlaylistsRepository _playlistsRepository;
  StreamSubscription<List<PlaylistSummary>>? _subscription;

  /// Starts (or restarts) watching the playlists.
  void watch() => handle(
    () async {
      setState(const PlaylistsState.inProgress());
      await _subscription?.cancel();
      _subscription = _playlistsRepository.watchPlaylists().listen(
        (playlists) => setState(PlaylistsState.completed(playlists: playlists)),
        onError: (Object error, StackTrace stackTrace) =>
            setState(PlaylistsState.error(error: error)),
      );
    },
    error: (error, stackTrace) async => setState(PlaylistsState.error(error: error)),
    name: 'watch',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}

import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/playlist_selection/data/playlist_selection_repository.dart';
import 'package:youtube/src/feature/playlist_selection/models/playlist_option.dart';

part 'playlist_selection_controller.freezed.dart';

@freezed
sealed class PlaylistSelectionState with _$PlaylistSelectionState {
  const PlaylistSelectionState._();

  const factory PlaylistSelectionState.initial() = PlaylistSelection$InitialState;

  const factory PlaylistSelectionState.inProgress() = PlaylistSelection$InProgressState;

  const factory PlaylistSelectionState.error({Object? error}) = PlaylistSelection$ErrorState;

  /// [currentPlaylistId] is the playlist that contained the video when the sheet opened.
  const factory PlaylistSelectionState.completed({
    required List<PlaylistOption> playlists,
    required int? currentPlaylistId,
  }) = PlaylistSelection$CompletedState;
}

/// Watches the playlists a video can be saved into and knows which one holds it now.
final class PlaylistSelectionController extends StateController<PlaylistSelectionState>
    with SequentialControllerHandler {
  PlaylistSelectionController({
    required this._playlistSelectionRepository,
    super.initialState = const PlaylistSelectionState.initial(),
  });

  final IPlaylistSelectionRepository _playlistSelectionRepository;
  StreamSubscription<List<PlaylistOption>>? _subscription;

  void load({required String videoId}) => handle(
    () async {
      setState(const PlaylistSelectionState.inProgress());
      await _subscription?.cancel();
      final currentPlaylistId = await _playlistSelectionRepository.playlistOf(videoId);
      _subscription = _playlistSelectionRepository.watchPlaylists().listen(
        (playlists) => setState(
          PlaylistSelectionState.completed(
            playlists: playlists,
            currentPlaylistId: currentPlaylistId,
          ),
        ),
        onError: (Object error, StackTrace stackTrace) =>
            setState(PlaylistSelectionState.error(error: error)),
      );
    },
    error: (error, stackTrace) async => setState(PlaylistSelectionState.error(error: error)),
    name: 'load',
  );

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/playlist_deletion/data/playlist_deletion_repository.dart';

part 'playlist_deletion_controller.freezed.dart';

@freezed
sealed class PlaylistDeletionState with _$PlaylistDeletionState {
  const PlaylistDeletionState._();

  const factory PlaylistDeletionState.initial() = PlaylistDeletion$InitialState;

  const factory PlaylistDeletionState.inProgress() = PlaylistDeletion$InProgressState;

  const factory PlaylistDeletionState.error({Object? error}) = PlaylistDeletion$ErrorState;

  const factory PlaylistDeletionState.completed() = PlaylistDeletion$CompletedState;
}

/// Deletes a playlist together with its videos.
final class PlaylistDeletionController extends StateController<PlaylistDeletionState>
    with DroppableControllerHandler {
  PlaylistDeletionController({
    required this._playlistDeletionRepository,
    super.initialState = const PlaylistDeletionState.initial(),
  });

  final IPlaylistDeletionRepository _playlistDeletionRepository;

  void delete(int playlistId) => handle(
    () async {
      setState(const PlaylistDeletionState.inProgress());
      await _playlistDeletionRepository.delete(playlistId);
      setState(const PlaylistDeletionState.completed());
    },
    error: (error, stackTrace) async => setState(PlaylistDeletionState.error(error: error)),
    name: 'delete',
  );
}

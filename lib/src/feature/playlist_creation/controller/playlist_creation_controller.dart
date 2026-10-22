import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/playlist_creation/data/playlist_creation_repository.dart';

part 'playlist_creation_controller.freezed.dart';

@freezed
sealed class PlaylistCreationState with _$PlaylistCreationState {
  const PlaylistCreationState._();

  const factory PlaylistCreationState.initial() = PlaylistCreation$InitialState;

  const factory PlaylistCreationState.inProgress() = PlaylistCreation$InProgressState;

  const factory PlaylistCreationState.error({Object? error}) = PlaylistCreation$ErrorState;

  /// [playlistId] is the id of the created playlist.
  const factory PlaylistCreationState.completed({required int playlistId}) =
      PlaylistCreation$CompletedState;
}

/// Creates a playlist.
final class PlaylistCreationController extends StateController<PlaylistCreationState>
    with DroppableControllerHandler {
  PlaylistCreationController({
    required this._playlistCreationRepository,
    super.initialState = const PlaylistCreationState.initial(),
  });

  final IPlaylistCreationRepository _playlistCreationRepository;

  /// Creates a playlist named [name] (trimmed). Blank names are ignored.
  void create(String name) => handle(
    () async {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return;
      setState(const PlaylistCreationState.inProgress());
      final id = await _playlistCreationRepository.create(trimmed);
      setState(PlaylistCreationState.completed(playlistId: id));
    },
    error: (error, stackTrace) async => setState(PlaylistCreationState.error(error: error)),
    name: 'create',
  );
}

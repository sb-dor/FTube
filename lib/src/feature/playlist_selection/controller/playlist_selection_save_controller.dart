import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlist_selection/data/playlist_selection_repository.dart';

part 'playlist_selection_save_controller.freezed.dart';

@freezed
sealed class PlaylistSelectionSaveState with _$PlaylistSelectionSaveState {
  const PlaylistSelectionSaveState._();

  const factory PlaylistSelectionSaveState.initial() = PlaylistSelectionSave$InitialState;

  const factory PlaylistSelectionSaveState.inProgress() = PlaylistSelectionSave$InProgressState;

  const factory PlaylistSelectionSaveState.error({Object? error}) =
      PlaylistSelectionSave$ErrorState;

  /// [playlistId] is where the video is now; null when it was removed from all playlists.
  const factory PlaylistSelectionSaveState.completed({required int? playlistId}) =
      PlaylistSelectionSave$CompletedState;
}

/// Moves a video into the chosen playlist, or out of all playlists.
final class PlaylistSelectionSaveController extends StateController<PlaylistSelectionSaveState>
    with DroppableControllerHandler {
  PlaylistSelectionSaveController({
    required this._playlistSelectionRepository,
    super.initialState = const PlaylistSelectionSaveState.initial(),
  });

  final IPlaylistSelectionRepository _playlistSelectionRepository;

  void save(VideoItem video, {required int? playlistId}) => handle(
    () async {
      setState(const PlaylistSelectionSaveState.inProgress());
      await _playlistSelectionRepository.assign(video, playlistId: playlistId);
      setState(PlaylistSelectionSaveState.completed(playlistId: playlistId));
    },
    error: (error, stackTrace) async => setState(PlaylistSelectionSaveState.error(error: error)),
    name: 'save',
  );
}

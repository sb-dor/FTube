import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/playlist_video_removal/data/playlist_video_removal_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

part 'playlist_video_removal_controller.freezed.dart';

@freezed
sealed class PlaylistVideoRemovalState with _$PlaylistVideoRemovalState {
  const PlaylistVideoRemovalState._();

  const factory PlaylistVideoRemovalState.initial() = PlaylistVideoRemoval$InitialState;

  const factory PlaylistVideoRemovalState.inProgress() = PlaylistVideoRemoval$InProgressState;

  const factory PlaylistVideoRemovalState.error({Object? error}) = PlaylistVideoRemoval$ErrorState;

  const factory PlaylistVideoRemovalState.completed() = PlaylistVideoRemoval$CompletedState;
}

/// Removes a video from a user playlist, or unlikes it when the playlist is "Liked videos".
final class PlaylistVideoRemovalController extends StateController<PlaylistVideoRemovalState>
    with DroppableControllerHandler {
  PlaylistVideoRemovalController({
    required this._playlistVideoRemovalRepository,
    super.initialState = const PlaylistVideoRemovalState.initial(),
  });

  final IPlaylistVideoRemovalRepository _playlistVideoRemovalRepository;

  void remove({required PlaylistSummary playlist, required String videoId}) => handle(
    () async {
      setState(const PlaylistVideoRemovalState.inProgress());
      switch (playlist) {
        case UserPlaylistSummary(:final id):
          await _playlistVideoRemovalRepository.removeFromPlaylist(
            playlistId: id,
            videoId: videoId,
          );
        case LikedPlaylistSummary():
          await _playlistVideoRemovalRepository.unlike(videoId);
      }
      setState(const PlaylistVideoRemovalState.completed());
    },
    error: (error, stackTrace) async => setState(PlaylistVideoRemovalState.error(error: error)),
    name: 'remove',
  );
}

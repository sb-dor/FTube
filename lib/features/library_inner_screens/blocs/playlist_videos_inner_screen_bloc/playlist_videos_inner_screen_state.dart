import 'state_model/playlist_videos_inner_screen_state_model.dart';

sealed class PlaylistVideosInnerScreenState {
  PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel;

  PlaylistVideosInnerScreenState({
    required this.playlistVideosInnerScreenStateModel,
  });
}

final class LoadingPlaylistVideosInnerScreenState
    extends PlaylistVideosInnerScreenState {
  LoadingPlaylistVideosInnerScreenState(
    PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel,
  ) : super(
        playlistVideosInnerScreenStateModel:
            playlistVideosInnerScreenStateModel,
      );
}

final class ErrorPlaylistVideosInnerScreenState
    extends PlaylistVideosInnerScreenState {
  ErrorPlaylistVideosInnerScreenState(
    PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel,
  ) : super(
        playlistVideosInnerScreenStateModel:
            playlistVideosInnerScreenStateModel,
      );
}

final class LoadedPlaylistVideosInnerScreenState
    extends PlaylistVideosInnerScreenState {
  LoadedPlaylistVideosInnerScreenState(
    PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel,
  ) : super(
        playlistVideosInnerScreenStateModel:
            playlistVideosInnerScreenStateModel,
      );
}

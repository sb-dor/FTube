import 'state_model/playlist_inner_screen_state_model.dart';

sealed class PlaylistInnerScreenState {
  PlaylistInnerScreenStateModel playlistInnerScreenStateModel;

  PlaylistInnerScreenState({required this.playlistInnerScreenStateModel});
}

final class LoadingPlaylistInnerState extends PlaylistInnerScreenState {
  LoadingPlaylistInnerState(
    PlaylistInnerScreenStateModel playlistInnerScreenStateModel,
  ) : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

final class ErrorPlaylistInnerState extends PlaylistInnerScreenState {
  ErrorPlaylistInnerState(
    PlaylistInnerScreenStateModel playlistInnerScreenStateModel,
  ) : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

final class LoadedPlaylistInnerState extends PlaylistInnerScreenState {
  LoadedPlaylistInnerState(
    PlaylistInnerScreenStateModel playlistInnerScreenStateModel,
  ) : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

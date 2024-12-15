import 'state_model/playlist_inner_screen_state_model.dart';

abstract class PlaylistInnerScreenState {
  PlaylistInnerScreenStateModel playlistInnerScreenStateModel;

  PlaylistInnerScreenState({required this.playlistInnerScreenStateModel});
}

class LoadingPlaylistInnerState extends PlaylistInnerScreenState {
  LoadingPlaylistInnerState(PlaylistInnerScreenStateModel playlistInnerScreenStateModel)
      : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

class ErrorPlaylistInnerState extends PlaylistInnerScreenState {
  ErrorPlaylistInnerState(PlaylistInnerScreenStateModel playlistInnerScreenStateModel)
      : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

class LoadedPlaylistInnerState extends PlaylistInnerScreenState {
  LoadedPlaylistInnerState(PlaylistInnerScreenStateModel playlistInnerScreenStateModel)
      : super(playlistInnerScreenStateModel: playlistInnerScreenStateModel);
}

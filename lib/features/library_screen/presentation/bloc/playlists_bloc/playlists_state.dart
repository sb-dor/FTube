import 'state_model/playlists_state_model.dart';

abstract class PlaylistsStates {
  PlayListsStateModel playListsStateModel;

  PlaylistsStates({required this.playListsStateModel});
}

class LoadingPlaylistsState extends PlaylistsStates {
  LoadingPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

class ErrorPlaylistsState extends PlaylistsStates {
  ErrorPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

class LoadedPlaylistsState extends PlaylistsStates {
  LoadedPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

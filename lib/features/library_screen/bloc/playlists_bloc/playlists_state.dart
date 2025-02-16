import 'state_model/playlists_state_model.dart';

sealed class PlaylistsStates {
  PlayListsStateModel playListsStateModel;

  PlaylistsStates({required this.playListsStateModel});
}

final class LoadingPlaylistsState extends PlaylistsStates {
  LoadingPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

final class ErrorPlaylistsState extends PlaylistsStates {
  ErrorPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

final class LoadedPlaylistsState extends PlaylistsStates {
  LoadedPlaylistsState(PlayListsStateModel playListsStateModel)
      : super(playListsStateModel: playListsStateModel);
}

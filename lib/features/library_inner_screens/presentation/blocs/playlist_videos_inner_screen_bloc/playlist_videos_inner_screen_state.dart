import 'state_model/playlist_videos_inner_screen_state_model.dart';

abstract class PlaylistVideosInnerScreenState {
  PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel;

  PlaylistVideosInnerScreenState({required this.playlistVideosInnerScreenStateModel});
}

class LoadingPlaylistVideosInnerScreenState extends PlaylistVideosInnerScreenState {
  LoadingPlaylistVideosInnerScreenState(
      PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel)
      : super(playlistVideosInnerScreenStateModel: playlistVideosInnerScreenStateModel);
}

class ErrorPlaylistVideosInnerScreenState extends PlaylistVideosInnerScreenState {
  ErrorPlaylistVideosInnerScreenState(
      PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel)
      : super(playlistVideosInnerScreenStateModel: playlistVideosInnerScreenStateModel);
}

class LoadedPlaylistVideosInnerScreenState extends PlaylistVideosInnerScreenState {
  LoadedPlaylistVideosInnerScreenState(
      PlaylistVideosInnerScreenStateModel playlistVideosInnerScreenStateModel)
      : super(playlistVideosInnerScreenStateModel: playlistVideosInnerScreenStateModel);
}

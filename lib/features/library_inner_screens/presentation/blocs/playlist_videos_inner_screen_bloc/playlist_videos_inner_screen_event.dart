import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class PlaylistVideosInnerScreenEvent {}

class RefreshPlaylistVideosInnerScreenEvent extends PlaylistVideosInnerScreenEvent {
  PlaylistModelDb? playlistModelDb;

  RefreshPlaylistVideosInnerScreenEvent({required this.playlistModelDb});
}

class PaginatePlaylistVideosInnerScreenEvent extends PlaylistVideosInnerScreenEvent {
  PlaylistModelDb? playlistModelDb;

  PaginatePlaylistVideosInnerScreenEvent({required this.playlistModelDb});
}

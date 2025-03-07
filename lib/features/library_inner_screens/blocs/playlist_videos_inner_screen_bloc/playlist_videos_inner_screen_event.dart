import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

sealed class PlaylistVideosInnerScreenEvent {}

final class RefreshPlaylistVideosInnerScreenEvent extends PlaylistVideosInnerScreenEvent {
  PlaylistModelDb? playlistModelDb;

  RefreshPlaylistVideosInnerScreenEvent({required this.playlistModelDb});
}

final class PaginatePlaylistVideosInnerScreenEvent extends PlaylistVideosInnerScreenEvent {
  PlaylistModelDb? playlistModelDb;

  PaginatePlaylistVideosInnerScreenEvent({required this.playlistModelDb});
}

import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

sealed class PlaylistsEvent {}

final class GetPlaylistsEvent extends PlaylistsEvent {}

final class DeletePlaylistEvent extends PlaylistsEvent {
  final PlaylistModelDb? playlistModelDb;

  DeletePlaylistEvent({required this.playlistModelDb});
}

final class CreatePlaylistEvent extends PlaylistsEvent {
  String name;

  CreatePlaylistEvent({required this.name});
}

final class SaveInPlaylistEvent extends PlaylistsEvent {
  BaseVideoModelDb? videoModelDb;
  PlaylistModelDb? playlistModelDb;

  SaveInPlaylistEvent({required this.videoModelDb, required this.playlistModelDb});
}

final class SelectTempPlaylist extends PlaylistsEvent {
  PlaylistModelDb? playlistModelDb;

  SelectTempPlaylist({required this.playlistModelDb});
}

final class ClearTempPlaylist extends PlaylistsEvent {}

final class CheckIsVideoInPlaylistEvent extends PlaylistsEvent {
  BaseVideoModelDb? baseVideoModelDb;

  CheckIsVideoInPlaylistEvent({required this.baseVideoModelDb});
}

final class GetLikedVideosEvent extends PlaylistsEvent {}

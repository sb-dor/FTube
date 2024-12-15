import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class PlaylistsEvent {}

class GetPlaylistsEvent extends PlaylistsEvent {}

class DeletePlaylistEvent extends PlaylistsEvent {
  final PlaylistModelDb? playlistModelDb;

  DeletePlaylistEvent({required this.playlistModelDb});
}

class CreatePlaylistEvent extends PlaylistsEvent {
  String name;

  CreatePlaylistEvent({required this.name});
}

class SaveInPlaylistEvent extends PlaylistsEvent {
  BaseVideoModelDb? videoModelDb;
  PlaylistModelDb? playlistModelDb;

  SaveInPlaylistEvent({
    required this.videoModelDb,
    required this.playlistModelDb,
  });
}

class SelectTempPlaylist extends PlaylistsEvent {
  PlaylistModelDb? playlistModelDb;

  SelectTempPlaylist({required this.playlistModelDb});
}

class ClearTempPlaylist extends PlaylistsEvent {}

class CheckIsVideoInPlaylistEvent extends PlaylistsEvent {
  BaseVideoModelDb? baseVideoModelDb;

  CheckIsVideoInPlaylistEvent({required this.baseVideoModelDb});
}

class GetLikedVideosEvent extends PlaylistsEvent {}

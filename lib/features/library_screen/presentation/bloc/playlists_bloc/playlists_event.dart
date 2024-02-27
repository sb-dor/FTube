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

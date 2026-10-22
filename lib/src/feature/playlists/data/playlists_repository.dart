import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/playlists/data/playlist_summary_queries.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

abstract interface class IPlaylistsRepository {
  /// All playlists ("Liked videos" first when something is liked, then the newest user
  /// playlists); emits again whenever playlists, their videos or likes change.
  Stream<List<PlaylistSummary>> watchPlaylists();
}

final class PlaylistsRepositoryImpl implements IPlaylistsRepository {
  PlaylistsRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Stream<List<PlaylistSummary>> watchPlaylists() => _database.watchTables([
    _database.playlists,
    _database.playlistVideos,
    _database.likes,
  ], _database.playlistSummaries);
}

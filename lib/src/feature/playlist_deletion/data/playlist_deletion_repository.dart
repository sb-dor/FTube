import 'package:youtube/src/common/database/database.dart';

abstract interface class IPlaylistDeletionRepository {
  /// Deletes the playlist and all of its videos.
  Future<void> delete(int playlistId);
}

final class PlaylistDeletionRepositoryImpl implements IPlaylistDeletionRepository {
  PlaylistDeletionRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> delete(int playlistId) => _database.transaction(() async {
    await (_database.delete(
      _database.playlistVideos,
    )..where((video) => video.playlistId.equals(playlistId))).go();
    await (_database.delete(
      _database.playlists,
    )..where((playlist) => playlist.id.equals(playlistId))).go();
  });
}

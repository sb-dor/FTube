import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';

abstract interface class IPlaylistVideoRemovalRepository {
  /// Removes [videoId] from the playlist [playlistId].
  Future<void> removeFromPlaylist({required int playlistId, required String videoId});

  /// Removes [videoId] from the liked videos.
  Future<void> unlike(String videoId);
}

final class PlaylistVideoRemovalRepositoryImpl implements IPlaylistVideoRemovalRepository {
  PlaylistVideoRemovalRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> removeFromPlaylist({required int playlistId, required String videoId}) =>
      (_database.delete(
        _database.playlistVideos,
      )..where((row) => row.playlistId.equals(playlistId) & row.videoId.equals(videoId))).go();

  @override
  Future<void> unlike(String videoId) =>
      (_database.delete(_database.likes)..where((row) => row.videoId.equals(videoId))).go();
}

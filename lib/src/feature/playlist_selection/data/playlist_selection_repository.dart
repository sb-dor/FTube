import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlist_selection/models/playlist_option.dart';

abstract interface class IPlaylistSelectionRepository {
  /// User playlists, newest first; emits again whenever playlists change. Never includes the
  /// virtual "Liked videos" playlist.
  Stream<List<PlaylistOption>> watchPlaylists();

  /// The playlist that currently contains [videoId], or null.
  Future<int?> playlistOf(String videoId);

  /// Moves [video] into [playlistId] (a video belongs to at most one playlist), or removes it
  /// from all playlists when [playlistId] is null.
  Future<void> assign(VideoItem video, {required int? playlistId});
}

final class PlaylistSelectionRepositoryImpl implements IPlaylistSelectionRepository {
  PlaylistSelectionRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Stream<List<PlaylistOption>> watchPlaylists() =>
      (_database.select(
        _database.playlists,
      )..orderBy([(row) => OrderingTerm.desc(row.id)])).watch().map(
        (rows) => [for (final row in rows) PlaylistOption(id: row.id, name: row.name ?? '')],
      );

  @override
  Future<int?> playlistOf(String videoId) async {
    final row =
        await (_database.select(_database.playlistVideos)
              ..where((row) => row.videoId.equals(videoId) & row.playlistId.isNotNull())
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(1))
            .getSingleOrNull();
    return row?.playlistId;
  }

  @override
  Future<void> assign(VideoItem video, {required int? playlistId}) =>
      _database.transaction(() async {
        await (_database.delete(
          _database.playlistVideos,
        )..where((row) => row.videoId.equals(video.id))).go();
        if (playlistId == null) return;
        await _database
            .into(_database.playlistVideos)
            .insert(video.toPlaylistVideoCompanion(playlistId));
      });
}

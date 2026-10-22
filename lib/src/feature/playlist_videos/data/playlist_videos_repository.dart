import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// The newest [videos] of a playlist and whether older ones exist.
typedef PlaylistVideosPage = ({List<VideoItem> videos, bool hasMore});

abstract interface class IPlaylistVideosRepository {
  /// The [limit] most recently added videos of [playlist] (liked videos for the virtual
  /// "Liked videos" playlist), newest first; emits again whenever they change.
  Stream<PlaylistVideosPage> watchVideos({required PlaylistSummary playlist, required int limit});
}

final class PlaylistVideosRepositoryImpl implements IPlaylistVideosRepository {
  PlaylistVideosRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Stream<PlaylistVideosPage> watchVideos({required PlaylistSummary playlist, required int limit}) {
    // One extra row tells whether another page exists.
    final rows = switch (playlist) {
      UserPlaylistSummary(:final id) =>
        (_database.select(_database.playlistVideos)
              ..where((row) => row.playlistId.equals(id))
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(limit + 1))
            .watch()
            .map((rows) => [for (final row in rows) row.toVideoItem()]),
      LikedPlaylistSummary() =>
        (_database.select(_database.likes)
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(limit + 1))
            .watch()
            .map((rows) => [for (final row in rows) row.toVideoItem()]),
    };
    return rows.map(
      (videos) => (videos: videos.take(limit).toList(), hasMore: videos.length > limit),
    );
  }
}

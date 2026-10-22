import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/feature/library/models/library_overview.dart';
import 'package:youtube/src/feature/playlists/data/playlist_summary_queries.dart';

abstract interface class ILibraryRepository {
  /// The library overview; emits again whenever history, playlists, likes or downloads change.
  Stream<LibraryOverview> watchOverview();
}

final class LibraryRepositoryImpl implements ILibraryRepository {
  LibraryRepositoryImpl({required this._database, this._sectionLimit = 15});

  final AppDatabase _database;

  /// How many history videos and user playlists the tab shows.
  final int _sectionLimit;

  @override
  Stream<LibraryOverview> watchOverview() => _database.watchTables([
    _database.videoHistory,
    _database.playlists,
    _database.playlistVideos,
    _database.likes,
    _database.fileDownloads,
  ], _overview);

  Future<LibraryOverview> _overview() async {
    final history =
        await (_database.select(_database.videoHistory)
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(_sectionLimit))
            .get();
    final playlists = await _database.playlistSummaries(limit: _sectionLimit);
    final count = _database.fileDownloads.id.count();
    final downloads = await (_database.selectOnly(
      _database.fileDownloads,
    )..addColumns([count])).map((row) => row.read(count) ?? 0).getSingle();
    return LibraryOverview(
      history: [for (final row in history) row.toVideoItem()],
      playlists: playlists,
      downloadsCount: downloads,
    );
  }
}

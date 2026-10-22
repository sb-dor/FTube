import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// The newest [videos] of a list and whether older ones exist.
typedef VideoListPage = ({List<VideoItem> videos, bool hasMore});

abstract interface class IHistoryRepository {
  /// The newest [limit] watched videos, newest first; emits again whenever the history changes.
  Stream<VideoListPage> watchHistory({required int limit});
}

final class HistoryRepositoryImpl implements IHistoryRepository {
  HistoryRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Stream<VideoListPage> watchHistory({required int limit}) {
    // One extra row tells whether another page exists.
    final query = _database.select(_database.videoHistory)
      ..orderBy([(row) => OrderingTerm.desc(row.id)])
      ..limit(limit + 1);
    return query.watch().map(
      (rows) => (
        videos: [for (final row in rows.take(limit)) row.toVideoItem()],
        hasMore: rows.length > limit,
      ),
    );
  }
}

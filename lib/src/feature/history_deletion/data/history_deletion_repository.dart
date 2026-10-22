import 'package:youtube/src/common/database/database.dart';

abstract interface class IHistoryDeletionRepository {
  /// Removes [videoId] from the watch history.
  Future<void> remove(String videoId);

  /// Removes every video from the watch history.
  Future<void> clear();
}

final class HistoryDeletionRepositoryImpl implements IHistoryDeletionRepository {
  HistoryDeletionRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> remove(String videoId) =>
      (_database.delete(_database.videoHistory)..where((row) => row.videoId.equals(videoId))).go();

  @override
  Future<void> clear() => _database.delete(_database.videoHistory).go();
}

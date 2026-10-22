import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// Likes and playlist membership of one video.
abstract interface class IVideoLibraryRepository {
  Stream<bool> watchLiked(String videoId);

  Future<void> setLiked(VideoItem video, {required bool liked});

  /// Whether the video is saved in any playlist.
  Stream<bool> watchInPlaylist(String videoId);
}

final class VideoLibraryRepositoryImpl implements IVideoLibraryRepository {
  VideoLibraryRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Stream<bool> watchLiked(String videoId) => (_database.select(
    _database.likes,
  )..where((t) => t.videoId.equals(videoId))).watch().map((rows) => rows.isNotEmpty);

  @override
  Future<void> setLiked(VideoItem video, {required bool liked}) => _database.transaction(() async {
    await (_database.delete(_database.likes)..where((t) => t.videoId.equals(video.id))).go();
    if (liked) await _database.into(_database.likes).insert(video.toLikeCompanion());
  });

  @override
  Stream<bool> watchInPlaylist(String videoId) => (_database.select(
    _database.playlistVideos,
  )..where((t) => t.videoId.equals(videoId))).watch().map((rows) => rows.isNotEmpty);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_floor.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorDbFloor {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DbFloorBuilder databaseBuilder(String name) => _$DbFloorBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DbFloorBuilder inMemoryDatabaseBuilder() => _$DbFloorBuilder(null);
}

class _$DbFloorBuilder {
  _$DbFloorBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$DbFloorBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$DbFloorBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<DbFloor> build() async {
    final path = name != null ? await sqfliteDatabaseFactory.getDatabasePath(name!) : ':memory:';
    final database = _$DbFloor();
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$DbFloor extends DbFloor {
  _$DbFloor([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  VideoModelDbDao? _videoDbDaoInstance;

  PlaylistModelDao? _playListDaoInstance;

  LikeDataAccessObject? _likeDaoInstance;

  FileDownloadedDao? _downloadedFilesInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `video_history` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT)',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `playlists` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT)',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `playlist_videos` (`play_list_id` INTEGER, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT, FOREIGN KEY (`play_list_id`) REFERENCES `playlists` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `likes_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT)',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `file_downloads` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `downloaded_path` TEXT, `image_path` TEXT, `views` TEXT, `created_at` TEXT, `channel_name` TEXT)',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VideoModelDbDao get videoDbDao {
    return _videoDbDaoInstance ??= _$VideoModelDbDao(database, changeListener);
  }

  @override
  PlaylistModelDao get playListDao {
    return _playListDaoInstance ??= _$PlaylistModelDao(database, changeListener);
  }

  @override
  LikeDataAccessObject get likeDao {
    return _likeDaoInstance ??= _$LikeDataAccessObject(database, changeListener);
  }

  @override
  FileDownloadedDao get downloadedFiles {
    return _downloadedFilesInstance ??= _$FileDownloadedDao(database, changeListener);
  }
}

class _$VideoModelDbDao extends VideoModelDbDao {
  _$VideoModelDbDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _videoModelDbInsertionAdapter = InsertionAdapter(
        database,
        'video_history',
        (VideoModelDb item) => <String, Object?>{
          'id': item.id,
          'videoId': item.videoId,
          'videoThumbnailUrl': item.videoThumbnailUrl,
          'views': item.views,
          'duration': item.duration,
          'title': item.title,
          'channelName': item.channelName,
          'channelThumb': item.channelThumb,
          'videoDate': item.videoDate,
          'date_time': item.dateTime,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<VideoModelDb> _videoModelDbInsertionAdapter;

  @override
  Future<List<VideoModelDb>> getAllVideos() async {
    return _queryAdapter.queryList(
      'select * from video_history',
      mapper:
          (Map<String, Object?> row) => VideoModelDb(
            id: row['id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
    );
  }

  @override
  Future<List<VideoModelDb>> getLimitVideos(int limit) async {
    return _queryAdapter.queryList(
      'select * from video_history order by id desc limit ?1',
      mapper:
          (Map<String, Object?> row) => VideoModelDb(
            id: row['id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
      arguments: [limit],
    );
  }

  @override
  Future<void> deleteVideo(int id) async {
    await _queryAdapter.queryNoReturn('delete from video_history where id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteVideoByVideoId(String id) async {
    await _queryAdapter.queryNoReturn(
      'delete from video_history where videoId = ?1',
      arguments: [id],
    );
  }

  @override
  Future<void> insertVideo(VideoModelDb videoModelDb) async {
    await _videoModelDbInsertionAdapter.insert(videoModelDb, OnConflictStrategy.abort);
  }
}

class _$PlaylistModelDao extends PlaylistModelDao {
  _$PlaylistModelDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _playlistModelDbInsertionAdapter = InsertionAdapter(
        database,
        'playlists',
        (PlaylistModelDb item) => <String, Object?>{'id': item.id, 'name': item.name},
      ),
      _playlistVideosModelDbInsertionAdapter = InsertionAdapter(
        database,
        'playlist_videos',
        (PlaylistVideosModelDb item) => <String, Object?>{
          'play_list_id': item.playlistId,
          'id': item.id,
          'videoId': item.videoId,
          'videoThumbnailUrl': item.videoThumbnailUrl,
          'views': item.views,
          'duration': item.duration,
          'title': item.title,
          'channelName': item.channelName,
          'channelThumb': item.channelThumb,
          'videoDate': item.videoDate,
          'date_time': item.dateTime,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlaylistModelDb> _playlistModelDbInsertionAdapter;

  final InsertionAdapter<PlaylistVideosModelDb> _playlistVideosModelDbInsertionAdapter;

  @override
  Future<List<PlaylistModelDb>> getPlaylists(int limit) async {
    return _queryAdapter.queryList(
      'select * from playlists limit ?1',
      mapper:
          (Map<String, Object?> row) =>
              PlaylistModelDb(id: row['id'] as int?, name: row['name'] as String?),
      arguments: [limit],
    );
  }

  @override
  Future<List<PlaylistModelDb>> getAllPlaylists() async {
    return _queryAdapter.queryList(
      'select * from playlists',
      mapper:
          (Map<String, Object?> row) =>
              PlaylistModelDb(id: row['id'] as int?, name: row['name'] as String?),
    );
  }

  @override
  Future<List<PlaylistVideosModelDb>> getPlaylistVideos(int id, int limit) async {
    return _queryAdapter.queryList(
      'select * from playlist_videos where play_list_id = ?1 limit ?2',
      mapper:
          (Map<String, Object?> row) => PlaylistVideosModelDb(
            id: row['id'] as int?,
            playlistId: row['play_list_id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
      arguments: [id, limit],
    );
  }

  @override
  Future<List<PlaylistVideosModelDb>> getPlaylistAllVideos(int id) async {
    return _queryAdapter.queryList(
      'select * from playlist_videos where play_list_id = ?1',
      mapper:
          (Map<String, Object?> row) => PlaylistVideosModelDb(
            id: row['id'] as int?,
            playlistId: row['play_list_id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
      arguments: [id],
    );
  }

  @override
  Future<PlaylistVideosModelDb?> getVideoFromPlaylistVideos(String videoId) async {
    return _queryAdapter.query(
      'select * from playlist_videos where videoId = ?1',
      mapper:
          (Map<String, Object?> row) => PlaylistVideosModelDb(
            id: row['id'] as int?,
            playlistId: row['play_list_id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
      arguments: [videoId],
    );
  }

  @override
  Future<PlaylistModelDb?> getVideoPlaylist(int playlistId) async {
    return _queryAdapter.query(
      'select * from playlists where id = ?1',
      mapper:
          (Map<String, Object?> row) =>
              PlaylistModelDb(id: row['id'] as int?, name: row['name'] as String?),
      arguments: [playlistId],
    );
  }

  @override
  Future<void> deletePlaylist(int id) async {
    await _queryAdapter.queryNoReturn('delete from playlists where id ?1', arguments: [id]);
  }

  @override
  Future<void> deleteVideoFromAllPlaylists(String videoId) async {
    await _queryAdapter.queryNoReturn(
      'delete from playlist_videos where videoId = ?1',
      arguments: [videoId],
    );
  }

  @override
  Future<void> createPlaylist(PlaylistModelDb playlistModelDb) async {
    await _playlistModelDbInsertionAdapter.insert(playlistModelDb, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertVideoIntoPlaylist(PlaylistVideosModelDb playlistVideosModelDb) async {
    await _playlistVideosModelDbInsertionAdapter.insert(
      playlistVideosModelDb,
      OnConflictStrategy.ignore,
    );
  }
}

class _$LikeDataAccessObject extends LikeDataAccessObject {
  _$LikeDataAccessObject(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _likeModelDbInsertionAdapter = InsertionAdapter(
        database,
        'likes_table',
        (LikeModelDb item) => <String, Object?>{
          'id': item.id,
          'videoId': item.videoId,
          'videoThumbnailUrl': item.videoThumbnailUrl,
          'views': item.views,
          'duration': item.duration,
          'title': item.title,
          'channelName': item.channelName,
          'channelThumb': item.channelThumb,
          'videoDate': item.videoDate,
          'date_time': item.dateTime,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LikeModelDb> _likeModelDbInsertionAdapter;

  @override
  Future<List<LikeModelDb>> getAllLikes() async {
    return _queryAdapter.queryList(
      'select * from likes_table',
      mapper:
          (Map<String, Object?> row) => LikeModelDb(
            id: row['id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
    );
  }

  @override
  Future<void> deleteLikedVideo(String videoID) async {
    await _queryAdapter.queryNoReturn(
      'delete from likes_table where videoId = ?1',
      arguments: [videoID],
    );
  }

  @override
  Future<LikeModelDb?> getLikedVideo(String videoID) async {
    return _queryAdapter.query(
      'select * from likes_table where videoId = ?1',
      mapper:
          (Map<String, Object?> row) => LikeModelDb(
            id: row['id'] as int?,
            videoId: row['videoId'] as String?,
            videoThumbnailUrl: row['videoThumbnailUrl'] as String?,
            views: row['views'] as String?,
            duration: row['duration'] as String?,
            title: row['title'] as String?,
            channelName: row['channelName'] as String?,
            channelThumb: row['channelThumb'] as String?,
            videoDate: row['videoDate'] as String?,
            dateTime: row['date_time'] as String?,
          ),
      arguments: [videoID],
    );
  }

  @override
  Future<void> insertLikedVideo(LikeModelDb likeModelDb) async {
    await _likeModelDbInsertionAdapter.insert(likeModelDb, OnConflictStrategy.abort);
  }
}

class _$FileDownloadedDao extends FileDownloadedDao {
  _$FileDownloadedDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _fileDownloadModelInsertionAdapter = InsertionAdapter(
        database,
        'file_downloads',
        (FileDownloadModel item) => <String, Object?>{
          'id': item.id,
          'name': item.name,
          'downloaded_path': item.downloadedPath,
          'image_path': item.imagePath,
          'views': item.views,
          'created_at': item.createdAt,
          'channel_name': item.channelName,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FileDownloadModel> _fileDownloadModelInsertionAdapter;

  @override
  Future<List<FileDownloadModel>> getDownloadedFiles() async {
    return _queryAdapter.queryList(
      'select * from file_downloads',
      mapper:
          (Map<String, Object?> row) => FileDownloadModel(
            id: row['id'] as int?,
            name: row['name'] as String?,
            downloadedPath: row['downloaded_path'] as String?,
            imagePath: row['image_path'] as String?,
            views: row['views'] as String?,
            createdAt: row['created_at'] as String?,
            channelName: row['channel_name'] as String?,
          ),
    );
  }

  @override
  Future<int?> getCountOfDownloadedFiles() async {
    return _queryAdapter.query(
      'select count(*) from file_downloads',
      mapper: (Map<String, Object?> row) => row.values.first as int,
    );
  }

  @override
  Future<void> deleteDownloadedFile(String path) async {
    await _queryAdapter.queryNoReturn(
      'delete from file_downloads where downloaded_path = ?1',
      arguments: [path],
    );
  }

  @override
  Future<void> insertDownloadedFile(FileDownloadModel fileDownloadModel) async {
    await _fileDownloadModelInsertionAdapter.insert(fileDownloadModel, OnConflictStrategy.abort);
  }
}

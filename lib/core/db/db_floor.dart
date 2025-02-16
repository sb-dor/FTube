import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:youtube/core/db/downloaded_file_db/dao/file_downloaded_dao.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/core/db/likes_db/data_access_object/like_data_access_object.dart';
import 'package:youtube/core/db/likes_db/like_model_db/like_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';

import 'playlists_db/data_access_object/playlist_model_db_dao.dart';
import 'video_db/data_access_object/video_model_db_dao.dart';
import 'video_db/video_model_db/video_model_db.dart';

part 'db_floor.g.dart';

abstract class Versions {
  static const int currentVersion = 5;
}

@Database(
  version: Versions.currentVersion,
  entities: [
    VideoModelDb,
    PlaylistModelDb,
    PlaylistVideosModelDb,
    LikeModelDb,
    FileDownloadModel,
  ],
)
abstract class DbFloor extends FloorDatabase {
  VideoModelDbDao get videoDbDao;

  PlaylistModelDao get playListDao;

  LikeDataAccessObject get likeDao;

  FileDownloadedDao get downloadedFiles;
}

import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/youtube_data_api/models/playlist.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

abstract class LibraryScreenRepository {
  Future<void> saveInHistory(Video? video);

  Future<void> saveInPlayList(BaseVideoModelDb? video);

  Future<void> createPlayList(String name);

  Future<List<BaseVideoModelDb>> getHistory({int page = 1});

  Future<List<PlaylistModelDb>> getPlaylists({int page = 1});

  Future<List<Video>> getVideosFromPlaylist(PlayList? playList);
}

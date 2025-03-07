import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/playlist.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

abstract class LibraryScreenRepository {
  Future<void> saveInHistory(Video? video);

  Future<void> saveInPlayList(BaseVideoModelDb? video, PlaylistModelDb? playlistModelDb);

  Future<void> createPlayList(String name);

  Future<List<BaseVideoModelDb>> getHistory({int page = 1});

  Future<List<PlaylistModelDb>> getPlaylists({int page = 1});

  Future<List<BaseVideoModelDb>> getLikedVideo();

  Future<List<Video>> getVideosFromPlaylist(PlayList? playList);

  Future<PlaylistModelDb?> videoPlaylist(BaseVideoModelDb? baseVideoModelDb);
}

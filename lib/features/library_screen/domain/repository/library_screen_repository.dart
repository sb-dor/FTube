import 'package:youtube/youtube_data_api/models/playlist.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

abstract class LibraryScreenRepository {
  Future<void> saveInHistory(Video? video);

  Future<void> saveInPlayList(Video? video);

  Future<void> createPlayList();

  Future<List<Video>> getHistory();

  Future<List<PlayList>> getPlaylists();

  Future<List<Video>> getVideosFromPlaylist(PlayList? playList);
}

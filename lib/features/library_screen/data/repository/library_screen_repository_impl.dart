import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_video_playlist_data_source/library_get_video_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/library_save_in_history_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_set_video_in_playlist_data_source/library_set_video_in_playlist_data_source.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/youtube_data_api/models/playlist.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibraryScreenRepositoryImpl implements LibraryScreenRepository {
  final LibraryCreatePlaylistDataSource _createPlaylistDataSource;
  final LibraryGetPlaylistDataSource _getPlaylistDataSource;
  final LibraryGetHistoryDataSource _getHistoryDataSource;
  final LibrarySaveInHistoryDataSource _saveInHistoryDataSource;
  final LibrarySetVideoInPlaylistDataSource _setVideoInPlaylistDataSource;
  final LibraryGetVideoPlaylistDataSource _getVideoPlaylistDataSource;

  LibraryScreenRepositoryImpl(
    this._createPlaylistDataSource,
    this._getPlaylistDataSource,
    this._getHistoryDataSource,
    this._saveInHistoryDataSource,
    this._setVideoInPlaylistDataSource,
    this._getVideoPlaylistDataSource,
  );

  @override
  Future<void> createPlayList(String name) => _createPlaylistDataSource.createPlayList(name);

  @override
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1}) =>
      _getPlaylistDataSource.getPlaylists(page: page);

  @override
  Future<List<VideoModelDb>> getHistory({int page = 1}) =>
      _getHistoryDataSource.getHistory(page: page);

  @override
  Future<List<Video>> getVideosFromPlaylist(PlayList? playList) {
    // TODO: implement getVideosFromPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> saveInHistory(Video? video) => _saveInHistoryDataSource.saveInHistory(video);

  @override
  Future<void> saveInPlayList(BaseVideoModelDb? video, PlaylistModelDb? playlistModelDb) =>
      _setVideoInPlaylistDataSource.setVideoInPlaylist(
        video,
        playlistModelDb,
      );

  @override
  Future<PlaylistModelDb?> videoPlaylist(BaseVideoModelDb? baseVideoModelDb) =>
      _getVideoPlaylistDataSource.videoPlaylist(baseVideoModelDb);
}

import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/library_save_in_history_data_source.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/youtube_data_api/models/playlist.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibraryScreenRepositoryImpl implements LibraryScreenRepository {
  final LibraryCreatePlaylistDataSource _createPlaylistDataSource;
  final LibraryGetPlaylistDataSource _getPlaylistDataSource;
  final LibraryGetHistoryDataSource _getHistoryDataSource;
  final LibrarySaveInHistoryDataSource _saveInHistoryDataSource;

  LibraryScreenRepositoryImpl(
    this._createPlaylistDataSource,
    this._getPlaylistDataSource,
    this._getHistoryDataSource,
    this._saveInHistoryDataSource,
  );

  @override
  Future<void> createPlayList() => _createPlaylistDataSource.createPlayList();

  @override
  Future<List<PlayList>> getPlaylists() => _getPlaylistDataSource.getPlaylists();

  @override
  Future<List<Video>> getHistory({int page = 1}) => _getHistoryDataSource.getHistory(page: page);

  @override
  Future<List<Video>> getVideosFromPlaylist(PlayList? playList) {
    // TODO: implement getVideosFromPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> saveInHistory(Video? video) => _saveInHistoryDataSource.saveInHistory(video);

  @override
  Future<void> saveInPlayList(Video? video) {
    // TODO: implement saveInPlayList
    throw UnimplementedError();
  }
}

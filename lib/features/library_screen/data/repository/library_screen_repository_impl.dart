import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/youtube_data_api/models/playlist.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibraryScreenRepositoryImpl implements LibraryScreenRepository {
  final LibraryCreatePlaylistDataSource _createPlaylistDataSource;
  final LibraryGetPlaylistDataSource _getPlaylistDataSource;

  LibraryScreenRepositoryImpl(
    this._createPlaylistDataSource,
    this._getPlaylistDataSource,
  );

  @override
  Future<void> createPlayList() => _createPlaylistDataSource.createPlayList();

  @override
  Future<List<PlayList>> getPlaylists() => _getPlaylistDataSource.getPlaylists();

  @override
  Future<List<Video>> getHistory() {
    // TODO: implement getHistory
    throw UnimplementedError();
  }

  @override
  Future<List<Video>> getVideosFromPlaylist(PlayList? playList) {
    // TODO: implement getVideosFromPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> saveInHistory(Video? video) {
    // TODO: implement saveInHistory
    throw UnimplementedError();
  }

  @override
  Future<void> saveInPlayList(Video? video) {
    // TODO: implement saveInPlayList
    throw UnimplementedError();
  }
}

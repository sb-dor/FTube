import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';

class PlaylistInnerScreenRepositoryImpl implements PlaylistInnerScreenRepository {
  final PlaylistInnerScreenDataSource _playlistInnerScreenDataSource;
  final PlaylistVideosInnerScreenDataSource _playlistVideosInnerScreenDataSource;

  PlaylistInnerScreenRepositoryImpl(
    this._playlistInnerScreenDataSource,
    this._playlistVideosInnerScreenDataSource,
  );

  @override
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1, int currentListLength = 0}) =>
      _playlistInnerScreenDataSource.getPlaylists(
        page: page,
        currentListLength: currentListLength,
      );

  @override
  Future<List<BaseVideoModelDb>> getPlaylistVideos({
    int page = 1,
    int currentListLength = 0,
    PlaylistModelDb? playlistModelDb,
  }) =>
      _playlistVideosInnerScreenDataSource.getPlaylistsVideos(
        page: page,
        currentListLength: currentListLength,
        playlistModelDb: playlistModelDb,
      );
}

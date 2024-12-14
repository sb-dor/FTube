import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_video_playlist_data_source/library_get_video_playlist_data_source.dart';

class LibraryGetVideoPlaylistLocally implements LibraryGetVideoPlaylistDataSource {
  final DbFloor _dbFloor;

  LibraryGetVideoPlaylistLocally(this._dbFloor);

  @override
  Future<PlaylistModelDb?> videoPlaylist(BaseVideoModelDb? baseVideoModelDb) async {
    if (baseVideoModelDb == null) return null;
    final findVideoFirst =
        await _dbFloor.playListDao.getVideoFromPlaylistVideos(baseVideoModelDb.videoId ?? '0');

    final result = await _dbFloor.playListDao.getVideoPlaylist(
      findVideoFirst?.playlistId ?? 0,
    );

    return result;
  }
}

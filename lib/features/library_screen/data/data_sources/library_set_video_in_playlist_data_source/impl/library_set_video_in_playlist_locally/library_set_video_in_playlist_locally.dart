import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_set_video_in_playlist_data_source/library_set_video_in_playlist_data_source.dart';

class LibrarySetVideoInPlaylistLocally implements LibrarySetVideoInPlaylistDataSource {
  final DbFloor _dbFloor;

  LibrarySetVideoInPlaylistLocally(this._dbFloor);

  @override
  Future<void> setVideoInPlaylist(
    BaseVideoModelDb? video,
    PlaylistModelDb? playlistModelDb,
  ) async {
    if (video == null || playlistModelDb == null) return;
    final DateTime dateTime = DateTime.now();
    PlaylistVideosModelDb pListVideoModel = PlaylistVideosModelDb.fromEntity(video)!;
    pListVideoModel = pListVideoModel.copyWith(playlistId: playlistModelDb.id);
    pListVideoModel.dateTime = dateTime.toString().substring(0, 16);
    await _dbFloor.playListDao.deleteVideoFromAllPlaylists(video.videoId ?? "0");
    await _dbFloor.playListDao.insertVideoIntoPlaylist(pListVideoModel);
  }
}

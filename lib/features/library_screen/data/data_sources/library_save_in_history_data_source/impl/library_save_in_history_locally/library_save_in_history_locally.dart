import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/library_save_in_history_data_source.dart';

class LibrarySaveInHistoryLocally implements LibrarySaveInHistoryDataSource {
  final DbFloor _dbFloor;

  LibrarySaveInHistoryLocally(this._dbFloor);

  @override
  Future<void> saveInHistory(Video? video) async {
    final DateTime dateTime = DateTime.now();

    await _dbFloor.videoDbDao.deleteVideoByVideoId(video?.videoId ?? '0');

    final videoModelDb = VideoModelDb.fromVideo(video)
      ..dateTime = dateTime.toString().substring(0, 16);

    await _dbFloor.videoDbDao.insertVideo(videoModelDb);
  }
}

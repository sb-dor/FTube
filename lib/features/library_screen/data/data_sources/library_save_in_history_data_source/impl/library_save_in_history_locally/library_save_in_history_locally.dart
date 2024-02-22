import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/library_save_in_history_data_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibrarySaveInHistoryLocally implements LibrarySaveInHistoryDataSource {
  @override
  Future<void> saveInHistory(Video? video) async {
    final videoModelDb = VideoModelDb.fromVideo(video);
    debugPrint("saving locally");
    locator<DbFloor>().videoDbDao.insertVideo(videoModelDb);
  }
}

import 'package:youtube/core/youtube_data_api/models/video.dart';

abstract class LibrarySaveInHistoryDataSource {
  Future<void> saveInHistory(Video? video);
}

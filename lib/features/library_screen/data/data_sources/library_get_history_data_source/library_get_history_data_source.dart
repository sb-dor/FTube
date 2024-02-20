import 'package:youtube/youtube_data_api/models/video.dart';

abstract class LibraryGetHistoryDataSource {
  Future<List<Video>> getHistory({int page = 1});
}

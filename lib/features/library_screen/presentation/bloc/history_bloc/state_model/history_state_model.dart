import 'package:youtube/youtube_data_api/models/video.dart';

class HistoryStateModel {
  List<Video> videos = [];

  int page = 1;

  bool hasMore = false;
}

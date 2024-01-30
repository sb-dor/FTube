import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class TrendingStateModel {
  List<Video> videos = [];

  VideoCategory category = VideoCategory.trendsCategories.first;

  bool hasMore = true;
}

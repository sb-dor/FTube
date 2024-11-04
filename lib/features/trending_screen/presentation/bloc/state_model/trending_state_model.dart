import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

class TrendingStateModel {
  List<Video> videos = [];

  VideoCategory category = VideoCategory.trendsCategories.first;
}

import 'package:youtube/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
import 'package:youtube/youtube_data_api/models/video_data.dart';

class TrendsVideos extends Video {
  const TrendsVideos(
      {String? videoId,
      String? duration,
      String? title,
      String? channelName,
      String? views,
      List<Thumbnail>? thumbnails,
      VideoData? videoData})
      : super(
          videoId: videoId,
          duration: duration,
          title: title,
          channelName: channelName,
          views: views,
          thumbnails: thumbnails,
          videoData: videoData,
        );
}

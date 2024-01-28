import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
import 'package:youtube/youtube_data_api/models/video_data.dart';

class TrendsVideosModel extends TrendsVideos {
  const TrendsVideosModel(
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

  factory TrendsVideosModel.fromVideo(Video video) {
    return TrendsVideosModel(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      thumbnails: video.thumbnails,
      videoData: video.videoData,
    );
  }
}

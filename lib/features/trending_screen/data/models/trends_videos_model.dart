import 'package:youtube/core/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

class TrendsVideosModel extends Video {
  TrendsVideosModel({
    String? videoId,
    String? duration,
    String? title,
    String? channelName,
    String? views,
    List<Thumbnail>? thumbnails,
    // VideoData? videoData,
    String? channelThumbnailUrl,
    String? publishedDateTime,
  }) : super(
          videoId: videoId,
          duration: duration,
          title: title,
          channelName: channelName,
          views: views,
          thumbnails: thumbnails,
          // videoData: videoData,
          channelThumbnailUrl: channelThumbnailUrl,
          publishedDateTime: publishedDateTime,
        );

  factory TrendsVideosModel.fromEntity(Video video) {
    return TrendsVideosModel(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      thumbnails: video.thumbnails,
      channelThumbnailUrl: video.channelThumbnailUrl,
      publishedDateTime: video.publishedDateTime,
    );
  }
}

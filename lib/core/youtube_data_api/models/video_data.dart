import 'package:youtube/core/youtube_data_api/models/video.dart';

import 'video_page.dart';

class VideoData {
  VideoPage? video;
  List<Video> videosList;

  VideoData({this.video, required this.videosList});

  VideoData clone() => VideoData(
    videosList: videosList.map((e) => e.clone()).toList(),
    video: video?.clone(),
  );

  factory VideoData.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = [];
    if (json['videoList'] != null) {
      list = json['videoList'];
    }

    final List<Video> videos = list.map((e) => Video.fromIsolate(e)).toList();

    return VideoData(
      videosList: videos,
      video:
          json['videoPage'] == null
              ? null
              : VideoPage.fromJson(json['videoPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "videoPage": video?.toJson(),
      "videoList": videosList.map((e) => e.toJson()).toList(),
    };
  }
}

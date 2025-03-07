import 'package:youtube/core/models/video_modes/video_id.dart';
import 'package:youtube/core/models/video_modes/video_snippet.dart';

class Video {
  String? kind;
  String? etag;
  VideoID? id;
  VideoSnippet? snippet;

  Video({this.kind, this.etag, this.id, this.snippet});

  factory Video.fromJson(Map<String, dynamic> json) {
    VideoID? tempId;
    if (json['id'] != null) {
      if (json['id'] is Map<String, dynamic>) {
        tempId = VideoID.fromJson(json['id']);
      } else {
        tempId = VideoID(videoID: json['id']);
      }
    }
    return Video(
      kind: json['kind'],
      etag: json['etag'],
      id: tempId,
      snippet:
          json['snippet'] == null
              ? null
              : VideoSnippet.fromJson(
                json['snippet'],
                videoId: tempId?.videoID,
              ),
    );
  }
}

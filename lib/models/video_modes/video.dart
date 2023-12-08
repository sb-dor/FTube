import 'package:youtube/models/video_modes/video_id.dart';
import 'package:youtube/models/video_modes/video_snippet.dart';
import 'package:youtube/models/video_modes/video_statistic.dart';

class Video {
  String? kind;
  String? etag;
  VideoID? id;
  VideoSnippet? snippet;

  Video({
    this.kind,
    this.etag,
    this.id,
    this.snippet,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    VideoID? tempId = json['id'] == null ? null : VideoID.fromJson(json['id']);
    return Video(
      kind: json['kind'],
      etag: json['etag'],
      id: tempId,
      snippet: json['snippet'] == null
          ? null
          : VideoSnippet.fromJson(json['snippet'], videoId: tempId?.videoID),
    );
  }
}

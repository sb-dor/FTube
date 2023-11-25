import 'package:youtube/models/video_category_models/video_category_snippet.dart';

class VideoCategory {
  String? id;
  String? kind;
  String? etag;
  VideoCategorySnippet? videoCategorySnippet;

  VideoCategory({this.id, this.kind, this.etag, this.videoCategorySnippet});

  factory VideoCategory.fromJson(Map<String, dynamic> json) => VideoCategory(
        id: json['id'],
        kind: json['kind'],
        etag: json['etag'],
        videoCategorySnippet:
            json['snippet'] == null ? null : VideoCategorySnippet.fromJson(json['snippet']),
      );
}

import 'video_category_snippet.dart';

class VideoCategory {
  String? id;
  String? kind; //name
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

  static List<VideoCategory> categories = [
    VideoCategory(id: "#all", kind: "All"),
    VideoCategory(id: "#films#animations#films#animations", kind: "Films and animations"),
    VideoCategory(id: "#musics", kind: "Music"),
    VideoCategory(
      id: "#videogames#computergames#games#shooters#rpgs#dota#cs16#csgo",
      kind: "Video games",
    ),
  ];

  static List<VideoCategory> trendsCategories = [
    VideoCategory(id: "1", kind: "Video games"),
    VideoCategory(id: "2", kind: "Films"),
    VideoCategory(id: "3", kind: "Music"),
    VideoCategory(id: "4", kind: "Videos"),
  ];
}

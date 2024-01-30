import 'package:youtube/models/video_category_models/video_category_snippet.dart';

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
    VideoCategory(id: "#all", kind: "Все"),
    VideoCategory(id: "#films#animations#films#animations", kind: "Фильмы и анимации"),
    VideoCategory(id: "#musics", kind: "Музыка"),
    VideoCategory(
        id: "#videogames#computergames#games#shooters#rpgs#dota#cs16#csgo", kind: "Видеоигры"),
  ];

    static List<VideoCategory> trendsCategories = [
    VideoCategory(id: "1", kind: "Видеоигры"),
    VideoCategory(id: "2", kind: "Фильмы"),
    VideoCategory(id: "3", kind: "Музыка"),
    VideoCategory(id: "4", kind: "Видео"),
  ];
}

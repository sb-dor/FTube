class VideoID {
  String? kind;
  String? videoID;

  VideoID({this.kind, this.videoID});

  factory VideoID.fromJson(Map<String, dynamic> json) =>
      VideoID(kind: json['kind'], videoID: json['videoId']);
}
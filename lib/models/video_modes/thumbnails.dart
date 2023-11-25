class Thumbnail {
  String? url;
  double? width;
  double? height;

  Thumbnail({this.url, this.width, this.height});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
        url: json['url'],
        width: json['width'] == null ? null : json['width'].toDouble(),
        height: json['height'] == null ? null : json['height'].toDouble());
  }
}

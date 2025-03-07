class Thumbnail {
  String? url;
  int? width, height;

  Thumbnail({this.url, this.width, this.height});

  Thumbnail clone() => Thumbnail(url: url, width: width, height: height);
}

class Channel {
  ///Youtube channel id
  String? channelId;

  ///Youtube channel title
  String? title;

  ///Youtube channel thumbnail
  String? thumbnail;

  ///Youtube channel number of videos
  String? videoCount;

  String? subsCount;

  Channel({this.channelId, this.title, this.thumbnail, this.videoCount, this.subsCount});

  factory Channel.fromMap(Map<String, dynamic>? map) {
    String? videoCount;
    if (map?['channelRenderer']?['videoCountText']?['runs'] != null) {
      videoCount = map?['channelRenderer']?['videoCountText']?['runs']?[0]?['text'];
    }
    String? subCount;
    if (map?['channelRenderer']?['videoCountText']?['accessibility']?['accessibilityData']?['simpleText'] !=
        null) {
      subCount =
          map?['channelRenderer']?['videoCountText']?['accessibility']?['accessibilityData']?['simpleText'];
    }
    return Channel(
      channelId: map?['channelRenderer']?['channelId'],
      thumbnail: map?['channelRenderer']?['thumbnail']?['thumbnails']?[0]?['url'],
      title: map?['channelRenderer']?['title']?['simpleText'],
      videoCount: videoCount,
      subsCount: subCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "channelId": channelId,
      "title": title,
      "thumbnail": thumbnail,
      "videoCount": videoCount,
    };
  }
}

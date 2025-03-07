class VideoStatistic {
  String? viewCount;
  String? likeCount;
  String? favoriteCount;
  String? commentCount;

  VideoStatistic({this.viewCount, this.likeCount, this.favoriteCount, this.commentCount});

  factory VideoStatistic.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> statistics = {};
    if (json['statistics'] != null) statistics = json['statistics'];
    return VideoStatistic(
      viewCount: statistics['viewCount'],
      likeCount: statistics['likeCount'],
      favoriteCount: statistics['favoriteCount'],
      commentCount: statistics['commentCount'],
    );
  }
}

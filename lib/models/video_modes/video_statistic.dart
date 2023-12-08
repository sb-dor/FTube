class VideoStatistic {
  String? viewCount;
  String? likeCount;
  String? favoriteCount;
  String? commentCount;

  VideoStatistic({
    this.viewCount,
    this.likeCount,
    this.favoriteCount,
    this.commentCount,
  });

  factory VideoStatistic.fromJson(Map<String, dynamic> json) {
    return VideoStatistic(
      viewCount: json['statistics']['viewCount'],
      likeCount: json['statistics']['likeCount'],
      favoriteCount: json['statistics']['favoriteCount'],
      commentCount: json['statistics']['commentCount'],
    );
  }

}

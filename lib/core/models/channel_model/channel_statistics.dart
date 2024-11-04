class ChannelStatistics {
  String? viewCount;
  String? subscriberCount;
  bool? hiddenSubscriberCount;
  String? videoCount;

  ChannelStatistics({
    this.viewCount,
    this.subscriberCount,
    this.hiddenSubscriberCount,
    this.videoCount,
  });

  factory ChannelStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> statistics = {};
    if (json['statistics'] != null) statistics = json['statistics'];
    return ChannelStatistics(
      viewCount: statistics['viewCount'],
      subscriberCount: statistics['subscriberCount'],
      hiddenSubscriberCount: statistics['hiddenSubscriberCount'],
      videoCount: statistics['videoCount'],
    );
  }
}

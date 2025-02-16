class ChannelStatus {
  String? privacyStatus;
  bool? isLinked;
  String? longUploadsStatus;
  bool? madeForKids;

  ChannelStatus({
    this.privacyStatus,
    this.isLinked,
    this.longUploadsStatus,
    this.madeForKids,
  });

  factory ChannelStatus.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> status = json['status'];
    return ChannelStatus(
      privacyStatus: status['privacyStatus'],
      isLinked: status['isLinked'],
      longUploadsStatus: status['longUploadsStatus'],
      madeForKids: status['madeForKids'],
    );
  }
}

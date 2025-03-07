class VideoCategorySnippet {
  String? title;
  bool? assignable;
  String? channelId;

  VideoCategorySnippet({this.title, this.assignable, this.channelId});

  factory VideoCategorySnippet.fromJson(Map<String, dynamic> json) =>
      VideoCategorySnippet(
        title: json['title'],
        assignable: json['assignable'],
        channelId: json['channelId'],
      );
}

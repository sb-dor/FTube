import 'package:youtube/models/channel_model/channel_snippet.dart';

class Channel {
  String? id;
  String? kind;
  String? etag;
  ChannelSnippet? channelSnippet;

  Channel({this.id, this.kind, this.etag, this.channelSnippet});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      kind: json['kind'],
      etag: json['etag'],
      channelSnippet: json['snippet'] == null
          ? null
          : ChannelSnippet.fromJson(json['snippet'], channelId: json['id']),
    );
  }
}

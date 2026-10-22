import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// A video continuing in the mini player after its screen closed.
@immutable
final class MiniPlayerSession {
  const MiniPlayerSession({
    required this.video,
    required this.url,
    required this.position,
    this.headers = const {},
  });

  final VideoItem video;

  /// Stream with video and sound that was playing.
  final Uri url;

  /// Headers [url] needs.
  final Map<String, String> headers;
  final Duration position;

  MiniPlayerSession copyWith({Duration? position}) => MiniPlayerSession(
    video: video,
    url: url,
    headers: headers,
    position: position ?? this.position,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/model/video_details.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/feature/video/models/video_item_converter.dart';
import 'package:youtube/src/feature/video/models/video_streams_converter.dart';

MediaStream _stream({
  required MediaStreamKind kind,
  required String container,
  int height = 0,
  int bitrate = 0,
  bool isOriginalAudio = true,
  bool isDrcAudio = false,
  String client = 'IOS',
}) => MediaStream(
  itag: height + bitrate,
  kind: kind,
  container: container,
  sizeBytes: 1,
  bitrate: bitrate,
  height: height,
  isOriginalAudio: isOriginalAudio,
  isDrcAudio: isDrcAudio,
  sources: [StreamSource(url: Uri.parse('https://example.com/$client'), client: client)],
);

void main() {
  const details = VideoDetails(
    id: 'abcdefghijk',
    title: 'Loaded title',
    channelName: 'Channel',
    viewsText: '1,234 views',
    publishedText: 'Aug 2, 2020',
    related: VideoPage.empty,
  );

  group('VideoItemConverter', () {
    test('a video from a link takes everything from its details', () {
      expect(
        const VideoItemConverter().convert(details),
        const VideoItem(
          id: 'abcdefghijk',
          title: 'Loaded title',
          channelName: 'Channel',
          viewsText: '1,234 views',
          publishedText: 'Aug 2, 2020',
        ),
      );
    });

    test('keeps what the tapped list item showed', () {
      const opened = VideoItem(
        id: 'abcdefghijk',
        title: 'List title',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        viewsText: '1.2K views',
        durationText: '3:15',
        publishedText: '3 years ago',
      );
      expect(
        const VideoItemConverter(opened: opened).convert(details),
        const VideoItem(
          id: 'abcdefghijk',
          title: 'Loaded title',
          channelName: 'Channel',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          viewsText: '1.2K views',
          durationText: '3:15',
          publishedText: '3 years ago',
        ),
      );
    });
  });

  group('VideoStreamsConverter', () {
    test('keeps MP4 muxed streams lowest first and the best original audio', () {
      final streams = const VideoStreamsConverter().convert(
        StreamCatalog(
          videoId: 'abcdefghijk',
          streams: [
            _stream(kind: MediaStreamKind.muxed, container: 'mp4', height: 720),
            _stream(kind: MediaStreamKind.muxed, container: 'webm', height: 480),
            _stream(kind: MediaStreamKind.muxed, container: 'mp4', height: 360),
            _stream(
              kind: MediaStreamKind.audio,
              container: 'mp4',
              bitrate: 256,
              isDrcAudio: true,
              client: 'DRC',
            ),
            _stream(
              kind: MediaStreamKind.audio,
              container: 'mp4',
              bitrate: 512,
              isOriginalAudio: false,
              client: 'DUB',
            ),
            _stream(kind: MediaStreamKind.audio, container: 'mp4', bitrate: 128, client: 'BEST'),
          ],
        ),
      );
      expect(streams.playable.map((s) => s.qualityLabel), ['360p', '720p']);
      expect(streams.audio?.client, 'BEST');
      expect(streams.initial?.height, 360);
      expect(streams.initialSources, streams.playable.first.sources);
    });

    test('a live stream has nothing playable', () {
      final streams = const VideoStreamsConverter().convert(
        const StreamCatalog(videoId: 'abcdefghijk', streams: []),
      );
      expect(streams.playable, isEmpty);
      expect(streams.audio, isNull);
    });
  });
}

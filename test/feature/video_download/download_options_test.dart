import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';

MediaStream _s(
  int itag,
  MediaStreamKind kind, {
  String container = 'mp4',
  String codecs = '',
  int bitrate = 128000,
  String? quality,
  int height = 0,
  bool original = true,
  bool drc = false,
}) => MediaStream(
  itag: itag,
  kind: kind,
  container: container,
  codecs: codecs,
  sizeBytes: 1000,
  bitrate: bitrate,
  qualityLabel: quality,
  height: height,
  isOriginalAudio: original,
  isDrcAudio: drc,
  sources: [StreamSource(url: Uri.parse('https://example.com/$itag'), client: 'TEST')],
);

void main() {
  test('offers original, non-compressed M4A audio first and skips dubbed tracks', () {
    final options = buildDownloadOptions(
      StreamCatalog(
        videoId: 'abcdefghijk',
        streams: [
          _s(140, MediaStreamKind.audio, drc: true),
          _s(141, MediaStreamKind.audio),
          _s(139, MediaStreamKind.audio, bitrate: 48000),
          _s(251, MediaStreamKind.audio, container: 'webm', bitrate: 160000),
          _s(142, MediaStreamKind.audio, original: false, bitrate: 256000),
        ],
      ),
    );
    expect(options.audio.map((o) => o.audio!.itag), [141, 139]);
  });

  test('lists muxed first, then one H.264 stream per quality, highest first', () {
    final muxed = _s(18, MediaStreamKind.muxed, quality: '360p', height: 360);
    final options = buildDownloadOptions(
      StreamCatalog(
        videoId: 'abcdefghijk',
        streams: [
          muxed,
          _s(140, MediaStreamKind.audio),
          _s(
            248,
            MediaStreamKind.video,
            container: 'webm',
            codecs: 'vp9',
            quality: '1080p',
            height: 1080,
          ),
          _s(137, MediaStreamKind.video, codecs: 'avc1.640028', quality: '1080p', height: 1080),
          _s(399, MediaStreamKind.video, codecs: 'av01.0', quality: '1080p', height: 1080),
          _s(136, MediaStreamKind.video, codecs: 'avc1.4d401f', quality: '720p', height: 720),
        ],
      ),
    );
    expect(options.video.first.muxed?.itag, 18);
    expect(options.video.skip(1).map((o) => o.video!.itag), [137, 136]);
    expect(options.video.skip(1).every((o) => o.audio?.itag == 140), isTrue);
    expect(options.video.skip(1).every((o) => o.soundFallback == muxed), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/youtube/json_node.dart';
import 'package:youtube/src/common/youtube/stream_converters.dart';

StreamSource _source(Uri url) => StreamSource(url: url, client: 'TEST');

JsonNode _format(Map<String, Object?> overrides) => JsonNode({
  'url': 'https://example.com/videoplayback?xtags=acont=dubbed:drc=1',
  'itag': 251,
  'mimeType': 'audio/webm; codecs="opus"',
  'bitrate': 160000,
  'contentLength': '4000000',
  ...overrides,
});

void main() {
  group('FormatConverter', () {
    const adaptive = FormatConverter(muxed: false, durationMs: 60000, source: _source);

    test('reads numeric fields sent as ints', () {
      final stream = adaptive.convert(
        _format({
          'itag': 137,
          'mimeType': 'video/mp4; codecs="avc1.640028"',
          'contentLength': 5000000,
          'height': 1080,
          'fps': 30,
          'qualityLabel': '1080p',
        }),
      )!;
      expect(stream.itag, 137);
      expect(stream.kind, MediaStreamKind.video);
      expect(stream.container, 'mp4');
      expect(stream.codecs, 'avc1.640028');
      expect(stream.sizeBytes, 5000000);
      expect(stream.height, 1080);
      expect(stream.fps, 30);
      expect(stream.qualityLabel, '1080p');
      expect(stream.isH264, isTrue);
    });

    test('reads numeric fields sent as strings', () {
      final stream = adaptive.convert(
        _format({'itag': '251', 'bitrate': '160000', 'contentLength': '4000000'}),
      )!;
      expect(stream.itag, 251);
      expect(stream.bitrate, 160000);
      expect(stream.sizeBytes, 4000000);
      expect(stream.kind, MediaStreamKind.audio);
      expect(stream.isOriginalAudio, isFalse);
      expect(stream.isDrcAudio, isTrue);
      expect(stream.sources.single.client, 'TEST');
    });

    test('estimates the size from bitrate and duration', () {
      final stream = adaptive.convert(_format({'contentLength': null}))!;
      expect(stream.sizeBytes, 160000 * 60000 ~/ 8000);
    });

    test('marks entries from formats as muxed and prefers the given url', () {
      final url = Uri.parse('https://example.com/solved');
      final stream = FormatConverter(
        muxed: true,
        durationMs: null,
        source: _source,
        url: url,
      ).convert(_format({'itag': 18, 'mimeType': 'video/mp4; codecs="avc1.42001E, mp4a.40.2"'}))!;
      expect(stream.kind, MediaStreamKind.muxed);
      expect(stream.sources.single.url, url);
      expect(stream.isOriginalAudio, isTrue);
    });

    test('skips entries without a numeric itag, mime type or size', () {
      expect(adaptive.convert(_format({'itag': null})), isNull);
      expect(adaptive.convert(_format({'itag': 'abc'})), isNull);
      expect(adaptive.convert(_format({'mimeType': 'audio/webm'})), isNull);
      const noDuration = FormatConverter(muxed: false, durationMs: null, source: _source);
      expect(noDuration.convert(_format({'contentLength': null})), isNull);
    });
  });
}

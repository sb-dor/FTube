import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/utils/youtube_link.dart';

void main() {
  group('videoIdInText', () {
    test('finds the id of a watch link', () {
      expect(videoIdInText('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    });

    test('finds the id of a short link among other words', () {
      expect(videoIdInText('look at this youtu.be/dQw4w9WgXcQ please'), 'dQw4w9WgXcQ');
    });

    test('finds the id of a shorts link without a scheme', () {
      expect(videoIdInText('m.youtube.com/shorts/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    });

    test('never takes an ordinary 11-letter word for a bare id', () {
      expect(videoIdInText('programming'), isNull);
      expect(videoIdInText('learn programming fast'), isNull);
    });

    test('ignores links to other sites and YouTube links without a video', () {
      expect(videoIdInText('https://example.com/watch?v=dQw4w9WgXcQ'), isNull);
      expect(videoIdInText('https://www.youtube.com/feed/trending'), isNull);
    });

    test('returns the first video when the text has several links', () {
      expect(videoIdInText('youtu.be/aaaaaaaaaaa youtu.be/bbbbbbbbbbb'), 'aaaaaaaaaaa');
    });

    test('handles blank text', () {
      expect(videoIdInText(''), isNull);
      expect(videoIdInText('   '), isNull);
    });
  });

  group('videoThumbnailUrl', () {
    test("is YouTube's standard high-quality thumbnail", () {
      expect(videoThumbnailUrl('abc'), 'https://i.ytimg.com/vi/abc/hqdefault.jpg');
    });
  });
}

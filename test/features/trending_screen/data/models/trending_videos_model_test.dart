import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';

void main() {
  final tTrendingVideoModel = TrendsVideosModel();

  group('models equality checker', () {
    test('model equality to trending_video test', () {
      expect(tTrendingVideoModel, isA<Video>());
    });
  });
}

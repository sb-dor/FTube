import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

void main() {
  final tTrendingVideoModel = TrendsVideosModel();
  final video = Video();

  group('models equality checker', () {
    test('model equality to trending_video test', () {
      expect(tTrendingVideoModel, isA<Video>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';
import 'package:youtube/features/trending_screen/data/repository/trends_repository_impl.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class MockTrendsRemoteDataSource extends Mock implements TrendsRemoteDataSource {}

class MockTrendsModel extends Mock implements TrendsVideosModel {}

void main() {
  late TrendsRepositoryImpl trendsRepositoryImpl;
  late MockTrendsRemoteDataSource mockTrendsRemoteDataSource;

  final list = List.generate(15, (index) => MockTrendsModel());

  setUp(() {
    mockTrendsRemoteDataSource = MockTrendsRemoteDataSource();

    trendsRepositoryImpl = TrendsRepositoryImpl(mockTrendsRemoteDataSource);

    when(() => mockTrendsRemoteDataSource.fetchTrendingMovies())
        .thenAnswer((invocation) async => list);

    when(() => mockTrendsRemoteDataSource.fetchTrendingGaming()).thenThrow(Exception());

    when(() => mockTrendsRemoteDataSource.fetchTrendingVideo())
        .thenAnswer((invocation) async => list);
  });

  group('trends_repository_impl-test', () {
    test('fetchTrendingMovies-test', () async {
      final result = await trendsRepositoryImpl.fetchTrendingMovies();

      expect(result.isNotEmpty, true);
    });

    test('fetchTrendingGaming-test', () async {
      List<Video> list = [];

      try {
        list = await trendsRepositoryImpl.fetchTrendingGaming();
      } catch (e) {
        list = [];
      }

      expect(list.isEmpty, true);
    });


    test('fetchTrendingVideo-test', () async {
      final result = await trendsRepositoryImpl.fetchTrendingVideo();

      expect(result.isNotEmpty, true);
    });
  });
}

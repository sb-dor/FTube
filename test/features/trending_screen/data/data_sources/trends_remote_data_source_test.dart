import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/features/trending_screen/data/datasource/i_trends_remote_datasource.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';

class MockTrendsRemoteDataSource extends Mock implements ITrendsRemoteDatasource {}

class MockTrendsVideoModel extends Mock implements TrendsVideosModel {}

void main() {
  late MockTrendsRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockTrendsRemoteDataSource();
  });

  final List<TrendsVideosModel> videos = List.generate(
    50,
    (index) => MockTrendsVideoModel(),
  );

  group('trends-remote-data-source-all-functions-test', () {
    // checking function for working properly
    test('fetchTrendingGaming-test', () async {
      when(() => dataSource.fetchTrendingGaming()).thenAnswer(
        (invocation) async => videos,
      );

      final results = await dataSource.fetchTrendingGaming();

      expect(results.isNotEmpty, true);
    });

    // checking function is it throws an exception
    test('fetchTrendingGaming-error-test', () async {
      List<TrendsVideosModel> emptyList = [];

      try {
        when(() => dataSource.fetchTrendingGaming()).thenThrow(UnimplementedError());

        emptyList = await dataSource.fetchTrendingGaming();
      } catch (e) {
        emptyList = [];
      }

      expect(emptyList.isEmpty, true);
    });

    // checking function for working properly
    test('fetchTrendingMovies-test', () async {
      when(() => dataSource.fetchTrendingMovies()).thenAnswer((invocation) async => videos);

      final result = await dataSource.fetchTrendingMovies();

      expect(result.isNotEmpty, true);
    });

    // checking function is it throws an exception
    test('fetchTrendingMovies-test', () async {
      List<TrendsVideosModel> emptyList = [];
      try {
        when(() => dataSource.fetchTrendingMovies()).thenThrow(Exception());

        emptyList = await dataSource.fetchTrendingMovies();
      } catch (e) {
        emptyList = [];
      }
      expect(emptyList.isEmpty, true);
    });
  });
}

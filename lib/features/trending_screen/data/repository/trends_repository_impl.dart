import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class TrendsRepositoryImpl implements TrendsRepository {
  final TrendsRemoteDataSource _remoteDataSource;

  TrendsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TrendsVideos>> fetchTrendingGaming() async => _remoteDataSource.fetchTrendingGaming();

  @override
  Future<List<TrendsVideos>> fetchTrendingMovies() async => _remoteDataSource.fetchTrendingMovies();

  @override
  Future<List<TrendsVideos>> fetchTrendingMusic() async => _remoteDataSource.fetchTrendingMusic();

  @override
  Future<List<TrendsVideos>> fetchTrendingVideo() async => _remoteDataSource.fetchTrendingVideo();
}

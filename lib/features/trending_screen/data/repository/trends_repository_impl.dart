import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/trending_screen/data/datasource/i_trends_remote_datasource.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class TrendsRepositoryImpl implements TrendsRepository {
  final ITrendsRemoteDatasource _remoteDataSource;

  TrendsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Video>> fetchTrendingGaming() async =>
      _remoteDataSource.fetchTrendingGaming();

  @override
  Future<List<Video>> fetchTrendingMovies() async =>
      _remoteDataSource.fetchTrendingMovies();

  @override
  Future<List<Video>> fetchTrendingMusic() async =>
      _remoteDataSource.fetchTrendingMusic();

  @override
  Future<List<Video>> fetchTrendingVideo() async =>
      _remoteDataSource.fetchTrendingVideo();
}

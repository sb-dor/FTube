import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';

abstract class ITrendsRemoteDatasource {
  Future<List<TrendsVideosModel>> fetchTrendingVideo();

  Future<List<TrendsVideosModel>> fetchTrendingMusic();

  Future<List<TrendsVideosModel>> fetchTrendingGaming();

  Future<List<TrendsVideosModel>> fetchTrendingMovies();
}

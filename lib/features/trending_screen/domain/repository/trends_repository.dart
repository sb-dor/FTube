import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';

abstract class TrendsRepository {
  Future<List<TrendsVideos>> fetchTrendingVideo();

  Future<List<TrendsVideos>> fetchTrendingMusic();

  Future<List<TrendsVideos>> fetchTrendingGaming();

  Future<List<TrendsVideos>> fetchTrendingMovies();
}

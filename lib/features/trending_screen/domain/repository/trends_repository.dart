import 'package:youtube/youtube_data_api/models/video.dart';

abstract class TrendsRepository {
  Future<List<Video>> fetchTrendingVideo();

  Future<List<Video>> fetchTrendingMusic();

  Future<List<Video>> fetchTrendingGaming();

  Future<List<Video>> fetchTrendingMovies();
}

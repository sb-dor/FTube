import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class GetTrendingMovies {
  final TrendsRepository _repository;

  GetTrendingMovies(this._repository);

  Future<List<TrendsVideos>> getTrendingMovies() async => _repository.fetchTrendingMovies();
}

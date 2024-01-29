import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class GetTrendingMovies {
  final TrendsRepository _repository;

  GetTrendingMovies(this._repository);

  Future<List<Video>> getTrendingMovies() async => _repository.fetchTrendingMovies();
}

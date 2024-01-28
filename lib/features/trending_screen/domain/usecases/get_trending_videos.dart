import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class GetTrendingVideos {
  final TrendsRepository _repository;

  GetTrendingVideos(this._repository);

  Future<List<TrendsVideos>> getTrendingVideos() async => _repository.fetchTrendingVideo();
}

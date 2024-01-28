import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class GetTrendingGaming {
  final TrendsRepository _repository;

  GetTrendingGaming(this._repository);

  Future<List<TrendsVideos>> getTrendingGaming() async => _repository.fetchTrendingGaming();
}

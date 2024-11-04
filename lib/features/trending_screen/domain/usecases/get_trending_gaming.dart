import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

class GetTrendingGaming {
  final TrendsRepository _repository;

  GetTrendingGaming(this._repository);

  Future<List<Video>> getTrendingGaming() => _repository.fetchTrendingGaming();
}

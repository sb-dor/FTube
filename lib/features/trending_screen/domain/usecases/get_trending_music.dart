import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

class GetTrendingMusic {
  final TrendsRepository _repository;

  GetTrendingMusic(this._repository);

  Future<List<Video>> getTrendingMusic() async => _repository.fetchTrendingMusic();
}

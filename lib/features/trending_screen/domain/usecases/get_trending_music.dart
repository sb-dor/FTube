import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_videos.dart';

class GetTrendingMusic {
  final TrendsRepository _repository;

  GetTrendingMusic(this._repository);

  Future<List<TrendsVideos>> getTrendingMusic() async => _repository.fetchTrendingMusic();
}

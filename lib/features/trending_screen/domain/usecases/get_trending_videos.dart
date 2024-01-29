import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class GetTrendingVideos {
  final TrendsRepository _repository;

  GetTrendingVideos(this._repository);

  Future<List<Video>> getTrendingVideos() async => _repository.fetchTrendingVideo();
}

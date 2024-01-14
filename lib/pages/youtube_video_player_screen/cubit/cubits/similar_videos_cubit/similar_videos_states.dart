import 'package:youtube/youtube_data_api/models/video.dart';

abstract class SimilarVideosStates {
  List<Video> similarVideos = [];

  SimilarVideosStates({List<Video>? data}) {
    similarVideos = data ?? [];
  }
}

class LoadingSimilarVideosState extends SimilarVideosStates {
  LoadingSimilarVideosState({List<Video>? data}) : super(data: data);
}

class ErrorSimilarVideosState extends SimilarVideosStates {
  ErrorSimilarVideosState({List<Video>? data}) : super(data: data);
}

class LoadedSimilarVideosState extends SimilarVideosStates {
  LoadedSimilarVideosState({List<Video>? data}) : super(data: data);
}

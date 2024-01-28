import 'package:youtube/youtube_data_api/models/video.dart';

class SimilarVideoStateModel {
  List<Video> similarVideos = [];
  bool hasMore = true;
}

abstract class SimilarVideosStates {
  SimilarVideoStateModel similarVideoStateModel;

  SimilarVideosStates({required this.similarVideoStateModel});
}

class LoadingSimilarVideosState extends SimilarVideosStates {
  LoadingSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

class ErrorSimilarVideosState extends SimilarVideosStates {
  ErrorSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

class LoadedSimilarVideosState extends SimilarVideosStates {
  LoadedSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

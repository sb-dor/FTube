import 'package:youtube/core/youtube_data_api/models/video.dart';

class SimilarVideoStateModel {
  List<Video> similarVideos = [];
  bool hasMore = true;
}

sealed class SimilarVideosStates {
  SimilarVideoStateModel similarVideoStateModel;

  SimilarVideosStates({required this.similarVideoStateModel});
}

final class LoadingSimilarVideosState extends SimilarVideosStates {
  LoadingSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

final class ErrorSimilarVideosState extends SimilarVideosStates {
  ErrorSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

final class LoadedSimilarVideosState extends SimilarVideosStates {
  LoadedSimilarVideosState(SimilarVideoStateModel similarVideoStateModel)
      : super(similarVideoStateModel: similarVideoStateModel);
}

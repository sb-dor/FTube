import 'state_model/youtube_video_state_model.dart';

sealed class YoutubeVideoStates {
  YoutubeVideoStateModel youtubeVideoStateModel;

  YoutubeVideoStates({required this.youtubeVideoStateModel});
}

final class InitialYoutubeVideoState extends YoutubeVideoStates {
  InitialYoutubeVideoState(YoutubeVideoStateModel videoStateModel)
    : super(youtubeVideoStateModel: videoStateModel);
}

final class ErrorYoutubeVideoState extends YoutubeVideoStates {
  ErrorYoutubeVideoState(YoutubeVideoStateModel videoStateModel)
    : super(youtubeVideoStateModel: videoStateModel);
}

import 'state_model/youtube_video_state_model.dart';

abstract class YoutubeVideoStates {
  YoutubeVideoStateModel youtubeVideoStateModel;

  YoutubeVideoStates({required this.youtubeVideoStateModel});
}

class InitialYoutubeVideoState extends YoutubeVideoStates {
  InitialYoutubeVideoState(YoutubeVideoStateModel videoStateModel)
      : super(youtubeVideoStateModel: videoStateModel);
}

class ErrorYoutubeVideoState extends YoutubeVideoStates {
  ErrorYoutubeVideoState(YoutubeVideoStateModel videoStateModel)
      : super(youtubeVideoStateModel: videoStateModel);
}
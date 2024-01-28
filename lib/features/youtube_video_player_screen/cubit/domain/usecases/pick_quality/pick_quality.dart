import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class PickQuality {
  static Future<void> pickQuality({
    required YoutubeVideoStateModel stateModel,
    required VideoStreamInfo videoStreamInfo,
    required Function(YoutubeVideoStates) emit,
  }) async {
    var tempPositionOfTheVideo = await stateModel.playerController?.position;
    if (tempPositionOfTheVideo == null) return;
    stateModel.playerController?.dispose();
    stateModel.playerController = null;
    stateModel.loadingVideo = true;
    emit(InitialYoutubeVideoState(stateModel));
    stateModel.playerController =
        VideoPlayerController.networkUrl(Uri.parse(videoStreamInfo.url.toString()));
    await stateModel.playerController?.initialize();
    await stateModel.playerController?.seekTo(tempPositionOfTheVideo);
    await stateModel.playerController?.play();
    stateModel.stopVideo = false;
    stateModel.loadingVideo = false;
    emit(InitialYoutubeVideoState(stateModel));
  }
}

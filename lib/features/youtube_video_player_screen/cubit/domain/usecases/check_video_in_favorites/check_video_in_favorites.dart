import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/x_injection_containers/injection_container.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';

abstract class CheckVideoInFavorites {
  static Future<void> checkVideoInFavorites({
    required YoutubeVideoStateModel stateModel,
    required Function(YoutubeVideoStates) emit,
  }) async {
    final data = await locator<DbFloor>().likeDao.getLikedVideo(stateModel.tempVideoId ?? '');
    if (data != null) {
      stateModel.isVideoAddedToFavorites = true;
    } else {
      stateModel.isVideoAddedToFavorites = false;
    }
    emit(InitialYoutubeVideoState(stateModel));
  }
}

import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';

abstract class CheckVideoInBookmarks {
  static Future<void> checkVideoInBookmarks({
    required YoutubeVideoStateModel stateModel,
    required String videoId,
    required Function(YoutubeVideoStates) emit,
  }) async {
    final data = await locator<DbFloor>().playListDao.getVideoFromPlaylistVideos(videoId);
    if (data != null) stateModel.isVideoAddedToBookMarks = true;
    emit(InitialYoutubeVideoState(stateModel));
  }
}

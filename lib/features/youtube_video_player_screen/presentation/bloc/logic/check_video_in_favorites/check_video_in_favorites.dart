import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';

class CheckVideoInFavorites {
  final DbFloor _dbFloor;

  CheckVideoInFavorites(this._dbFloor);

  Future<void> checkVideoInFavorites({
    required YoutubeVideoStateModel stateModel,
    required Function(YoutubeVideoStates) emit,
  }) async {
    final data = await _dbFloor.likeDao.getLikedVideo(
      stateModel.tempVideoId ?? '',
    );
    if (data != null) {
      stateModel.isVideoAddedToFavorites = true;
    } else {
      stateModel.isVideoAddedToFavorites = false;
    }
    emit(InitialYoutubeVideoState(stateModel));
  }
}

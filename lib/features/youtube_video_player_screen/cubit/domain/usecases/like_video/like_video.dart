import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/likes_db/like_model_db/like_model_db.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/check_video_in_favorites/check_video_in_favorites.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';

abstract class LikeVideo {
  static Future<void> likeVideo({
    required YoutubeVideoStateModel stateModel,
    required Function(YoutubeVideoStates) emit,
  }) async {
    if (stateModel.isVideoAddedToFavorites) {
      await locator<DbFloor>().likeDao.deleteLikedVideo(stateModel.tempVideoId ?? '');
    } else {
      final video = LikeModelDb.fromVideo(
        Video(
          videoId: stateModel.videoData?.video?.videoId,
          title: stateModel.videoData?.video?.title,
          channelName: stateModel.videoData?.video?.channelName,
          views: stateModel.videoData?.video?.viewCount,
          thumbnails: [Thumbnail(url: stateModel.videoPicture ?? '')],
        ),
      );
      await locator<DbFloor>().likeDao.insertLikedVideo(video);
    }
    await CheckVideoInFavorites.checkVideoInFavorites(stateModel: stateModel, emit: emit);
  }
}

import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

abstract class DownloadingRepository {
  Future<void> downloadVideo(
    List<int>? downloadingVideo,
    YoutubeVideoStateModel stateModel,
  );

  Future<void> downloadAudio(
    List<int>? downloadData,
    YoutubeVideoStateModel stateModel,
  );
}

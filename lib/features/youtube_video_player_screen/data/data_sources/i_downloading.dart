import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

abstract interface class IDownloading {
  Future<void> download(
    List<int>? downloadingVideo,
    YoutubeVideoStateModel stateModel,
  );
}

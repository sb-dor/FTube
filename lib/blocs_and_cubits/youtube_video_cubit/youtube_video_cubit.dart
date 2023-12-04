import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/blocs_and_cubits/youtube_video_cubit/youtube_video_states.dart';

class YoutubeVideoCubit extends Cubit<YoutubeVideoStates> {
  YoutubeVideoCubit() : super(InitialYoutubeVideoState());

  late PodPlayerController _playerController;

  PodPlayerController get playerController => _playerController;

  void init({required String url}) async {
    _playerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(url),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
        videoQualityPriority: [
          1080,
          720,
          480,
          360,
          144,
        ],
      ),
    );
    await _playerController.initialise();
  }

  void dispose() {
    _playerController.dispose();
  }
}

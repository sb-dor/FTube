import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/blocs_and_cubits/youtube_video_cubit/state_model/youtube_video_state_modek.dart';
import 'package:youtube/blocs_and_cubits/youtube_video_cubit/youtube_video_states.dart';

class YoutubeVideoCubit extends Cubit<YoutubeVideoStates> {
  late YoutubeVideoStateModel currentState;

  YoutubeVideoCubit() : super(InitialYoutubeVideoState(YoutubeVideoStateModel())) {
    currentState = state.youtubeVideoStateModel;
  }

  // late PodPlayerController _playerController;
  //
  // PodPlayerController get playerController => _playerController;

  void init({required String url}) async {
    currentState.clearData();
    currentState.loadingVideo = true;
    emit(InitialYoutubeVideoState(currentState));
    currentState.playerController = VideoPlayerController.networkUrl(
        Uri.parse('https://packaged-media.redd.it/5cm4p6o15b4c1/pb/m2-res_640p.'
            'mp4?m=DASHPlaylist.mpd&v=1&e=1701795600&s=75de0a1556c6f64c2a4a574716722a4c7829d9d1#t=0'),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
        ));
    await currentState.playerController.initialize();
    await currentState.playerController.play();
    currentState.loadingVideo = false;

    emit(InitialYoutubeVideoState(currentState));
    currentState.playerController.addListener(_controllerListener);
  }

  void dispose() async {
    await currentState.playerController.dispose();
  }

  void _controllerListener() async {
    currentState.runningTime =
        currentState.globalFunc.getFromDuration(await currentState.playerController.position);

    if (currentState.playerController.value.isCompleted) {
      currentState.stopVideo = true;
    }

    if(currentState.playerController.value.)

    emit(InitialYoutubeVideoState(currentState));
  }

  void clickOnVideo({bool fromStopVideo = false}) {
    if (!fromStopVideo) currentState.clickedUpOnVideo = !currentState.clickedUpOnVideo;
    if (currentState.clickedUpOnVideo) {
      if ((currentState.timerForClickedUpOnVideo?.isActive ?? false)) {
        currentState.timerForClickedUpOnVideo?.cancel();
      }
      currentState.timerForClickedUpOnVideo = Timer(const Duration(seconds: 5), () {
        currentState.clickedUpOnVideo = false;
        emit(InitialYoutubeVideoState(currentState));
      });
    } else {
      if ((currentState.timerForClickedUpOnVideo?.isActive ?? false)) {
        currentState.timerForClickedUpOnVideo?.cancel();
      }
    }
    emit(InitialYoutubeVideoState(currentState));
  }

  void stopVideo() {
    currentState.stopVideo = !currentState.stopVideo;
    clickOnVideo(fromStopVideo: true);
    if (currentState.stopVideo) {
      currentState.playerController.pause();
    } else {
      currentState.playerController.play();
    }
  }
}

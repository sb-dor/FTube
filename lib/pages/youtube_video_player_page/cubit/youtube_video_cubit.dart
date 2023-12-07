import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'state_model/youtube_video_state_model.dart';
import 'youtube_video_states.dart';

class YoutubeVideoCubit extends Cubit<YoutubeVideoStates> {
  late YoutubeVideoStateModel currentState;

  YoutubeVideoCubit() : super(InitialYoutubeVideoState(YoutubeVideoStateModel())) {
    currentState = state.youtubeVideoStateModel;
  }

  //

  void init({required String url, required SingleTickerProviderStateMixin mixin}) async {
    currentState.clearData();
    currentState.loadingVideo = true;
    currentState.playPauseController =
        AnimationController(vsync: mixin, duration: const Duration(seconds: 1));
    currentState.playPauseAnimation =
        Tween<double>(begin: 0, end: 1).animate(currentState.playPauseController);
    emit(InitialYoutubeVideoState(currentState));
    await getVideoInformation(videoId: url);
    currentState.loadingVideo = false;

    emit(InitialYoutubeVideoState(currentState));
    currentState.playerController.addListener(_controllerListener);
  }

  Future<void> getVideoInformation({required String videoId}) async {
    try {
      // var getVideo = await currentState.youtubeExplode.videos.get(videoId);

      var informationVideo =
          await currentState.youtubeExplode.videos.streamsClient.getManifest(videoId);

      currentState.videosWithSound = informationVideo.video
          .where((e) =>
              e.size.totalMegaBytes >= 1 &&
              currentState.globalFunc.checkMp4FromURI(
                value: e.url.toString(),
              ))
          .toList();

      await currentState.deleteDuplicatedVideos();

      var minStreamVideo = await currentState.minStreamFromArray();

      debugPrint("min stream: ${minStreamVideo.size.totalMegaBytes}");

      // var getSmallSize = currentState.videos.firstWhere((el) => el)

      for (var element in currentState.videosWithSound) {
        log(element.url.toString());
        log(element.videoQuality.name);
        debugPrint("______");
      }

      currentState.playerController = VideoPlayerController.networkUrl(
        Uri.parse(
          minStreamVideo.url.toString(),
        ),
      );

      await currentState.playerController.initialize();

      await currentState.playerController.play();
    } catch (e) {
      emit(ErrorYoutubeVideoState(currentState));
    }
  }

  void dispose() async {
    await currentState.playerController.dispose();
    currentState.playPauseController.dispose();
  }

  void _controllerListener() async {
    currentState.runningTime =
        currentState.globalFunc.getFromDuration(await currentState.playerController.position);

    if (currentState.playerController.value.isCompleted) {
      currentState.playPauseController.forward();
      cancelTime();
      currentState.stopVideo = true;
      currentState.clickedUpOnVideo = true;
    }

    emit(InitialYoutubeVideoState(currentState));
  }

  void clickOnVideo({bool fromStopVideo = false}) {
    if (!fromStopVideo) currentState.clickedUpOnVideo = !currentState.clickedUpOnVideo;
    if (currentState.clickedUpOnVideo) {
      cancelTime();
      currentState.timerForClickedUpOnVideo = Timer(const Duration(seconds: 5), () {
        currentState.clickedUpOnVideo = false;
        emit(InitialYoutubeVideoState(currentState));
      });
    } else {
      cancelTime();
    }
    emit(InitialYoutubeVideoState(currentState));
  }

  void cancelTime() {
    if ((currentState.timerForClickedUpOnVideo?.isActive ?? false)) {
      currentState.timerForClickedUpOnVideo?.cancel();
    }
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

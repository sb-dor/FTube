import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/utils/duration_helper/duration_helper.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'state_model/youtube_video_state_model.dart';
import 'youtube_video_states.dart';
import 'package:youtube/models/video_modes/video.dart' as v;

class YoutubeVideoCubit extends Cubit<YoutubeVideoStates> {
  late YoutubeVideoStateModel currentState;

  YoutubeVideoCubit() : super(InitialYoutubeVideoState(YoutubeVideoStateModel())) {
    currentState = state.youtubeVideoStateModel;
  }

  //

  void init(
      {required String url,
      required SingleTickerProviderStateMixin mixin,
      required BuildContext context}) async {
    //clear data at first
    currentState.clearData();
    currentState.youtubeExplode = YoutubeExplode();
    currentState.loadingVideo = true;
    //init _stop_play button
    currentState.playPauseController =
        AnimationController(vsync: mixin, duration: const Duration(seconds: 1));
    currentState.playPauseAnimation =
        Tween<double>(begin: 0, end: 1).animate(currentState.playPauseController);
    // change the state
    emit(InitialYoutubeVideoState(currentState));
    //get information about video
    getVideoInformation(videoId: url, context: context);
    getVideo(videoId: url, context: context);
  }

  Future<void> getVideo({required String videoId, required BuildContext context}) async {
    try {
      // var getVideo = await currentState.youtubeExplode.videos.get(videoId);

      if (!context.mounted) return;

      var informationVideo =
          await currentState.youtubeExplode?.videos.streamsClient.getManifest(videoId);

      if (!context.mounted) return;

      currentState.videosWithSound = (informationVideo?.video ?? <VideoStreamInfo>[])
          .where((e) =>
              e.size.totalMegaBytes >= 1 &&
              currentState.globalFunc.checkMp4FromURI(
                value: e.url.toString(),
              ))
          .toList();

      if (!context.mounted) return;

      await currentState.deleteDuplicatedVideos();

      if (!context.mounted) return;

      var minStreamVideo = await currentState.minStreamFromArray();

      if (!context.mounted) return;
      //
      for (var element in currentState.videosWithSound) {
        debugPrint("______");
        log(element.url.toString());
        log(element.videoQuality.name);
        debugPrint("______");
      }

      if (!context.mounted) return;

      currentState.playerController =
          VideoPlayerController.networkUrl(Uri.parse(minStreamVideo.url.toString()));

      if (!context.mounted) return;

      await currentState.playerController?.initialize();

      await currentState.playerController?.play();

      currentState.loadingVideo = false;

      emit(InitialYoutubeVideoState(currentState));

      currentState.playerController?.addListener(_controllerListener);
    } catch (e) {
      emit(ErrorYoutubeVideoState(currentState));
    }
  }

  Future<void> getVideoInformation({required String videoId, required BuildContext context}) async {
    if (!context.mounted) return;

    var videoInfoCubit = BlocProvider.of<VideoInformationCubit>(context);

    videoInfoCubit.loadingVideoInformationState();

    try {
      var data = await RestApiGetVideoData.getVideoInfo(
          videoContent: TypeContent.snippet, videoId: videoId);

      if (data.containsKey('server_error') && data['server_error'] == true) {
        videoInfoCubit.errorVideoInformationState();
      } else if (data.containsKey('success') && data['success'] == true) {
        currentState.video = v.Video.fromJson(data['item']);
        await currentState.video?.snippet?.loadSnippetData();
        videoInfoCubit.loadedVideoInformationState();
        emit(InitialYoutubeVideoState(currentState));
      } else {
        videoInfoCubit.errorVideoInformationState();
      }
    } catch (e) {
      debugPrint("getVideoInformation: $e");
      videoInfoCubit.errorVideoInformationState();
    }
  }

  void dispose() async {
    await currentState.playerController?.dispose();
    currentState.playPauseController.dispose();
    currentState.youtubeExplode = null;
  }

  void _controllerListener() async {
    currentState.runningTime =
        DurationHelper.getFromDuration(await currentState.playerController?.position);

    if ((currentState.playerController?.value.isCompleted ?? false)) {
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
      currentState.playerController?.pause();
    } else {
      currentState.playerController?.play();
    }
  }
}

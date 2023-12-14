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
  late YoutubeVideoStateModel _currentState;

  YoutubeVideoCubit() : super(InitialYoutubeVideoState(YoutubeVideoStateModel())) {
    _currentState = state.youtubeVideoStateModel;
  }

  //

  void init(
      {required String url,
      required SingleTickerProviderStateMixin mixin,
      required BuildContext context}) async {
    //clear data at first
    _currentState.clearData();
    _currentState.youtubeExplode = YoutubeExplode();
    _currentState.loadingVideo = true;
    //init _stop_play button
    _currentState.playPauseController =
        AnimationController(vsync: mixin, duration: const Duration(seconds: 1));
    _currentState.playPauseAnimation =
        Tween<double>(begin: 0, end: 1).animate(_currentState.playPauseController);
    // change the state
    emit(InitialYoutubeVideoState(_currentState));
    //get information about video
    getVideoInformation(videoId: url, context: context);
    getVideo(videoId: url, context: context);
  }

  Future<void> getVideo({required String videoId, required BuildContext context}) async {
    try {
      // var getVideo = await _currentState.youtubeExplode.videos.get(videoId);

      if (!context.mounted) return;

      var informationVideo =
          await _currentState.youtubeExplode?.videos.streamsClient.getManifest(videoId);

      if (!context.mounted) return;

      _currentState.videosWithSound = (informationVideo?.video ?? <VideoStreamInfo>[])
          .where((e) =>
              e.size.totalMegaBytes >= 1 &&
              _currentState.globalFunc.checkMp4FromURI(
                value: e.url.toString(),
              ))
          .toList();

      if (!context.mounted) return;

      await _currentState.deleteDuplicatedVideos();

      if (!context.mounted) return;

      var minStreamVideo = await _currentState.minStreamFromArray();

      if (!context.mounted) return;
      //
      for (var element in _currentState.videosWithSound) {
        debugPrint("______");
        log(element.url.toString());
        log(element.videoQuality.name);
        debugPrint("______");
      }

      if (!context.mounted) return;

      _currentState.playerController =
          VideoPlayerController.networkUrl(Uri.parse(minStreamVideo.url.toString()));

      if (!context.mounted) return;

      await _currentState.playerController?.initialize();

      await _currentState.playerController?.play();

      _currentState.loadingVideo = false;

      emit(InitialYoutubeVideoState(_currentState));

      _currentState.playerController?.addListener(_controllerListener);
    } catch (e) {
      emit(ErrorYoutubeVideoState(_currentState));
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
        _currentState.video = v.Video.fromJson(data['item']);
        await _currentState.video?.snippet?.loadSnippetData();
        videoInfoCubit.loadedVideoInformationState();
        emit(InitialYoutubeVideoState(_currentState));
      } else {
        videoInfoCubit.errorVideoInformationState();
      }
    } catch (e) {
      debugPrint("getVideoInformation: $e");
      videoInfoCubit.errorVideoInformationState();
    }
  }

  void dispose() async {
    await _currentState.playerController?.dispose();
    _currentState.playerController = null;
    _currentState.playPauseController.dispose();
    _currentState.youtubeExplode = null;
  }

  void _controllerListener() async {
    _currentState.runningTime =
        DurationHelper.getFromDuration(await _currentState.playerController?.position);

    if ((_currentState.playerController?.value.isCompleted ?? false)) {
      _currentState.playPauseController.forward();
      cancelTime();
      _currentState.stopVideo = true;
      _currentState.clickedUpOnVideo = true;
    }

    emit(InitialYoutubeVideoState(_currentState));
  }

  void clickOnVideo({bool fromStopVideo = false}) {
    if (!fromStopVideo) _currentState.clickedUpOnVideo = !_currentState.clickedUpOnVideo;
    if (_currentState.clickedUpOnVideo) {
      cancelTime();
      _currentState.timerForClickedUpOnVideo = Timer(const Duration(seconds: 5), () {
        _currentState.clickedUpOnVideo = false;
        emit(InitialYoutubeVideoState(_currentState));
      });
    } else {
      cancelTime();
    }
    emit(InitialYoutubeVideoState(_currentState));
  }

  void cancelTime() {
    if ((_currentState.timerForClickedUpOnVideo?.isActive ?? false)) {
      _currentState.timerForClickedUpOnVideo?.cancel();
    }
  }

  void stopVideo() {
    _currentState.stopVideo = !_currentState.stopVideo;
    clickOnVideo(fromStopVideo: true);
    if (_currentState.stopVideo) {
      _currentState.playerController?.pause();
    } else {
      _currentState.playerController?.play();
    }
  }
}

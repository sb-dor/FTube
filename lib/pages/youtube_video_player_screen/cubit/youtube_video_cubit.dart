import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/usecases/download_video/download_video.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/utils/duration_helper/duration_helper.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'domain/usecases/get_video/get_video.dart';
import 'domain/usecases/get_video_information/get_video_information.dart';
import 'domain/usecases/pick_quality/pick_quality.dart';
import 'state_model/youtube_video_state_model.dart';
import 'youtube_video_states.dart';

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
    await initToken();
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
    if (context.mounted) await getVideoInformation(videoId: url, context: context);
    if (context.mounted) await getVideo(videoId: url, context: context);
  }

  Future<void> getVideo({required String videoId, required BuildContext context}) async {
    try {
      // var getVideo = await _currentState.youtubeExplode.videos.get(videoId);

      await GetVideo.getVideo(
        videoId: videoId,
        context: context,
        stateModel: _currentState,
        emit: emit,
      );

      _currentState.playerController?.addListener(_controllerListener);
    } catch (e) {
      debugPrint("the getVideo error is :$e");
      emit(ErrorYoutubeVideoState(_currentState));
    }
  }

  Future<void> getVideoInformation({required String videoId, required BuildContext context}) async {
    await GetVideoInformation.getVideoInformation(
      videoId: videoId,
      context: context,
      stateModel: _currentState,
      emit: emit,
    );
  }

  void dispose() async {
    await _currentState.playerController?.dispose();
    _currentState.playerController = null;
    _currentState.playPauseController.dispose();
    _currentState.youtubeExplode = null;
    _currentState.video = null;
    _currentState.tempMinAudioForVideo = null;
    emit(InitialYoutubeVideoState(_currentState));
  }

  void _controllerListener() async {
    _currentState.runningTime =
        DurationHelper.getFromDuration(await _currentState.playerController?.position);

    if ((_currentState.playerController?.value.isCompleted ?? false)) {
      _currentState.playPauseController.forward();
      _currentState.cancelTime();
      _currentState.stopVideo = true;
      _currentState.clickedUpOnVideo = true;
    }

    emit(InitialYoutubeVideoState(_currentState));
  }

  void clickOnVideo({bool fromStopVideo = false}) {
    if (!fromStopVideo) _currentState.clickedUpOnVideo = !_currentState.clickedUpOnVideo;
    if (_currentState.clickedUpOnVideo) {
      _currentState.cancelTime();
      _currentState.timerForClickedUpOnVideo = Timer(const Duration(seconds: 5), () {
        _currentState.clickedUpOnVideo = false;
        emit(InitialYoutubeVideoState(_currentState));
      });
    } else {
      _currentState.cancelTime();
    }
    emit(InitialYoutubeVideoState(_currentState));
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

  Future<void> pickQualityOfVideo({required VideoStreamInfo videoStreamInfo}) async {
    await PickQuality.pickQuality(
      stateModel: _currentState,
      videoStreamInfo: videoStreamInfo,
      emit: emit,
    );

    _currentState.playerController?.addListener(_controllerListener);
  }

  void clickTypeOfDownloadingVideo(DownloadingType downloadingType) {
    _currentState.downloadingType = downloadingType;
    emit(InitialYoutubeVideoState(_currentState));
  }

  void clearTypeOfDownloadingVideoOnPopup() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _currentState.downloadingType = null;
      emit(InitialYoutubeVideoState(_currentState));
    });
  }

  void onDownloadingError(BuildContext context) async {
    var downloadingCubit = BlocProvider.of<VideoDownloadingCubit>(context);
    downloadingCubit.videoDownloadingLoadedState();
    clearTypeOfDownloadingVideoOnPopup();
  }

  Future<void> cancelTheVideo() async {
    var downloadingCubit = BlocProvider.of<VideoDownloadingCubit>(
        GlobalContextHelper.instance.globalNavigatorContext.currentContext!);
    _currentState.cancelVideoToken.cancel();
    _currentState.cancelAudioToken.cancel();
    await initToken();
    downloadingCubit.state.tempDownloadingVideoInfo = null;
    downloadingCubit.videoDownloadingLoadedState();
    emit(InitialYoutubeVideoState(_currentState));
  }

  Future<void> initToken() async {
    if (_currentState.cancelVideoToken.isCancelled) {
      _currentState.cancelVideoToken = CancelToken();
    }
    if (_currentState.cancelAudioToken.isCancelled) {
      _currentState.cancelAudioToken = CancelToken();
    }
  }

  Future<void> downloadVideo(VideoStreamInfo video, DownloadingStoragePath path) async {
    await DownloadVideo.downloadVideo(
      video: video,
      stateModel: _currentState,
      path: path,
    );
  }

  Future<void> downloadAudio(AudioStreamInfo audioStreamInfo) async {
    await DownloadingAudioRepository().download(audioStreamInfo);
  }
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/duration_helper/duration_helper.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'logic/check_video_in_favorites/check_video_in_favorites.dart';
import 'logic/download_audio/download_audio.dart';
import 'logic/download_video/download_video.dart';
import 'logic/get_similar_videos/get_similar_videos.dart';
import 'logic/get_video/get_video.dart';
import 'logic/get_video_information/get_video_information.dart';
import 'logic/like_video/like_video.dart';
import 'logic/pick_quality/pick_quality.dart';
import 'state_model/youtube_video_state_model.dart';
import 'youtube_video_states.dart';

class YoutubeVideoCubit extends Cubit<YoutubeVideoStates> {
  late YoutubeVideoStateModel _currentState;
  final DbFloor _dbFloor;
  final YoutubeDataApi _youtubeDataApi;
  final Permissions _permissions;

  YoutubeVideoCubit(
      {required DbFloor dbFloor,
      required YoutubeDataApi youtubeDataApi,
      required Permissions permission,
      s})
      : _dbFloor = dbFloor,
        _youtubeDataApi = youtubeDataApi,
        _permissions = permission,
        super(InitialYoutubeVideoState(YoutubeVideoStateModel())) {
    _currentState = state.youtubeVideoStateModel;
  }

  //

  void init({
    required String url,
    required SingleTickerProviderStateMixin mixin,
    required BuildContext context,
    required bool paginating,
    String? videoPicture,
  }) async {
    //clear data at first
    _currentState.clearData();
    _currentState.videoPicture = videoPicture;
    _currentState.youtubeExplode = YoutubeExplode();
    _currentState.loadingVideo = true;
    _currentState.loadedMusicForBackground = false;
    _currentState.mediaItemForRunningInBackground = null;
    _currentState.videoUrlForOverlayRun = null;
    _currentState.isVideoAddedToBookMarks = false;
    _currentState.isVideoAddedToFavorites = false;

    // change the state
    emit(InitialYoutubeVideoState(_currentState));
    var similarVideosCubit = BlocProvider.of<SimilarVideosCubit>(context);
    similarVideosCubit.clearAndSetLoadingState();
    await initToken();

    //get information about video
    if (context.mounted) await getVideo(videoId: url, context: context);
    await checkVideoInFavorites();
    if (context.mounted) await getVideoInformation(videoId: url, context: context);
    await checkVideoInBookmarks(videoId: url);
    if (context.mounted) await getSimilarVideos(context: context, paginating: paginating);
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
      // debugPrint"the getVideo error is :$e");
      emit(ErrorYoutubeVideoState(_currentState));
    }
  }

  Future<void> getVideoInformation({required String videoId, required BuildContext context}) async {
    await GetVideoInformation(_youtubeDataApi).getVideoInformation(
      videoId: videoId,
      context: context,
      stateModel: _currentState,
      emit: emit,
    );
  }

  Future<void> getSimilarVideos({required BuildContext context, bool paginating = false}) async {
    await GetSimilarVideos(_youtubeDataApi).getSimilarVideos(
      videoTitle: _currentState.videoData?.video?.title ?? '',
      stateModel: _currentState,
      context: context,
      paginating: paginating,
    );
  }

  void dispose() async {
    await _currentState.playerController?.dispose();
    _currentState.playerController = null;
    _currentState.youtubeExplode = null;
    _currentState.videoData = null;
    _currentState.tempMinAudioForVideo = null;
    _currentState.videoUrlForOverlayRun = null;
    emit(InitialYoutubeVideoState(_currentState));
  }

  void _controllerListener() async {
    _currentState.runningTime = DurationHelper().getFromDuration(
      await _currentState.playerController?.position,
    );

    _currentState.lastVideoDurationForMediaBackground =
        await _currentState.playerController?.position;

    if ((_currentState.playerController?.value.isCompleted ?? false) ||
        !(_currentState.playerController?.value.isPlaying ?? false)) {
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
    var downloadingVideoCubit = BlocProvider.of<VideoDownloadingCubit>(context);
    var downloadingAudioCubit = BlocProvider.of<AudioDownloadingCubit>(context);
    downloadingVideoCubit.videoDownloadingLoadedState();
    downloadingAudioCubit.audioDownloadingLoadedState();
    clearTypeOfDownloadingVideoOnPopup();
  }

  Future<void> cancelTheVideo() async {
    var downloadingCubit = BlocProvider.of<VideoDownloadingCubit>(
        GlobalContextHelper.instance.globalNavigatorContext.currentContext!);
    await cancelTheAudio();
    _currentState.cancelVideoToken?.cancel();
    _currentState.cancelVideoToken = null;
    _currentState.isolateForDownloadingAudio
        ?.timeout(const Duration(milliseconds: 1))
        .then((value) => value.kill());
    downloadingCubit.state.tempDownloadingVideoInfo = null;
    downloadingCubit.state.tempDownloadingAudioInfo = null;
    await initToken();
    downloadingCubit.videoDownloadingLoadedState();
    emit(InitialYoutubeVideoState(_currentState));
  }

  Future<void> cancelTheAudio() async {
    var downloadingAudioCubit = BlocProvider.of<AudioDownloadingCubit>(
      GlobalContextHelper.instance.globalNavigatorContext.currentContext!,
    );
    _currentState.cancelAudioToken?.cancel();
    _currentState.cancelAudioToken = null;
    await initToken();
    downloadingAudioCubit.state.downloadingAudioInfo = null;
    downloadingAudioCubit.audioDownloadingLoadedState();
    emit(InitialYoutubeVideoState(_currentState));
  }

  Future<void> initToken() async {
    if (_currentState.cancelVideoToken == null ||
        (_currentState.cancelVideoToken?.isCancelled ?? false)) {
      _currentState.cancelVideoToken = CancelToken();
    }
    if (_currentState.cancelAudioToken == null ||
        (_currentState.cancelAudioToken?.isCancelled ?? false)) {
      _currentState.cancelAudioToken = CancelToken();
    }
  }

  Future<void> downloadVideo(VideoStreamInfo video, DownloadingStoragePath path) async {
    await DownloadVideo.downloadVideo(
      video: video,
      path: path,
      stateModel: _currentState,
      permissions: _permissions,
      dbFloor: _dbFloor,
    );
  }

  Future<void> downloadAudio({
    required AudioStreamInfo audioStreamInfo,
    required DownloadingStoragePath path,
  }) async {
    await DownloadAudio.download(
      audioStreamInfo: audioStreamInfo,
      path: path,
      stateModel: _currentState,
      dbFloor: _dbFloor,
      permissions: _permissions,
    );
  }

  bool showInformationInButtonIfTheSameVideoIsDownloading(BuildContext context) {
    var videoDownloaderCubit = BlocProvider.of<VideoDownloadingCubit>(context).state;
    return videoDownloaderCubit.tempDownloadingVideoInfo?.mainVideoId == _currentState.tempVideoId;
  }

  bool showInformationInButtonIfTheSameVideosAudioIsDownloading(BuildContext context) {
    var audioDownloadCubit = BlocProvider.of<AudioDownloadingCubit>(context).state;
    return audioDownloadCubit.downloadingAudioInfo?.mainVideoId == _currentState.tempVideoId;
  }

  Future<void> checkVideoInBookmarks({required String videoId}) async {
    // print("okay budd workuing here bro");
    final data = await _dbFloor.playListDao.getVideoFromPlaylistVideos(videoId);
    if (data != null) _currentState.isVideoAddedToBookMarks = true;
    emit(InitialYoutubeVideoState(_currentState));
  }

  Future<void> checkVideoInFavorites() async {
    await CheckVideoInFavorites(_dbFloor).checkVideoInFavorites(
      stateModel: _currentState,
      emit: emit,
    );
  }

  Future<void> likeVideo() async {
    await LikeVideo(_dbFloor).likeVideo(
      stateModel: _currentState,
      emit: emit,
    );
  }

  Future<void> seekToTheDurationPosition(Duration? duration) async {
    if (duration == null) return;
    _currentState.playerController?.seekTo(duration);
  }

  void loadedMusicForBackground({bool value = false}) {
    _currentState.loadedMusicForBackground = value;
    emit(InitialYoutubeVideoState(_currentState));
  }
}

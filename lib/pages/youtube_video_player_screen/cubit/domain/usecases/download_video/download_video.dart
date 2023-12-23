import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/repository/downloading_video_repository/downloading_video_repository.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/downloading_video_info.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadVideo {
  static ReusableGlobalFunctions globalFunc = ReusableGlobalFunctions.instance;

  static Future<void> downloadVideo({
    required VideoStreamInfo video,
    required YoutubeVideoStateModel stateModel,
    required DownloadingStoragePath path,
  }) async {
    var videoDownloadingCubit = BlocProvider.of<VideoDownloadingCubit>(
        GlobalContextHelper.instance.globalNavigatorContext.currentState!.context);
    try {
      if (videoDownloadingCubit.state.tempDownloadingVideoInfo != null) {
        globalFunc.showToast(
          msg: Constants.videoDownloadingInfo,
          typeError: true,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }
      videoDownloadingCubit.state.tempDownloadingVideoInfo = DownloadingVideoInfo(
        urlId: video.url.toString(),
        downloadingProgress: 0.0,
      );
      videoDownloadingCubit.videoDownloadingGettingInfoState();

      var downloadingVideo = await APISettings.dio.get<List<int>>(video.url.toString(),
          onReceiveProgress: (int receive, int total) {
        var solvePercentage = receive / total * 100;
        videoDownloadingCubit.state.tempDownloadingVideoInfo?.downloadingProgress =
            solvePercentage / 100;
        videoDownloadingCubit.videoDownloadingLoadingState();
      },
          options: Options(
            headers: await APISettings.headers(),
            responseType: ResponseType.bytes,
          ));

      await DownloadingVideoRepository(path).download(downloadingVideo.data);

      videoDownloadingCubit.state.tempDownloadingVideoInfo = null;

      if (path.name == DownloadingStoragePath.appStorage.name) {
        globalFunc.showToast(msg: Constants.videoSavedInAppStorageInfo);
      } else {
        globalFunc.showToast(msg: Constants.videoSavedInGalleryInfo);
      }

      videoDownloadingCubit.videoDownloadingLoadedState();
    } catch (e) {
      videoDownloadingCubit.state.tempDownloadingVideoInfo = null;
      videoDownloadingCubit.videoDownloadingErrorState();
      debugPrint("downloadInGallery error is $e");
    }
  }
}

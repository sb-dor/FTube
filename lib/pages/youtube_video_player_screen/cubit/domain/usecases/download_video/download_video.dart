import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
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

      // make here better

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

      if (globalFunc.checkMp4FromURI(value: video.url.toString())) {
        await DownloadingVideoRepository(path).download(downloadingVideo.data);
      } else {
        await _downloadVideoWithoutSound(
          videoDownloadingCubit: videoDownloadingCubit,
          stateModel: stateModel,
          downloadingVideo: downloadingVideo,
        );
      }

      videoDownloadingCubit.state.tempDownloadingVideoInfo = null;

      if (path.name == DownloadingStoragePath.appStorage.name) {
        globalFunc.showToast(msg: Constants.videoSavedInAppStorageInfo);
      } else {
        globalFunc.showToast(msg: Constants.videoSavedInGalleryInfo);
      }

      videoDownloadingCubit.videoDownloadingLoadedState();
    } on DioException catch (e) {
      if (e.type.name == 'cancel') return;
      videoDownloadingCubit.state.tempDownloadingVideoInfo = null;
      videoDownloadingCubit.videoDownloadingErrorState();
      debugPrint("downloadInGallery error is $e");
    }
  }

  static Future<void> _downloadVideoWithoutSound({
    required VideoDownloadingCubit videoDownloadingCubit,
    required YoutubeVideoStateModel stateModel,
    required Response<List<int>> downloadingVideo,
  }) async {
    debugPrint(
        "is working second download 2 | ${stateModel.tempMinAudioForVideo?.size.totalMegaBytes}"
        " | audio url : ${stateModel.tempMinAudioForVideo?.url.toString()}");
    videoDownloadingCubit.videoDownloadingGettingAudioInformationState();
    var downloadingAudio = await APISettings.dio
        .get<List<int>>(stateModel.tempMinAudioForVideo?.url.toString() ?? '',
            onReceiveProgress: (int receive, int total) {
      var solvePercentage = receive / total * 100;
      videoDownloadingCubit.state.tempDownloadingAudioInfo?.downloadingProgress =
          solvePercentage / 100;
      videoDownloadingCubit.videoDownloadingAudioState();
    },
            cancelToken: stateModel.cancelAudioToken,
            options: Options(
              headers: await APISettings.headers(),
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(minutes: 5),
            ));

    videoDownloadingCubit.videoDownloadingSavingOnStorageState();

    debugPrint("is working second download 3");

    var tempPath = await getTemporaryDirectory();

    var dateTime = DateTime.now();

    var newVideoPath =
        "${tempPath.path}/${globalFunc.removeSpaceFromStringForDownloadingVideo(dateTime.toString())}.mp4";
    var newAudioPath =
        "${tempPath.path}/${globalFunc.removeSpaceFromStringForDownloadingVideo(dateTime.toString())}.mp3";

    File newVideoFile = File(newVideoPath);
    File newAudioFile = File(newAudioPath);

    newVideoFile.writeAsBytesSync(downloadingVideo.data ?? []);
    newAudioFile.writeAsBytesSync(downloadingAudio.data ?? []);

    var getExStorage = await getExternalStorageDirectory();

    // create output path where file will be saved
    String outputPath =
        '${getExStorage?.path}/${Random().nextInt(pow(2, 10).toInt())}.mp4'; // remember to rename file all the time, other way file will be replaced with another file

    await FFmpegKit.execute('-i ${newVideoFile.path} -i ${newAudioFile.path} -c copy $outputPath')
        .then((value) async {
      final returnCode = await value.getReturnCode();
      debugPrint("result of audio and video");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("SUCCESS");
      } else if (ReturnCode.isCancel(returnCode)) {
        debugPrint("CANCEL");
      } else {
        debugPrint("ERROR");
      }
    });
  }
}

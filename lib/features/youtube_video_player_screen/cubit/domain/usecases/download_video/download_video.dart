import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_video_repository/downloading_video_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_video_info.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/utils/mixins/solve_percentage_mixin.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadVideo with SolvePercentageMixin {
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

      final receivePort = ReceivePort();
      List<int>? audioList;
      Stream<dynamic>? broadcastRp;
      if (!globalFunc.checkMp4FromURI(value: video.url.toString())) {
        Isolate.spawn(
          _downloadAudio,
          receivePort.sendPort,
        );

        broadcastRp = receivePort.asBroadcastStream();

        final SendPort communicatorSendPort = await broadcastRp.first;

        communicatorSendPort.send(stateModel.tempMinAudioForVideo?.url.toString());

        debugPrint("coming into here");

        broadcastRp.listen((message) async {
          debugPrint("message is here $message");
          audioList = message;
        });
      }

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

      // var downloadingVideo =
      //     await HttpDownloaderHelper.download(video.url.toString(), (total, downloading, progress) {
      //   debugPrint("total: $total | downloading: $downloading | progress: $progress");
      //   videoDownloadingCubit.state.tempDownloadingVideoInfo?.downloadingProgress = progress / 100;
      //   videoDownloadingCubit.videoDownloadingLoadingState();
      // });

      if (globalFunc.checkMp4FromURI(value: video.url.toString())) {
        await DownloadingVideoRepository(path).download(downloadingVideo.data);
      } else {
        debugPrint("then coming here");
        if (audioList == null) {
          broadcastRp?.listen((message) async {
            debugPrint("message is here 2 $message");
            await _downloadVideoWithoutSound(
              videoDownloadingCubit: videoDownloadingCubit,
              stateModel: stateModel,
              downloadingVideo: downloadingVideo.data ?? [],
              downloadingAudio: message,
              path: path,
            );
            // isolate?.kill();
          });
        } else {
          debugPrint("then coming here 2");
          await _downloadVideoWithoutSound(
            videoDownloadingCubit: videoDownloadingCubit,
            stateModel: stateModel,
            downloadingVideo: downloadingVideo.data ?? <int>[],
            downloadingAudio: audioList ?? <int>[],
            path: path,
          );
        }
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

  static void _downloadAudio(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final messages = receivePort.takeWhile((element) => element is String).cast<String>();

    Response<List<int>>? downloadingAudio;

    await for (var each in messages) {
      try {
        downloadingAudio = await Dio().get<List<int>>(each,
            onReceiveProgress: (int receive, int total) {},
            options: Options(
              headers: await APISettings.headers(),
              responseType: ResponseType.bytes,
              receiveDataWhenStatusError: true,
              receiveTimeout: const Duration(minutes: 5),
            ));

        // var downloadingAudio =
        //     await HttpDownloaderHelper.download(url, (total, downloading, progress) {});

        sendPort.send(downloadingAudio.data ?? []);
      } catch (e) {
        sendPort.send(downloadingAudio?.data ?? []);
      }
    }
  }

  static Future<void> _downloadVideoWithoutSound(
      {required VideoDownloadingCubit videoDownloadingCubit,
      required YoutubeVideoStateModel stateModel,
      required List<int> downloadingVideo,
      required List<int> downloadingAudio,
      required DownloadingStoragePath path}) async {
    log("getting downloading audio list: $downloadingAudio");

    videoDownloadingCubit.videoDownloadingSavingOnStorageState();

    var tempPath = await getTemporaryDirectory();

    var dateTime = DateTime.now();

    var newVideoPath =
        "${tempPath.path}/${globalFunc.removeSpaceFromStringForDownloadingVideo(dateTime.toString())}_video.mp4";
    var newAudioPath =
        "${tempPath.path}/${globalFunc.removeSpaceFromStringForDownloadingVideo(dateTime.toString())}_sound.mp3";

    File newVideoFile = File(newVideoPath);
    File newAudioFile = File(newAudioPath);

    newVideoFile.writeAsBytesSync(downloadingVideo);
    newAudioFile.writeAsBytesSync(downloadingAudio);

    var getExStorage = await getExternalStorageDirectory();

    // create output path where file will be saved

    dateTime = DateTime.now();

    String outputPath =
        '${getExStorage?.path}/${globalFunc.removeSpaceFromStringForDownloadingVideo(dateTime.toString())}.mp4'; // remember to rename file all the time, other way file will be replaced with another file

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

    if (path.name == DownloadingStoragePath.gallery.name) {
      await Gal.putVideo(outputPath);
    }

    videoDownloadingCubit.videoDownloadingLoadedState();
  }
}

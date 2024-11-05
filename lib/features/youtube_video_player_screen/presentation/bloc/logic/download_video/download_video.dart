import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/utils/mixins/solve_percentage_mixin.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_video_info.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadVideo with SolvePercentageMixin {
  static final ReusableGlobalFunctions _globalFunc = locator<ReusableGlobalFunctions>();
  static final GlobalContextHelper _globalContextHelper = locator<GlobalContextHelper>();

  static Future<void> downloadVideo({
    required VideoStreamInfo video,
    required YoutubeVideoStateModel stateModel,
    required DownloadingStoragePath path,
  }) async {
    var videoDownloadingCubit = BlocProvider.of<VideoDownloadingCubit>(
      _globalContextHelper.globalNavigatorContext.currentState!.context,
    );
    var audioDownloadingCubit = BlocProvider.of<AudioDownloadingCubit>(
      _globalContextHelper.globalNavigatorContext.currentState!.context,
    );
    try {
      if (audioDownloadingCubit.state.downloadingAudioInfo != null) {
        _globalFunc.showToast(
          msg: Constants.videoDownloadingInfo,
          typeError: true,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }
      if (videoDownloadingCubit.state.isDownloading) {
        _globalFunc.showToast(
          msg: Constants.audioDownloadingInfo,
          typeError: true,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }
      videoDownloadingCubit.state.tempDownloadingVideoInfo = DownloadingVideoInfo(
        urlId: video.url.toString(),
        downloadingProgress: 0.0,
        mainVideoId: stateModel.tempVideoId,
      );

      videoDownloadingCubit.videoDownloadingGettingInfoState();

      // make here better

      final receivePort = ReceivePort();
      List<int>? audioList;
      Stream<dynamic>? broadcastRp;
      if (!_globalFunc.checkMp4FromURI(value: video.url.toString())) {
        stateModel.isolateForDownloadingAudio = Isolate.spawn(
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

      var downloadingVideo = await APISettings.dio.get<List<int>>(
        video.url.toString(),
        cancelToken: stateModel.cancelVideoToken,
        onReceiveProgress: (int receive, int total) {
          var solvePercentage = receive / total * 100;
          videoDownloadingCubit.state.tempDownloadingVideoInfo?.downloadingProgress =
              solvePercentage / 100;
          videoDownloadingCubit.videoDownloadingLoadingState();
          // debugPrint("still downloading");
        },
        options: Options(
          headers: await APISettings.headers(),
          responseType: ResponseType.bytes,
          receiveDataWhenStatusError: true,
          receiveTimeout: const Duration(minutes: 5),
          persistentConnection: true,
        ),
      );

      // var downloadingVideo =
      //     await HttpDownloaderHelper.download(video.url.toString(), (total, downloading, progress) {
      //   debugPrint("total: $total | downloading: $downloading | progress: $progress");
      //   videoDownloadingCubit.state.tempDownloadingVideoInfo?.downloadingProgress = progress / 100;
      //   videoDownloadingCubit.videoDownloadingLoadingState();
      // });

      if (_globalFunc.checkMp4FromURI(value: video.url.toString())) {
        await DownloadingVideoRepository(path).download(
          downloadingVideo.data,
          stateModel,
        );
        stateModel.isolateForDownloadingAudio = null;
      } else {
        debugPrint("then coming here");
        if (audioList == null) {
          broadcastRp?.listen((message) async {
            debugPrint("message is here 2 $message");
            await _downloadVideoWithoutSound(
              videoDownloadingCubit: videoDownloadingCubit,
              stateModel: stateModel,
              downloadingVideo: downloadingVideo.data ?? <int>[],
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
        _globalFunc.showToast(msg: Constants.videoSavedInAppStorageInfo);
      } else {
        _globalFunc.showToast(msg: Constants.videoSavedInGalleryInfo);
      }

      videoDownloadingCubit.videoDownloadingLoadedState();
    } on DioException catch (e) {
      if (e.type.name == 'cancel') return;
      videoDownloadingCubit.state.tempDownloadingVideoInfo = null;
      videoDownloadingCubit.videoDownloadingErrorState();
      debugPrint("downloadInGallery error is $e");
    } catch (e) {
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
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
                "Connection": "Keep-Alive",
                "Keep-Alive": "timeout=500, max=1000"
              },
              responseType: ResponseType.bytes,
              receiveDataWhenStatusError: true,
              receiveTimeout: const Duration(minutes: 5),
              persistentConnection: true,
            ));
        // var downloadingAudio =
        //     await HttpDownloaderHelper.download(url, (total, downloading, progress) {});

        sendPort.send(downloadingAudio.data ?? <int>[]);
      } catch (e) {
        sendPort.send(downloadingAudio?.data ?? <int>[]);
      }
    }
  }

  static Future<void> _downloadVideoWithoutSound({
    required VideoDownloadingCubit videoDownloadingCubit,
    required YoutubeVideoStateModel stateModel,
    required List<int> downloadingVideo,
    required List<int> downloadingAudio,
    required DownloadingStoragePath path,
  }) async {
    videoDownloadingCubit.videoDownloadingSavingOnStorageState();

    var tempPath = await getTemporaryDirectory();

    String videoName = stateModel.videoData?.video?.title ?? '-';

    var newVideoPath =
        "${tempPath.path}/${_globalFunc.removeSpaceFromStringForDownloadingVideo("${videoName}_${downloadingVideo.length}")}_video.mp4";
    var newAudioPath =
        "${tempPath.path}/${_globalFunc.removeSpaceFromStringForDownloadingVideo("${videoName}_${downloadingAudio.length}")}_sound.mp3";

    File newVideoFile = File(newVideoPath);
    File newAudioFile = File(newAudioPath);

    if (!newVideoFile.existsSync()) newVideoFile.writeAsBytesSync(downloadingVideo);
    if (!newAudioFile.existsSync()) newAudioFile.writeAsBytesSync(downloadingAudio);

    // create output path where file will be saved

    var dateTime = DateTime.now();

    String outputPath =
        "${tempPath.path}/${_globalFunc.removeSpaceFromStringForDownloadingVideo("$videoName"
            "_${downloadingVideo.length + downloadingAudio.length}_$dateTime")}.mp4"; // remember to rename file all the time, other way file will be replaced with another file

    // final command =
    //     '-i ${newVideoFile.path} -i ${newAudioFile.path} -c:v copy -c:a aac -strict experimental $outputPath';
    //
    // final command2 = '-i ${newAudioFile.path} -i ${newVideoFile.path} -c copy $outputPath';
    //
    // final command3 =
    //     "-y -i ${newVideoFile.path} -i ${newAudioFile.path} -map 0:v -map 1:a -c:v copy "
    //     "-shortest $outputPath";
    //
    // final command4 =
    //     "-i ${newVideoFile.path} -i ${newAudioFile.path} -c:v copy -c:a copy $outputPath";
    //
    // final command5 =
    //     "-i ${newVideoFile.path} -i ${newAudioFile.path} -c:v copy -map 0:v -map 1:a -y $outputPath";

    final command6 = "-i ${newVideoFile.path} -i ${newAudioFile.path} -c:v copy -c:a aac -map 0:v:0"
        " -map 1:a:0 -shortest $outputPath";

    await FFmpegKit.execute(command6).then((value) async {
      final returnCode = await value.getReturnCode();
      log("result of audio and video logs: ${await value.getAllLogsAsString()}");
      log("result of fail: ${await value.getFailStackTrace()}");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("SUCCESS");
        await DownloadingVideoRepository(path).download(
          File(outputPath).readAsBytesSync(),
          stateModel,
        );
      } else if (ReturnCode.isCancel(returnCode)) {
        debugPrint("CANCEL");
      } else {
        stateModel.globalFunc.showToast(
          msg: Constants.videoDownloadingErrorOccurred,
          typeError: true,
          toastLength: Toast.LENGTH_LONG,
        );
        debugPrint("ERROR");
      }
    });

    stateModel.isolateForDownloadingAudio = null;

    videoDownloadingCubit.videoDownloadingLoadedState();
  }
}

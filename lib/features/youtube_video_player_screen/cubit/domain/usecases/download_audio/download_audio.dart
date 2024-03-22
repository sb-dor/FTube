import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadAudio {
  static final GlobalContextHelper _contextHelper = locator<GlobalContextHelper>();
  static final ReusableGlobalFunctions _globalFunc = locator<ReusableGlobalFunctions>();

  static Future<void> download({
    required AudioStreamInfo audioStreamInfo,
    required DownloadingStoragePath path,
    required YoutubeVideoStateModel stateModel,
  }) async {
    var audioDownloadingCubit = BlocProvider.of<AudioDownloadingCubit>(
      _contextHelper.globalNavigatorContext.currentState!.context,
    );

    var videoDownloadingCubit = BlocProvider.of<VideoDownloadingCubit>(
      _contextHelper.globalNavigatorContext.currentState!.context,
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

      audioDownloadingCubit.state.downloadingAudioInfo = DownloadingAudioInfo(
        urlId: audioStreamInfo.url.toString(),
        downloadingProgress: 0.0,
        mainVideoId: stateModel.tempVideoId,

      );
      audioDownloadingCubit.audioGettingInformationState();
      debugPrint(
          "audio url: |${audioStreamInfo.size.totalKiloBytes}| ${audioStreamInfo.url.toString()}");
      var data = await APISettings.dio.get<List<int>>(audioStreamInfo.url.toString(),
          cancelToken: stateModel.cancelAudioToken, onReceiveProgress: (int receive, int total) {
        audioDownloadingCubit.state.downloadingAudioInfo?.downloadingProgress = receive / total;
        audioDownloadingCubit.audioDownloadingState();
      },
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              "Connection": "Keep-Alive",
              "Keep-Alive": "timeout=500, max=1000"
            },
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(minutes: 5),
            receiveDataWhenStatusError: true,
          ));

      audioDownloadingCubit.audioSavingOnStorageState();

      await DownloadingAudioRepository(path).download(
        data.data,
        stateModel,
      );

      audioDownloadingCubit.state.downloadingAudioInfo = null;

      audioDownloadingCubit.audioDownloadingLoadedState();
    } on DioException catch (e) {
      if (e.type.name == 'cancel') return;
      audioDownloadingCubit.state.downloadingAudioInfo = null;
      audioDownloadingCubit.audioDownloadingErrorState();
      debugPrint("download audio error is : $e");
    } catch (e) {
      audioDownloadingCubit.state.downloadingAudioInfo = null;
      audioDownloadingCubit.audioDownloadingErrorState();
      debugPrint("download audio error is : $e");
    }
  }
}

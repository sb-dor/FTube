import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/downloading_audio_usecase.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadAudio {
  static final GlobalContextHelper _contextHelper = GlobalContextHelper.instance;
  static final ReusableGlobalFunctions _globalFunc = ReusableGlobalFunctions.instance;

  static Future<void> download({
    required AudioStreamInfo audioStreamInfo,
    required DownloadingStoragePath path,
    required YoutubeVideoStateModel stateModel,
    required DbFloor dbFloor,
    required Permissions permissions,
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
      // debugPrint
      //     "audio url: |${audioStreamInfo.size.totalKiloBytes}| ${audioStreamInfo.url.toString()}");
      var data = await APISettings.dio.get<List<int>>(
        audioStreamInfo.url.toString(),
        cancelToken: stateModel.cancelAudioToken,
        onReceiveProgress: (int receive, int total) {
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
        ),
      );

      audioDownloadingCubit.audioSavingOnStorageState();

      await DownloadingAudioUseCase(
        path,
        dbFloor,
        permissions,
      ).download(
        downloadingVideo: data.data,
        stateModel: stateModel,
      );

      audioDownloadingCubit.state.downloadingAudioInfo = null;

      audioDownloadingCubit.audioDownloadingLoadedState();
    } on DioException catch (e) {
      if (e.type.name == 'cancel') return;
      audioDownloadingCubit.state.downloadingAudioInfo = null;
      audioDownloadingCubit.audioDownloadingErrorState();
      // debugPrint"download audio error is : $e");
    } catch (e) {
      audioDownloadingCubit.state.downloadingAudioInfo = null;
      audioDownloadingCubit.audioDownloadingErrorState();
      // debugPrint"download audio error is : $e");
    }
  }
}

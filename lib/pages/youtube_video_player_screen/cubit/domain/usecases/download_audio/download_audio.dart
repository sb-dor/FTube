import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadAudio {
  static final GlobalContextHelper _contextHelper = GlobalContextHelper.instance;

  static Future<void> download({
    required AudioStreamInfo audioStreamInfo,
    required DownloadingStoragePath path,
  }) async {
    var audioDownloadingCubit = BlocProvider.of<AudioDownloadingCubit>(
      _contextHelper.globalNavigatorContext.currentState!.context,
    );
    try {
      audioDownloadingCubit.state.downloadingAudioInfo = DownloadingAudioInfo(
        urlId: audioStreamInfo.url.toString(),
        downloadingProgress: 0.0,
      );
      audioDownloadingCubit.audioGettingInformationState();
      debugPrint(
          "audio url: |${audioStreamInfo.size.totalKiloBytes}| ${audioStreamInfo.url.toString()}");
      var data = await APISettings.dio.get<List<int>>(audioStreamInfo.url.toString(),
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
          ));

      audioDownloadingCubit.audioSavingOnStorageState();

      await DownloadingAudioRepository(path).download(data.data);

      audioDownloadingCubit.audioDownloadingLoadedState();
    } catch (e) {
      audioDownloadingCubit.state.downloadingAudioInfo = null;
      audioDownloadingCubit.audioDownloadingErrorState();
      debugPrint("download audio error is : $e");
    }
  }
}

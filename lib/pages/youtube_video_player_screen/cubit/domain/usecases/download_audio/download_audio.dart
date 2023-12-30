import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadAudio implements DownloadingAudioRepository {
  @override
  Future<void> download(AudioStreamInfo audioStreamInfo) async {
    debugPrint("audio url: |${audioStreamInfo.size.totalKiloBytes}| ${audioStreamInfo.url.toString()}");
    await APISettings.dio.get<List<int>>(audioStreamInfo.url.toString(),
        onReceiveProgress: (int receive, int total) {
      debugPrint("receiving : $receive | total: $total");
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
  }
}

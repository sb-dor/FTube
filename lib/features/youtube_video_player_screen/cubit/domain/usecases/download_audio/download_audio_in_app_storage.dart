import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class DownloadAudioInAppStorage implements DownloadingAudioRepository {
  final ReusableGlobalFunctions _reusableGlobalFunctions = ReusableGlobalFunctions.instance;

  @override
  Future<void> download(List<int>? downloadData, String audioName) async {
    var getExternalStoragePath = await getExternalStorageDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getExternalStoragePath?.path}/'
        '${audioName}_${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(dateTimeForVideoName.toString())}.mp3';

    File fileForSaving = File(pathOfVideo);

    if (downloadData != null && downloadData.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadData);
    }
  }
}

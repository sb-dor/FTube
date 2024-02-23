import 'dart:io';

import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class DownloadAudioInDownloadsFolder implements DownloadingAudioRepository {
  final ReusableGlobalFunctions _reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(List<int>? downloadData, String audioName) async {
    var directory = await DownloadsPath.downloadsDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${directory?.path}/'
        '${audioName}_${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(dateTimeForVideoName.toString())}.mp3';

    File fileForSaving = File(pathOfVideo);

    if (downloadData != null && downloadData.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadData);
    }
  }
}

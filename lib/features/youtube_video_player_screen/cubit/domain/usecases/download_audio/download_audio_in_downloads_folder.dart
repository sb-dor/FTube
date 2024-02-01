import 'dart:io';

import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class DownloadAudioInDownloadsFolder implements DownloadingAudioRepository {
  final ReusableGlobalFunctions _reusableGlobalFunctions = ReusableGlobalFunctions.instance;

  @override
  Future<void> download(List<int>? downloadData) async {
    var directory = await DownloadsPath.downloadsDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${directory?.path}/'
        '${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(dateTimeForVideoName.toString())}.mp3';

    File fileForSaving = File(pathOfVideo);

    if (downloadData != null && downloadData.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadData);
    }
  }
}

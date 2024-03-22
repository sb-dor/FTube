import 'dart:io';

import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_audio_repository/downloading_audio_repository.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class DownloadAudioInDownloadsFolder implements DownloadingAudioRepository {
  final ReusableGlobalFunctions _reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(List<int>? downloadData, YoutubeVideoStateModel stateModel) async {
    var directory = await DownloadsPath.downloadsDirectory();

    var dateTimeForAudioName = DateTime.now();

    var pathOfAudio = '${directory?.path}/'
        '${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? '-'}"
            "_${dateTimeForAudioName.toString()}")}.mp3';

    File fileForSaving = File(pathOfAudio);

    if (downloadData != null && downloadData.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadData);
    }
  }
}

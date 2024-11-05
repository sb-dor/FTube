import 'dart:io';

import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/mixins/storage_helper.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import '../i_downloading.dart';

class DownloadAudioInAppStorage with StorageHelper implements IDownloading {
  final ReusableGlobalFunctions _reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(
    List<int>? downloadData,
    YoutubeVideoStateModel stateModel,
  ) async {
    var getExternalStoragePath = await getStorage();

    var dateTimeForAudioName = DateTime.now();

    var pathOfAudio = '${getExternalStoragePath?.path}/'
        '${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? '-'}"
            "_${dateTimeForAudioName.toString()}")}'
        '_videoId_${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(stateModel.tempVideoId ?? '')}.mp3';

    File fileForSaving = File(pathOfAudio);

    if (downloadData != null && downloadData.isNotEmpty) {
      var data = FileDownloadModel.fromVideoData(stateModel.videoData);
      data.imagePath = stateModel.videoPicture;
      data.downloadedPath = pathOfAudio;
      fileForSaving.writeAsBytesSync(downloadData);
      await locator<DbFloor>().downloadedFiles.insertDownloadedFile(data);
    }
  }
}

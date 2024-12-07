import 'dart:io';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/mixins/storage_helper.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/i_downloading.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

class DownloadVideoInAppStorage with StorageHelper implements IDownloading {
  ReusableGlobalFunctions reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(
    List<int>? downloadingVideo,
    YoutubeVideoStateModel stateModel,
  ) async {
    final getExternalStoragePath = await getStorage();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getExternalStoragePath?.path}/'
        '${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? "-"}"
            "_${dateTimeForVideoName.toString()}")}'
        '_videoId_${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(stateModel.tempVideoId ?? '')}.mp4';

    File fileForSaving = File(pathOfVideo);

    if (downloadingVideo != null && downloadingVideo.isNotEmpty) {
      var data = FileDownloadModel.fromVideoData(stateModel.videoData);
      data.imagePath = stateModel.videoPicture;
      data.downloadedPath = pathOfVideo;
      fileForSaving.writeAsBytesSync(downloadingVideo);
      await locator<DbFloor>().downloadedFiles.insertDownloadedFile(data);
    }
  }
}

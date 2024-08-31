import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_video_repository/downloading_video_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/utils/mixins/storage_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class DownloadVideoInAppStorage with StorageHelper implements DownloadingVideoRepository {
  ReusableGlobalFunctions reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(List<int>? downloadingVideo, YoutubeVideoStateModel stateModel) async {
    final getExternalStoragePath = await getStorage();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getExternalStoragePath?.path}/'
        '${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? "-"}_${dateTimeForVideoName.toString()}")}.mp4';

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

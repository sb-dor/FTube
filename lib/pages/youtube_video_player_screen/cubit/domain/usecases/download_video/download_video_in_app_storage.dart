import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/repository/downloading_video_repository/downloading_video_repository.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class DownloadVideoInAppStorage implements DownloadingVideoRepository {
  ReusableGlobalFunctions reusableGlobalFunctions = ReusableGlobalFunctions.instance;

  @override
  Future<void> download(List<int>? downloadingVideo) async {
    var getExternalStoragePath = await getExternalStorageDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getExternalStoragePath?.path}/'
        '${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(dateTimeForVideoName.toString())}.mp4';

    File fileForSaving = File(pathOfVideo);

    if (downloadingVideo != null && downloadingVideo.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadingVideo);
    }
  }
}

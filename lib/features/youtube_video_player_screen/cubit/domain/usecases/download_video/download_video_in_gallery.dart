import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/repository/downloading_video_repository/downloading_video_repository.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class DownloadVideoInGallery implements DownloadingVideoRepository {
  ReusableGlobalFunctions reusableGlobalFunctions = locator<ReusableGlobalFunctions>();

  @override
  Future<void> download(List<int>? downloadingVideo, String videoName) async {
    var getTemporaryPath = await getTemporaryDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getTemporaryPath.path}/'
        '${videoName}_${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(dateTimeForVideoName.toString())}.mp4';

    File fileForSaving = File(pathOfVideo);

    if (downloadingVideo != null && downloadingVideo.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadingVideo);
      await Gal.putVideo(fileForSaving.path);
    }
  }
}

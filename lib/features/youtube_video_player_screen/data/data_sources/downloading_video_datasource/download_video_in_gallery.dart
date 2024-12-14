import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/i_downloading.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

class DownloadVideoInGallery implements IDownloading {
  ReusableGlobalFunctions reusableGlobalFunctions = ReusableGlobalFunctions.instance;

  @override
  Future<void> download(
    List<int>? downloadingVideo,
    YoutubeVideoStateModel stateModel,
  ) async {
    var getTemporaryPath = await getTemporaryDirectory();

    var dateTimeForVideoName = DateTime.now();

    var pathOfVideo = '${getTemporaryPath.path}/'
        '${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? '-'}"
            "_${dateTimeForVideoName.toString()}")}.mp4';

    File fileForSaving = File(pathOfVideo);

    if (downloadingVideo != null && downloadingVideo.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadingVideo);
      await Gal.putVideo(fileForSaving.path);
    }
  }
}

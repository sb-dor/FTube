import 'dart:io';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';
import 'package:youtube/core/utils/mixins/storage_helper.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/i_downloading.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

class DownloadVideoInAppStorage with StorageHelper implements IDownloading {
  ReusableGlobalFunctions reusableGlobalFunctions = ReusableGlobalFunctions.instance;
  final DbFloor _dbFloor;

  DownloadVideoInAppStorage(this._dbFloor);

  @override
  Future<void> download(List<int>? downloadingVideo, YoutubeVideoStateModel stateModel) async {
    final getExternalStoragePath = await getStorage();

    final dateTimeForVideoName = DateTime.now();

    final pathOfVideo =
        '${getExternalStoragePath?.path}/'
        '${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? "-"}"
        "_${dateTimeForVideoName.toString()}")}'
        '_videoId_${reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo(stateModel.tempVideoId ?? '')}.mp4';

    final File fileForSaving = File(pathOfVideo);

    if (downloadingVideo != null && downloadingVideo.isNotEmpty) {
      final data = FileDownloadModel.fromVideoData(stateModel.videoData);
      data.imagePath = stateModel.videoPicture;
      data.downloadedPath = pathOfVideo;
      fileForSaving.writeAsBytesSync(downloadingVideo);
      await _dbFloor.downloadedFiles.insertDownloadedFile(data);
    }
  }
}

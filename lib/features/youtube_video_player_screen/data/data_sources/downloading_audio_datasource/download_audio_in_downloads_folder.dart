import 'dart:io';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/i_downloading.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

class DownloadAudioInDownloadsFolder implements IDownloading {
  final ReusableGlobalFunctions _reusableGlobalFunctions = ReusableGlobalFunctions.instance;
  final Permissions _permissions;

  DownloadAudioInDownloadsFolder(this._permissions);

  @override
  Future<void> download(
    List<int>? downloadData,
    YoutubeVideoStateModel stateModel,
  ) async {
    // Check for permission to access storage

    final externalStoragePermission = await _permissions.manageExternalStoragePermission();

    final storagePermission = await _permissions.storagePermission();

    if (!externalStoragePermission && !storagePermission) return;

    // debugPrint"permission coming here");

    final directory = await DownloadsPath.downloadsDirectory();

    final dateTimeForAudioName = DateTime.now();

    final pathOfAudio = '${directory?.path}/'
        '${_reusableGlobalFunctions.removeSpaceFromStringForDownloadingVideo("${stateModel.videoData?.video?.title ?? '-'}"
            "_${dateTimeForAudioName.toString()}")}.mp3';

    final File fileForSaving = File(pathOfAudio);

    if (downloadData != null && downloadData.isNotEmpty) {
      fileForSaving.writeAsBytesSync(downloadData);
    }
  }
}

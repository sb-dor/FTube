import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import '../i_downloading.dart';

class DownloadAudioInDownloadsFolder implements IDownloading {
  final ReusableGlobalFunctions _reusableGlobalFunctions = locator<ReusableGlobalFunctions>();
  final Permissions _permissions = locator<Permissions>();

  @override
  Future<void> download(
    List<int>? downloadData,
    YoutubeVideoStateModel stateModel,
  ) async {
    // Check for permission to access storage

    final externalStoragePermission = await _permissions.manageExternalStoragePermission();

    final storagePermission = await _permissions.storagePermission();

    if (!externalStoragePermission && !storagePermission) return;

    debugPrint("permission coming here");

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

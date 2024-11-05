import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_downloads_folder.dart';

final class DownloadingAudioUseCase {
  final DownloadingStoragePath path;

  DownloadingAudioUseCase(this.path);

  DownloadingAudioRepository get repo {
    switch (path) {
      case DownloadingStoragePath.appStorage:
        return DownloadAudioInAppStorage();
      case DownloadingStoragePath.downloads:
        return DownloadAudioInDownloadsFolder();
      default:
        return DownloadAudioInAppStorage();
    }
  }
}

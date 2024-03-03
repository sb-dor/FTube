import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio_in_downloads_folder.dart';
import 'package:youtube/utils/enums.dart';

abstract class DownloadingAudioRepository {
  Future<void> download(List<int>? downloadData, String audioName);

  factory DownloadingAudioRepository(DownloadingStoragePath path) {
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

import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio_in_gallery.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadingAudioRepository {
  Future<void> download(List<int>? downloadData);

  factory DownloadingAudioRepository(DownloadingStoragePath path) {
    switch (path) {
      case DownloadingStoragePath.appStorage:
        return DownloadAudioInAppStorage();
      case DownloadingStoragePath.gallery:
        return DownloadAudioInGallery();
      default:
        return DownloadAudioInAppStorage();
    }
  }
}

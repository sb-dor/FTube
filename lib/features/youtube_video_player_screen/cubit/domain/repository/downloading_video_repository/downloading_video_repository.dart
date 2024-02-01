import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_video/download_video_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/domain/usecases/download_video/download_video_in_gallery.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadingVideoRepository {
  Future<void> download(List<int>? downloadingVideo, String videoName);

  factory DownloadingVideoRepository(DownloadingStoragePath path) {
    switch (path) {
      case DownloadingStoragePath.appStorage:
        return DownloadVideoInAppStorage();
      case DownloadingStoragePath.gallery:
        return DownloadVideoInGallery();
      default:
        return DownloadVideoInAppStorage();
    }
  }
}

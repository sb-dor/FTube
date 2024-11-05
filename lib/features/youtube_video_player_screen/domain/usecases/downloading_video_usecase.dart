import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_gallery.dart';

final class DownloadingVideoUseCase {
  final DownloadingStoragePath path;

  DownloadingVideoUseCase(this.path);

  DownloadingVideoRepository get repo {
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

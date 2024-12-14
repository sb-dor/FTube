import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_downloads_folder.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_gallery.dart';
import 'package:youtube/features/youtube_video_player_screen/data/repo/downloading_repo_impl.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';

final class YtDownloadingRepoFactory implements Factory<DownloadingRepository> {
  YtDownloadingRepoFactory({required DownloadingStoragePath downloadingStoragePath})
      : _downloadingStoragePath = downloadingStoragePath;

  final DownloadingStoragePath _downloadingStoragePath;

  @override
  DownloadingRepository create() {
    final audioAppStorage = DownloadAudioInAppStorage();
    final videoAppStorage = DownloadVideoInAppStorage();

    final audioPhoneStorage = DownloadAudioInDownloadsFolder();
    final videoPhoneStorage = DownloadVideoInGallery();

    final DownloadingRepository downloadingAppStorageImpl = DownloadingVideoRepoImpl(
      audioAppStorage,
      videoAppStorage,
    );

    final DownloadingRepository downloadInPhoneStorage = DownloadingVideoRepoImpl(
      audioPhoneStorage,
      videoPhoneStorage,
    );

    switch (_downloadingStoragePath) {
      case DownloadingStoragePath.appStorage:
        return downloadingAppStorageImpl;
      case DownloadingStoragePath.phoneStorage:
        return downloadInPhoneStorage;
    }
  }
}

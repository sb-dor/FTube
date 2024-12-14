import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_downloads_folder.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_gallery.dart';
import 'package:youtube/features/youtube_video_player_screen/data/repo/downloading_repo_impl.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';

abstract final class YtVideoPlayerScreenInj {
  static Future<void> inject() async {
    final audioAppStorage = DownloadAudioInAppStorage();
    final videoAppStorage = DownloadVideoInAppStorage();

    final audioPhoneStorage = DownloadAudioInDownloadsFolder();
    final videoPhoneStorage = DownloadVideoInGallery();

    final DownloadingVideoRepoImpl downloadingAppStorageImpl = DownloadingVideoRepoImpl(
      audioAppStorage,
      videoAppStorage,
    );

    final DownloadingVideoRepoImpl downloadInPhoneStorage = DownloadingVideoRepoImpl(
      audioPhoneStorage,
      videoPhoneStorage,
    );

    locator.registerLazySingleton<DownloadingRepository>(
      () => downloadingAppStorageImpl,
      instanceName: DownloadingStoragePath.appStorage.name,
    );

    locator.registerLazySingleton<DownloadingRepository>(
      () => downloadInPhoneStorage,
      instanceName: DownloadingStoragePath.phoneStorage.name,
    );
  }
}

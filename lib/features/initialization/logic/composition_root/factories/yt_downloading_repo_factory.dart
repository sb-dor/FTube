import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_audio_datasource/download_audio_in_downloads_folder.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_app_storage.dart';
import 'package:youtube/features/youtube_video_player_screen/data/data_sources/downloading_video_datasource/download_video_in_gallery.dart';
import 'package:youtube/features/youtube_video_player_screen/data/repo/downloading_repo_impl.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';

final class YtDownloadingRepoFactory implements Factory<DownloadingRepository> {
  YtDownloadingRepoFactory({
    required DownloadingStoragePath downloadingStoragePath,
    required DbFloor dbFloor,
    required Permissions permission,
  })  : _downloadingStoragePath = downloadingStoragePath,
        _dbFloor = dbFloor,
        _permissions = permission;

  final DownloadingStoragePath _downloadingStoragePath;
  final DbFloor _dbFloor;
  final Permissions _permissions;

  @override
  DownloadingRepository create() {
    final audioAppStorage = DownloadAudioInAppStorage(_dbFloor);
    final videoAppStorage = DownloadVideoInAppStorage(_dbFloor);

    final audioPhoneStorage = DownloadAudioInDownloadsFolder(_permissions);
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

import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/yt_downloading_repo_factory.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

final class DownloadingAudioUseCase {
  final DownloadingStoragePath path;
  final DbFloor dbFloor;
  final Permissions permission;

  DownloadingAudioUseCase(this.path, this.dbFloor, this.permission);

  Future<void> download({
    required List<int>? downloadingVideo,
    required YoutubeVideoStateModel stateModel,
  }) async {
    final downloadingRepo =
        YtDownloadingRepoFactory(
          downloadingStoragePath: path,
          dbFloor: dbFloor,
          permission: permission,
        ).create();

    await downloadingRepo.downloadVideo(downloadingVideo, stateModel);
  }
}

import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/yt_downloading_repo_factory.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

final class DownloadingVideoUseCase {
  final DownloadingStoragePath path;

  DownloadingVideoUseCase(this.path);

  Future<void> download({
    required List<int>? downloadingVideo,
    required YoutubeVideoStateModel stateModel,
  }) async {
    final downloadingRepo = YtDownloadingRepoFactory(downloadingStoragePath: path).create();

    await downloadingRepo.downloadVideo(downloadingVideo, stateModel);
  }
}

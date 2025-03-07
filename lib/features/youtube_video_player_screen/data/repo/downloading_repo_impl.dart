import 'package:youtube/features/youtube_video_player_screen/data/data_sources/i_downloading.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/repo/downloading_repository.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

class DownloadingVideoRepoImpl implements DownloadingRepository {
  final IDownloading _audioDownloading;
  final IDownloading _videoDownloading;

  DownloadingVideoRepoImpl(this._audioDownloading, this._videoDownloading);

  @override
  Future<void> downloadVideo(List<int>? downloadingVideo, YoutubeVideoStateModel stateModel) =>
      _videoDownloading.download(downloadingVideo, stateModel);

  @override
  Future<void> downloadAudio(List<int>? downloadData, YoutubeVideoStateModel stateModel) =>
      _audioDownloading.download(downloadData, stateModel);
}

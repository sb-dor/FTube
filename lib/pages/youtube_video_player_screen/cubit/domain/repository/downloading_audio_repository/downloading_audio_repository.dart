import 'package:youtube/pages/youtube_video_player_screen/cubit/domain/usecases/download_audio/download_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadingAudioRepository {
  Future<void> download(AudioStreamInfo audioStreamInfo);

  factory DownloadingAudioRepository() {
    return DownloadAudio();
  }
}

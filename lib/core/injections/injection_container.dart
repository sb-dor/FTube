import 'package:youtube/core/injections/yt_video_player_screen_inj/yt_video_player_screen_inj.dart';
import 'package:youtube/core/services/audio_background_service.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

import 'utils_inj/utils_inj.dart';

// final locator = GetIt.instance;

abstract final class Injections {
  static Future<void> initGetIt() async {
    initYoutubeDataApi();

    // utils inj
    await UtilsInj.utilsInj();

    locator.registerLazySingleton<JustAudioBackgroundHelper>(
      () => JustAudioBackgroundHelper(),
    );

    await locator<JustAudioBackgroundHelper>().initJustAudioBackground();
  }

  static void initYoutubeDataApi() {
    locator.registerLazySingleton<YoutubeDataApi>(
      () => YoutubeDataApi(),
    );
  }
}

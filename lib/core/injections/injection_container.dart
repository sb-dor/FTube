import 'package:youtube/core/injections/yt_video_player_screen_inj/yt_video_player_screen_inj.dart';
import 'package:youtube/core/services/audio_background_service.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

import 'utils_inj/utils_inj.dart';

final locator = GetIt.instance;

abstract final class Injections {
  static Future<void> initGetIt() async {
    initYoutubeDataApi();

    // utils inj
    await UtilsInj.utilsInj();

    // trending screen initialization:
    await TrendsInj.trendsInj();

    // library inj
    await LibraryInj.libraryInj();

    // library downloads inj
    await LibraryDownloadsInj.libraryDownloadsInj();

    // library inner history screens inj
    await HistoryInnerScreenInj.historyInnerScreenInj();

    // library inner playlist screen inj
    await PlaylistInnerScreenInj.playlistInnerScreenInj();

    // home screen injection
    await HomeScreenInj.inject();

    // search screen injection
    await SearchScreenInj.searchScreenInj();

    // youtube video player screen inj
    await YtVideoPlayerScreenInj.inject();

    // db inj
    await DBInj.dbInj();

    //
    locator.registerLazySingleton<YoutubeVideoCubit>(
      () => YoutubeVideoCubit(),
    );

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

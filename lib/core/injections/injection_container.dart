import 'package:get_it/get_it.dart';
import 'package:youtube/core/injections/home_screen_inj/home_screen_inj.dart';
import 'package:youtube/core/injections/library_inj/library_inj.dart';
import 'package:youtube/core/injections/search_screen_inj/search_screen_inj.dart';
import 'package:youtube/core/injections/yt_video_player_screen_inj/yt_video_player_screen_inj.dart';
import 'package:youtube/core/services/music_background_service.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'db_inj/db_inj.dart';
import 'library_downloads_inj/library_downloads_inj.dart';
import 'library_inner_screens_inj/history_inner_screen_inj/history_inner_screen_inj.dart';
import 'library_inner_screens_inj/playlist_inner_screen_inj/playlist_inner_screen_inj.dart';
import 'trends_inj/trends_inj.dart';
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

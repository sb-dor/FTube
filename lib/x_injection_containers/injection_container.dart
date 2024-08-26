import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/services/music_background_service.dart';
import 'package:youtube/x_injection_containers/db_inj/db_inj.dart';
import 'package:youtube/x_injection_containers/library_inj/library_inj.dart';
import 'package:youtube/x_injection_containers/library_inner_screens_inj/history_inner_screen_inj/history_inner_screen_inj.dart';
import 'package:youtube/x_injection_containers/trends_inj/trends_inj.dart';
import 'package:youtube/x_injection_containers/utils_inj/utils_inj.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

import 'library_downloads_inj/library_downloads_inj.dart';
import 'library_inner_screens_inj/playlist_inner_screen_inj/playlist_inner_screen_inj.dart';

final locator = GetIt.instance;

Future<void> initGetIt() async {
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

void initYoutubeDataApi() {
  locator.registerLazySingleton<YoutubeDataApi>(() => YoutubeDataApi());
}

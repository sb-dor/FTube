import 'package:get_it/get_it.dart';
import 'package:youtube/x_injection_containers/db_inj/db_inj.dart';
import 'package:youtube/x_injection_containers/library_inj/library_inj.dart';
import 'package:youtube/x_injection_containers/library_inner_screens_inj/history_inner_screen_inj/history_inner_screen_inj.dart';
import 'package:youtube/x_injection_containers/trends_inj/trends_inj.dart';
import 'package:youtube/x_injection_containers/utils_inj/utils_inj.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';


final locator = GetIt.instance;

Future<void> initGetIt() async {
  initYoutubeDataApi();

  // utils inj
  await UtilsInj.utilsInj();

  // trending screen initialization:
  await TrendsInj.trendsInj();

  // library inj
  await LibraryInj.libraryInj();

  // library inner screens inj
  await HistoryInnerScreenInj.historyInnerScreenInj();

  // db inj
  await DBInj.dbInj();
}

void initYoutubeDataApi() {
  locator.registerLazySingleton<YoutubeDataApi>(() => YoutubeDataApi());
}

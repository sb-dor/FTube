import 'package:get_it/get_it.dart';
import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/data/repository/trends_repository_impl.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/trending_screen/presentation/pages/trending_screen.dart';
import 'package:youtube/x_injection_containers/db_inj/db_inj.dart';
import 'package:youtube/x_injection_containers/library_inj/library_inj.dart';
import 'package:youtube/x_injection_containers/trends_inj/trends_inj.dart';
import 'package:youtube/x_injection_containers/utils_inj/utils_inj.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

import '../features/trending_screen/domain/repository/trends_repository.dart';

final locator = GetIt.instance;

Future<void> initGetIt() async {
  initYoutubeDataApi();

  // utils inj
  await UtilsInj.utilsInj();

  // trending screen initialization:
  await TrendsInj.trendsInj();

  // library inj
  await LibraryInj.libraryInj();

  // db inj
  await DBInj.dbInj();
}

void initYoutubeDataApi() {
  locator.registerLazySingleton<YoutubeDataApi>(() => YoutubeDataApi());
}

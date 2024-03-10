import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/history_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/impls/history_inner_screen_data_source_locally/history_inner_screen_data_source_locally.dart';
import 'package:youtube/features/library_inner_screens/data/repository/history_inner_screen_repository_impl/history_inner_screen_repository_impl.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository/history_inner_screen_repository.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class HistoryInnerScreenInj {
  static Future<void> historyInnerScreenInj() async {
    locator.registerLazySingleton<HistoryInnerScreenDataSource>(
      () => HistoryInnerScreenDataSourceLocally(),
    );

    locator.registerLazySingleton<HistoryInnerScreenRepository>(
      () => HistoryInnerScreenRepositoryImpl(
        locator<HistoryInnerScreenDataSource>(),
      ),
    );

    locator.registerFactory<HistoryInnerScreenBloc>(
      () => HistoryInnerScreenBloc(
        locator<HistoryInnerScreenRepository>(),
      ),
    );
  }
}

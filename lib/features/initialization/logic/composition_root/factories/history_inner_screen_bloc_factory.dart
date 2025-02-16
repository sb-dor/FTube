import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_inner_screens/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/history_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/impls/history_inner_screen_data_source_locally/history_inner_screen_data_source_locally.dart';
import 'package:youtube/features/library_inner_screens/data/repository/history_inner_screen_repository_impl.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository.dart';

final class HistoryInnerScreenBlocFactory implements Factory<HistoryInnerScreenBloc> {
  final DbFloor _dbFloor;

  HistoryInnerScreenBlocFactory(this._dbFloor);

  @override
  HistoryInnerScreenBloc create() {
    final HistoryInnerScreenDataSource dataSource = HistoryInnerScreenDataSourceLocally(_dbFloor);

    final HistoryInnerScreenRepository historyInnerScreenRepository =
        HistoryInnerScreenRepositoryImpl(
      dataSource,
    );

    return HistoryInnerScreenBloc(
      historyInnerScreenRepository,
    );
  }
}

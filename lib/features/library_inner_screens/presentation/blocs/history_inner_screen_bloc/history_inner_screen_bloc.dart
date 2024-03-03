import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository/history_inner_screen_repository.dart';
import 'package:youtube/features/library_inner_screens/domain/usecases/history_inner_screen_usecases/get_all_history_usecase/get_all_history_usecase.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/state_model/history_inner_screen_state_model.dart';
import 'history_inner_screen_event.dart';
import 'history_inner_screen_state.dart';

class HistoryInnerScreenBloc extends Bloc<HistoryInnerScreenEvent, HistoryInnerScreenState> {
  late HistoryInnerScreenStateModel _currentState;
  late GetAllHistoryUsecase _getAllHistoryUsecase;
  final HistoryInnerScreenRepository _historyInnerScreenRepository;

  HistoryInnerScreenBloc(
    this._historyInnerScreenRepository,
  ) : super(LoadingHistoryInnerScreen(HistoryInnerScreenStateModel())) {
    _currentState = state.historyInnerScreenStateModel;
    _getAllHistoryUsecase = GetAllHistoryUsecase(_historyInnerScreenRepository);

    on<RefreshHistoryInnerScreenEvent>(_refreshHistoryInnerScreenEvent);

    //
    on<PaginateHistoryInnerScreenEvent>(_paginateHistoryInnerScreenEvent);
  }

  void _refreshHistoryInnerScreenEvent(
    RefreshHistoryInnerScreenEvent event,
    Emitter<HistoryInnerScreenState> emit,
  ) async {
    emit(LoadingHistoryInnerScreen(_currentState));

    final data = await _getAllHistoryUsecase.getAllHistory();

    _currentState.addPaginate(videos: data);

    emit(LoadedHistoryInnerScreen(_currentState));
  }

  void _paginateHistoryInnerScreenEvent(
    PaginateHistoryInnerScreenEvent event,
    Emitter<HistoryInnerScreenState> emit,
  ) {}
}

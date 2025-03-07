import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository.dart';
import 'history_inner_screen_event.dart';
import 'history_inner_screen_state.dart';
import 'state_model/history_inner_screen_state_model.dart';

class HistoryInnerScreenBloc
    extends Bloc<HistoryInnerScreenEvent, HistoryInnerScreenState> {
  late HistoryInnerScreenStateModel _currentState;
  final HistoryInnerScreenRepository _historyInnerScreenRepository;

  HistoryInnerScreenBloc(this._historyInnerScreenRepository)
    : super(LoadingHistoryInnerScreen(HistoryInnerScreenStateModel())) {
    _currentState = state.historyInnerScreenStateModel;

    on<RefreshHistoryInnerScreenEvent>(_refreshHistoryInnerScreenEvent);

    //
    on<PaginateHistoryInnerScreenEvent>(_paginateHistoryInnerScreenEvent);
  }

  void _refreshHistoryInnerScreenEvent(
    RefreshHistoryInnerScreenEvent event,
    Emitter<HistoryInnerScreenState> emit,
  ) async {
    emit(LoadingHistoryInnerScreen(_currentState));

    final data = await _historyInnerScreenRepository.getHistory();

    _currentState.addPaginate(videos: data);

    emit(LoadedHistoryInnerScreen(_currentState));
  }

  void _paginateHistoryInnerScreenEvent(
    PaginateHistoryInnerScreenEvent event,
    Emitter<HistoryInnerScreenState> emit,
  ) async {
    final data = await _historyInnerScreenRepository.getHistory(
      currentListLength: _currentState.historyVideos.length,
    );

    _currentState.addPaginate(videos: data, paginate: true);

    emit(LoadedHistoryInnerScreen(_currentState));
  }
}

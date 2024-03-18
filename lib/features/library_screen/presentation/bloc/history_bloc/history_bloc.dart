import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_history.dart';
import 'package:youtube/features/library_screen/domain/usecases/save_in_history.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
import 'state_model/history_state_model.dart';

part 'history_events.dart';

part 'history_states.dart';

class HistoryBloc extends Bloc<HistoryEvents, HistoryStates> {
  late HistoryStateModel _currentState;

  final LibraryScreenRepository _libraryScreenRepository;

  late GetHistory _getHistory;

  late SaveInHistory _saveInHistory;

  HistoryBloc(this._libraryScreenRepository) : super(LoadingHistoryState(HistoryStateModel())) {
    // registrations
    _currentState = state.historyStateModel;

    _getHistory = GetHistory(_libraryScreenRepository);

    _saveInHistory = SaveInHistory(_libraryScreenRepository);

    // events
    on<GetHistoryEvent>(_getHistoryEvent);

    on<PaginateHistoryEvent>(_paginateHistoryEvent);

    on<AddOnHistoryEvent>(_addOnHistoryEvent);

    on<InitLengthOfDownloadedFiles>(_initLengthOfDownloadedFiles);
  }

  void _getHistoryEvent(GetHistoryEvent event, Emitter<HistoryStates> emit) async {
    emit(LoadingHistoryState(_currentState));

    final data = await _getHistory.getHistory();

    _currentState.addPaginate(videos: data);

    emit(LoadedHistoryState(_currentState));
  }

  void _paginateHistoryEvent(PaginateHistoryEvent event, Emitter<HistoryStates> emit) async {
    final data = await _getHistory.getHistory();

    _currentState.addPaginate(videos: data, paginate: true);

    _emitter(emit);
  }

  void _addOnHistoryEvent(AddOnHistoryEvent event, Emitter<HistoryStates> emit) async =>
      await _saveInHistory.saveInHistory(event.video);

  void _initLengthOfDownloadedFiles(
    InitLengthOfDownloadedFiles event,
    Emitter<HistoryStates> emit,
  ) async {
    final path = await getExternalStorageDirectory();
    _currentState.lengthOfDownloadedFiles = ((await path?.list().toList()) ?? []).length;
    _emitter(emit);
  }

  _emitter(Emitter<HistoryStates> emit) {
    if (state is LoadingHistoryState) {
      emit(LoadingHistoryState(_currentState));
    } else if (state is ErrorHistoryState) {
      emit(ErrorHistoryState(Constants.errorMessage, _currentState));
    } else if (state is LoadedHistoryState) {
      emit(LoadedHistoryState(_currentState));
    }
  }
}

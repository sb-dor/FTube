import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/utils/mixins/storage_helper.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'state_model/history_state_model.dart';

part 'history_events.dart';

part 'history_states.dart';

class HistoryBloc extends Bloc<HistoryEvents, HistoryStates> with StorageHelper {
  late HistoryStateModel _currentState;

  final LibraryScreenRepository _libraryScreenRepository;


  HistoryBloc(this._libraryScreenRepository) : super(LoadingHistoryState(HistoryStateModel())) {
    // registrations
    _currentState = state.historyStateModel;

    // events
    on<GetHistoryEvent>(_getHistoryEvent);

    on<PaginateHistoryEvent>(_paginateHistoryEvent);

    on<AddOnHistoryEvent>(_addOnHistoryEvent);

    on<InitLengthOfDownloadedFiles>(_initLengthOfDownloadedFiles);
  }

  void _getHistoryEvent(GetHistoryEvent event, Emitter<HistoryStates> emit) async {
    emit(LoadingHistoryState(_currentState));

    final data = await _libraryScreenRepository.getHistory();

    _currentState.addPaginate(videos: data);

    emit(LoadedHistoryState(_currentState));
  }

  void _paginateHistoryEvent(PaginateHistoryEvent event, Emitter<HistoryStates> emit) async {
    final data = await _libraryScreenRepository.getHistory();

    _currentState.addPaginate(videos: data, paginate: true);

    _emitter(emit);
  }

  void _addOnHistoryEvent(AddOnHistoryEvent event, Emitter<HistoryStates> emit) async =>
      await _libraryScreenRepository.saveInHistory(event.video);

  void _initLengthOfDownloadedFiles(
    InitLengthOfDownloadedFiles event,
    Emitter<HistoryStates> emit,
  ) async {
    final Directory? path = await getStorage();
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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_history.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

import 'state_model/history_state_model.dart';

part 'history_events.dart';

part 'history_states.dart';

class HistoryBloc extends Bloc<HistoryEvents, HistoryStates> {
  late HistoryStateModel _currentState;

  final LibraryScreenRepository _libraryScreenRepository;

  late GetHistory _getHistory;

  HistoryBloc(this._libraryScreenRepository) : super(LoadingHistoryState(HistoryStateModel())) {
    _currentState = state.historyStateModel;

    _getHistory = GetHistory(_libraryScreenRepository);

    on<HistoryEvents>((event, emit) {
      // TODO: implement event handler
    });
  }
}

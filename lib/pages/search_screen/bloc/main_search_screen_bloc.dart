import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/state_model/search_screen_state_model.dart';

import 'search_screen_events.dart';
import 'search_screen_states.dart';

class MainSearchScreenBloc extends Bloc<SearchScreenEvents, SearchScreenStates> {

  late SearchScreenStateModel _currentState;

  MainSearchScreenBloc() : super(InitialSearchScreenState(SearchScreenStateModel())) {
    _currentState = state.searchScreenStateModel;
    //
    //
  }
}

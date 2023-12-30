import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/pages/search_screen/bloc/state_model/search_screen_state_model.dart';
import 'package:youtube/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';

import 'search_screen_events.dart';
import 'search_screen_states.dart';

class MainSearchScreenBloc extends Bloc<SearchScreenEvents, SearchScreenStates> {
  late SearchScreenStateModel _currentState;

  MainSearchScreenBloc() : super(InitialSearchScreenState(SearchScreenStateModel())) {
    _currentState = state.searchScreenStateModel;
    //
    //

    on<InitSearchScreenEvent>(initSearchScreenEvent);

    on<ClickSearchButtonEvent>(clickSearchButtonEvent);
  }

  void initSearchScreenEvent(InitSearchScreenEvent event, Emitter<SearchScreenStates> emit) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    searchBodyCubit.searchingBodyState();
    _currentState.searchData = await _currentState.hiveDatabaseHelper.getSearchData();
    emit(InitialSearchScreenState(_currentState));
  }

  void clickSearchButtonEvent(
      ClickSearchButtonEvent event, Emitter<SearchScreenStates> emit) async {
    _currentState.searchData.insert(0, _currentState.searchController.text);
    if (_currentState.searchData.length >= 30) _currentState.searchData.removeLast();
    await _currentState.hiveDatabaseHelper.saveSearchData(listOfSearch: _currentState.searchData);
    emit(InitialSearchScreenState(_currentState));
  }
}

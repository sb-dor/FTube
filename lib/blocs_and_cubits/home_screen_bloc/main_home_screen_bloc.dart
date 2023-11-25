import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_home_screen/rest_api_home_screen.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_bloc_states.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_state_model/home_screen_state_model.dart';

import 'home_screen_bloc_events.dart';

class MainHomeScreenBloc extends Bloc<HomeScreenBlocEvents, HomeScreenStates> {
  late HomeScreenStateModel currentState;

  MainHomeScreenBloc() : super(InitialHomeScreenState(HomeScreenStateModel())) {
    currentState = state.homeScreenStateModel;

    on<RefreshHomeScreenEvent>((event, emit) => refreshHomeScreen(event, emit));

    on<PaginateHomeScreenEvent>((event, emit) => paginateHomeScreen(event, emit));
  }

  Future<void> refreshHomeScreen(
      RefreshHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    var data = await RestApiHomeScreen.homeScreenGetVideo();

    if (data.containsKey("server_error")) {
      // server error
    } else if (data.containsKey("success")) {
      currentState.videos = data['videos'];
    } else {
      // server error
    }
    emitState(emit);
  }

  Future<void> paginateHomeScreen(
      PaginateHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {}

  void emitState(Emitter<HomeScreenStates> emit) {
    if (state is InitialHomeScreenState) {
      emit(InitialHomeScreenState(currentState));
    } else if (state is ErrorHomeScreenState) {
      emit(ErrorHomeScreenState(currentState));
    }
  }
}

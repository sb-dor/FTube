import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_states.dart';

class HomePageBottomNavbarCubit extends Cubit<HomePageBottomNavbarStates> {
  late HomePageBottomNavbarStateModel _currentState;

  HomePageBottomNavbarCubit()
      : super(InitialHomePageBottomNavbarState(HomePageBottomNavbarStateModel())) {
    _currentState = state.homePageBottomNavbarCubit;
  }

  void changePage({required int index}) {
    _currentState.page = index;

    emit(InitialHomePageBottomNavbarState(_currentState));
  }

  void hideBottomNavbar() {
    _currentState.showBottomNavbar = false;
    emit(InitialHomePageBottomNavbarState(_currentState));
  }

  void showBottomNavbar() {
    _currentState.showBottomNavbar = true;
    emit(InitialHomePageBottomNavbarState(_currentState));
  }
}

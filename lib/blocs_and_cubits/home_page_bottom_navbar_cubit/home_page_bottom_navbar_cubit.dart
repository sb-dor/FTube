import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_states.dart';

class HomePageBottomNavbarCubit extends Cubit<HomePageBottomNavbarStates> {
  HomePageBottomNavbarCubit()
      : super(InitialHomePageBottomNavbarState(HomePageBottomNavbarStateModel()));

  void changePage({required int index}) {
    var currentState = state.homePageBottomNavbarCubit;

    currentState.page = index;

    emit(InitialHomePageBottomNavbarState(currentState));
  }
}

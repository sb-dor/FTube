import 'dart:async';

class HomePageBottomNavbarStateModel {
  int page = 0;
  bool showBottomNavbar = true;
  Timer? timeForChangingBottomNavBar;
}

sealed class HomePageBottomNavbarStates {
  HomePageBottomNavbarStateModel homePageBottomNavbarCubit;

  HomePageBottomNavbarStates({required this.homePageBottomNavbarCubit});
}

final class InitialHomePageBottomNavbarState extends HomePageBottomNavbarStates {
  InitialHomePageBottomNavbarState(HomePageBottomNavbarStateModel homePageBottomNavbarStateModel)
      : super(homePageBottomNavbarCubit: homePageBottomNavbarStateModel);
}

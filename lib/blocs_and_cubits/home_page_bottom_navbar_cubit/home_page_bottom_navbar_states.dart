 class HomePageBottomNavbarStateModel {
  int page = 0;
}

abstract class HomePageBottomNavbarStates {
  HomePageBottomNavbarStateModel homePageBottomNavbarCubit;

  HomePageBottomNavbarStates({required this.homePageBottomNavbarCubit});
}

class InitialHomePageBottomNavbarState extends HomePageBottomNavbarStates {
  InitialHomePageBottomNavbarState(HomePageBottomNavbarStateModel homePageBottomNavbarStateModel)
      : super(homePageBottomNavbarCubit: homePageBottomNavbarStateModel);
}

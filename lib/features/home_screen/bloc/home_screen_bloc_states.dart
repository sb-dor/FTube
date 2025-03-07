import 'home_screen_state_model/home_screen_state_model.dart';

sealed class HomeScreenStates {
  HomeScreenStateModel homeScreenStateModel;

  HomeScreenStates({required this.homeScreenStateModel});
}

final class InitialHomeScreenState extends HomeScreenStates {
  InitialHomeScreenState(HomeScreenStateModel homeScreenStateModel)
    : super(homeScreenStateModel: homeScreenStateModel);
}

final class ErrorHomeScreenState extends HomeScreenStates {
  ErrorHomeScreenState(HomeScreenStateModel homeScreenStateModel)
    : super(homeScreenStateModel: homeScreenStateModel);
}

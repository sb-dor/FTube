import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_state_model/home_screen_state_model.dart';

abstract class HomeScreenStates {
  HomeScreenStateModel homeScreenStateModel;

  HomeScreenStates({required this.homeScreenStateModel});
}

class InitialHomeScreenState extends HomeScreenStates {
  InitialHomeScreenState(HomeScreenStateModel homeScreenStateModel)
      : super(homeScreenStateModel: homeScreenStateModel);
}

class ErrorHomeScreenState extends HomeScreenStates {
  ErrorHomeScreenState(HomeScreenStateModel homeScreenStateModel)
      : super(homeScreenStateModel: homeScreenStateModel);
}

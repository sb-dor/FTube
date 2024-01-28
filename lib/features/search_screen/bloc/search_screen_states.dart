import 'state_model/search_screen_state_model.dart';

abstract class SearchScreenStates {
  SearchScreenStateModel searchScreenStateModel;

  SearchScreenStates({required this.searchScreenStateModel});
}

class InitialSearchScreenState extends SearchScreenStates {
  InitialSearchScreenState(SearchScreenStateModel searchScreenStateModel)
      : super(searchScreenStateModel: searchScreenStateModel);
}

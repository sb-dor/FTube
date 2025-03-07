import 'state_model/search_screen_state_model.dart';

sealed class SearchScreenStates {
  SearchScreenStateModel searchScreenStateModel;

  SearchScreenStates({required this.searchScreenStateModel});
}

final class InitialSearchScreenState extends SearchScreenStates {
  InitialSearchScreenState(SearchScreenStateModel searchScreenStateModel)
    : super(searchScreenStateModel: searchScreenStateModel);
}

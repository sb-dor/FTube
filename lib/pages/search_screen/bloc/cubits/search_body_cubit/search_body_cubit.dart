import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_body_states.dart';

class SearchBodyCubit extends Cubit<SearchBodyStates> {
  SearchBodyCubit() : super(SearchingBodyState());

  void searchingBodyState() => emit(SearchingBodyState());

  void loadingSearchBodyState() => emit(LoadingSearchBodyState());

  void errorSearchBodyState() => emit(ErrorSearchBodyState());

  void loadedSearchBodyState() => emit(LoadedSearchBodyState());
}

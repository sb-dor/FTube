import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/search_screen/data/repo/search_screen_repo_impl.dart';
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';
import 'package:youtube/features/search_screen/presentation/bloc/main_search_screen_bloc.dart';

final class SearchScreenBlocFactory implements Factory<MainSearchScreenBloc> {
  @override
  MainSearchScreenBloc create() {
    final SearchScreenRepo searchScreenRepo = SearchScreenRepoImpl();

    return MainSearchScreenBloc(searchScreenRepo);
  }
}

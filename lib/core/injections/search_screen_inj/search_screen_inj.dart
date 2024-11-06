import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/search_screen/data/repo/search_screen_repo_impl.dart';
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';
import 'package:youtube/features/search_screen/presentation/bloc/main_search_screen_bloc.dart';

abstract final class SearchScreenInj {
  static Future<void> searchScreenInj() async {
    final SearchScreenRepo searchScreenRepo = SearchScreenRepoImpl();

    locator.registerFactory(
      () => MainSearchScreenBloc(searchScreenRepo),
    );
  }
}

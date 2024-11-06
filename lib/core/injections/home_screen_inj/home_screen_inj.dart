import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/home_screen/data/repo/home_screen_repo_impl.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'package:youtube/features/home_screen/presentation/bloc/main_home_screen_bloc.dart';

abstract final class HomeScreenInj {
  static Future<void> inject() async {
    final homeScreenRepoImpl = HomeScreenRepoImpl();

    locator.registerFactory<MainHomeScreenBloc>(
      () => MainHomeScreenBloc(
        homeScreenRepoImpl,
      ),
    );
  }
}

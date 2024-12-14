import 'package:youtube/features/home_screen/data/repo/home_screen_repo_impl.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'package:youtube/features/home_screen/presentation/bloc/main_home_screen_bloc.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class HomeScreenBlocFactory implements Factory<MainHomeScreenBloc> {
  @override
  MainHomeScreenBloc create() {
    final HomeScreenRepo homeScreenRepoImpl = HomeScreenRepoImpl();

    return MainHomeScreenBloc(
      homeScreenRepoImpl,
    );
  }
}

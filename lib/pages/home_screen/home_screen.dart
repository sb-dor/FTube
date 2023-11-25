import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_bloc_events.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/main_home_screen_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final mainHomeScreenState = context.watch<MainHomeScreenBloc>().state;

      //data
      var mainHomeScreenStateModel = mainHomeScreenState.homeScreenStateModel;

      return RefreshIndicator(
        onRefresh: () async {
          context.read<MainHomeScreenBloc>().add(RefreshHomeScreenEvent());
        },
        child: ListView(padding: const EdgeInsets.only(left: 10, right: 10), children: [
          ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: mainHomeScreenStateModel.videos.length,
              itemBuilder: (context, index) {
                var video = mainHomeScreenStateModel.videos[index];
                return Text("${video.snippet?.title}");
              }),
          const SizedBox(height: kBottomNavigationBarHeight + 30)
        ]),
      );
    });
  }
}

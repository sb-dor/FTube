import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/features/initialization/models/app_routes.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screen_overlay_info_feature_cubit.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // context.read<MainAuthBloc>().add(CheckAuthEvent(authorizationService: GoogleService()));
    context.read<MainScreenOverlayInfoFeatureCubit>().checkCanUserScroll();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: MaterialApp.router(
        scaffoldMessengerKey: GlobalContextHelper.instance.globalNavigatorContext,
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
      ),
    );
  }
}

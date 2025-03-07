import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_states.dart';
import 'package:youtube/core/widgets/home_page_widgets/bottom_navigation_widget.dart';
import 'package:youtube/core/widgets/home_page_widgets/home_page_appbar.dart';
import 'home_screen/presentation/home_screen.dart';
import 'library_screen/presentation/pages/main_library_page/library_screen.dart';
import 'trending_screen/presentation/pages/trending_screen.dart';

//main page begins here
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer? _timer;
  final bool _animate = false; // make this true to animate
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      TrendingScreen(),
      // SubscriptionsScreen(),
      // InboxScreen(),
      LibraryScreen(),
    ];
    // getRequestForAppOverlayEntry();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // void getRequestForAppOverlayEntry() async {
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     bool? status = await FlutterOverlayWindow.isPermissionGranted();
  //
  //     if (status) return;
  //
  //     status = await FlutterOverlayWindow.requestPermission();
  //
  //     if (!(status ?? false)) {
  //       // show message that user did not allow the permission and overlay will not be shown
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBottomNavbarCubit, HomePageBottomNavbarStates>(
      builder: (context, bottomNavbarStates) {
        final bottomNavbarState = bottomNavbarStates.homePageBottomNavbarCubit;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              kToolbarHeight + 40,
            ),
            child: const HomePageAppBar(),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _screens[bottomNavbarState.page],
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  bottom: bottomNavbarState.showBottomNavbar ? 15 : -200,
                  right: 15,
                  left: 15,
                  child: BottomNavigationWidget(animate: _animate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// final List<TweenSequenceItem<double>> tweenList = List.generate(
//         31,
//         (index) => TweenSequenceItem<double>(
//               tween: Tween(begin: index / 10.0, end: (index + 1) / 10.0),
//               weight: 1,
//             ));
//
//     final TweenSequence<double> tweenSequence = TweenSequence(tweenList);
//
//     _bottomNavBarAnimation = tweenSequence
//         .animate(CurvedAnimation(parent: _bottomNavBarAnimController, curve: Curves.linear));

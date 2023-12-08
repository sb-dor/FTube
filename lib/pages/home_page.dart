import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_states.dart';
import 'package:youtube/widgets/home_page_widgets/home_page_appbar.dart';

import '../widgets/home_page_widgets/bottom_navigation_widget.dart';
import 'home_screen/home_screen.dart';
import 'inbox_screen/inbox_screen.dart';
import 'library_screen/library_screen.dart';
import 'subscriptions_screen/subscriptions_screen.dart';
import 'trending_screen/trending_screen.dart';

//main page begins here
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    // _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    //   setState(() {
    //     _animate = !_animate;
    //   });
    // }); // recomment for animation
    _screens = const [
      HomeScreen(),
      TrendingScreen(),
      SubscriptionsScreen(),
      InboxScreen(),
      LibraryScreen(),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBottomNavbarCubit, HomePageBottomNavbarStates>(
        builder: (context, bottomNavbarStates) {
      var bottomNavbarState = bottomNavbarStates.homePageBottomNavbarCubit;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, kToolbarHeight + 40),
            child: const HomePageAppBar()),
        body: SafeArea(
            child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: _screens[bottomNavbarState.page],
          ),
          Positioned(
            bottom: 15,
            right: 15,
            left: 15,
            child: BottomNavigationWidget(animate: _animate),
          )
        ])),
      );
    });
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

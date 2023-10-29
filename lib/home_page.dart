import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/pages/home_screen/home_screen.dart';
import 'package:youtube/pages/inbox_screen/inbox_screen.dart';
import 'package:youtube/pages/library_screen/library_screen.dart';
import 'package:youtube/pages/subscriptions_screen/subscriptions_screen.dart';
import 'package:youtube/pages/trending_screen/trending_screen.dart';
import 'package:youtube/widgets/home_page_widgets/home_page_appbar.dart';

//main page begins here
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer? _timer;
  bool _animate = true;
  late List<Widget> _screens;
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _animate = !_animate;
      });
    });
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
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, kToolbarHeight + 40),
          child: const HomePageAppBar()),
      body: SafeArea(
          child: Stack(children: [
        _screens[_selectedIndex],
        Positioned(
            bottom: 15,
            right: 15,
            left: 15,
            child: AnimatedContainer(
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              height: kBottomNavigationBarHeight + 10,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: _animate ? 3 : 0.3,
                      spreadRadius: _animate ? 0.5 : 0)
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedIndex = 0;
                  }),
                  child: Container(
                      color: Colors.transparent,
                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.laptop, size: 25),
                            SizedBox(height: 5),
                            Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            )
                          ])),
                )),
                Expanded(
                    child: GestureDetector(
                        onTap: () => setState(() {
                              _selectedIndex = 1;
                            }),
                        child: Container(
                            color: Colors.transparent,
                            child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.boltLightning, size: 25),
                                  SizedBox(height: 5),
                                  Text(
                                    "Trending",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  )
                                ])))),
                Expanded(
                    child: Container(
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                      FaIcon(FontAwesomeIcons.peopleGroup, size: 25),
                      SizedBox(height: 5),
                      Text(
                        "Subscription",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      )
                    ]))),
                Expanded(
                    child: Container(
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                      FaIcon(FontAwesomeIcons.inbox, size: 25),
                      SizedBox(height: 5),
                      Text(
                        "Inbox",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      )
                    ]))),
                Expanded(
                    child: Container(
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                      FaIcon(FontAwesomeIcons.folder, size: 25),
                      SizedBox(height: 5),
                      Text(
                        "Library",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      )
                    ]))),
              ]),
            ))
      ])),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_states.dart';
import 'package:youtube/core/utils/analytics/analytics_event.dart';
import 'package:youtube/features/initialization/models/dependency_container.dart';

class BottomNavigationWidget extends StatefulWidget {
  final bool animate;

  const BottomNavigationWidget({Key? key, required this.animate}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBottomNavbarCubit, HomePageBottomNavbarStates>(
      builder: (context, bottomNavbarStates) {
        var bottomNavBarState = bottomNavbarStates.homePageBottomNavbarCubit;
        return AnimatedContainer(
          curve: Curves.easeInOut,
          duration: const Duration(seconds: 1),
          height: kBottomNavigationBarHeight + 10,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: widget.animate ? 3 : 0.3,
                  spreadRadius: widget.animate ? 0.5 : 0)
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () async {
                  context.read<HomePageBottomNavbarCubit>().changePage(index: 0);
                  await Provider.of<DependencyContainer>(context, listen: false)
                      .analyticsReporter
                      .report(
                        TabAnalyticEvent("home"),
                      );
                },
                child: Container(
                    color: Colors.transparent,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.laptop,
                              size: 25,
                              color: bottomNavBarState.page == 0
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.3)),
                          const SizedBox(height: 5),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 375),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                color: bottomNavBarState.page == 0
                                    ? Colors.red
                                    : Colors.black.withOpacity(0.3)),
                            child: const Text(
                              "Home",
                              maxLines: 1,
                            ),
                          )
                        ])),
              )),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    context.read<HomePageBottomNavbarCubit>().changePage(index: 1);
                    await Provider.of<DependencyContainer>(context, listen: false)
                        .analyticsReporter
                        .report(
                          TabAnalyticEvent("trending"),
                        );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.boltLightning,
                            size: 25,
                            color: bottomNavBarState.page == 1
                                ? Colors.red
                                : Colors.black.withOpacity(0.3)),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 375),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: bottomNavBarState.page == 1
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.3)),
                          child: const Text(
                            "Trending",
                            maxLines: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded(
              //     child: GestureDetector(
              //   onTap: () => context.read<HomePageBottomNavbarCubit>().changePage(index: 2),
              //   child: Container(
              //       color: Colors.transparent,
              //       child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             FaIcon(
              //               FontAwesomeIcons.peopleGroup,
              //               size: 25,
              //               color: bottomNavBarState.page == 2
              //                   ? Colors.red
              //                   : Colors.black.withOpacity(0.3),
              //             ),
              //             const SizedBox(height: 5),
              //             AnimatedDefaultTextStyle(
              //               style: TextStyle(
              //                   fontSize: 10,
              //                   fontWeight: FontWeight.bold,
              //                   overflow: TextOverflow.ellipsis,
              //                   color: bottomNavBarState.page == 2
              //                       ? Colors.red
              //                       : Colors.black.withOpacity(0.3)),
              //               duration: const Duration(milliseconds: 375),
              //               child: const Text(
              //                 "Subscription",
              //                 maxLines: 1,
              //               ),
              //             )
              //           ])),
              // )),
              // Expanded(
              //     child: GestureDetector(
              //   onTap: () => context.read<HomePageBottomNavbarCubit>().changePage(index: 3),
              //   child: Container(
              //       color: Colors.transparent,
              //       child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             FaIcon(
              //               FontAwesomeIcons.inbox,
              //               size: 25,
              //               color: bottomNavBarState.page == 3
              //                   ? Colors.red
              //                   : Colors.black.withOpacity(0.3),
              //             ),
              //             const SizedBox(height: 5),
              //             AnimatedDefaultTextStyle(
              //               duration: const Duration(milliseconds: 375),
              //               style: TextStyle(
              //                   fontSize: 10,
              //                   fontWeight: FontWeight.bold,
              //                   overflow: TextOverflow.ellipsis,
              //                   color: bottomNavBarState.page == 3
              //                       ? Colors.red
              //                       : Colors.black.withOpacity(0.3)),
              //               child: const Text(
              //                 "Inbox",
              //                 maxLines: 1,
              //               ),
              //             )
              //           ])),
              // )),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    context.read<HomePageBottomNavbarCubit>().changePage(index: 2);
                    await Provider.of<DependencyContainer>(context, listen: false)
                        .analyticsReporter
                        .report(
                          TabAnalyticEvent("library"),
                        );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.folder,
                            size: 25,
                            color: bottomNavBarState.page == 2
                                ? Colors.red
                                : Colors.black.withOpacity(0.3)),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: bottomNavBarState.page == 2
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.3)),
                          duration: const Duration(milliseconds: 375),
                          child: const Text(
                            "Library",
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

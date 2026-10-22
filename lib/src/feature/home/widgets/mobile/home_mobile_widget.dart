import 'package:flutter/material.dart';
import 'package:youtube/src/feature/feed/widgets/feed_config_widget.dart';
import 'package:youtube/src/feature/home/widgets/home_config_widget.dart';
import 'package:youtube/src/feature/home/widgets/mobile/home_app_bar.dart';
import 'package:youtube/src/feature/home/widgets/mobile/home_bottom_bar.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/library/widgets/library_config_widget.dart';
import 'package:youtube/src/feature/trending/widgets/trending_config_widget.dart';

class HomeMobileWidget extends StatefulWidget {
  const HomeMobileWidget({super.key});

  @override
  State<HomeMobileWidget> createState() => _HomeMobileWidgetState();
}

class _HomeMobileWidgetState extends State<HomeMobileWidget> {
  late final _controller = HomeConfigInhWidget.of(context).homeDataController;

  bool _onScroll(UserScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _controller.onUserScroll(notification.direction);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HomeAppBar(),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<UserScrollNotification>(
                onNotification: _onScroll,
                child: IndexedStack(
                  index: _controller.tab.index,
                  children: const [
                    FeedConfigWidget(),
                    TrendingConfigWidget(),
                    LibraryConfigWidget(),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: _controller.bottomBarVisible ? 15 : -200,
              left: 15,
              right: 15,
              child: HomeBottomBar(
                tab: _controller.tab,
                onSelected: (tab) {
                  _controller.selectTab(tab);
                  DependenciesScope.of(context).analytics.screenTab(tab.analyticsName);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

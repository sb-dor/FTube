import 'package:flutter/material.dart';
import 'package:youtube/src/feature/home/widgets/controllers/home_data_controller.dart';
import 'package:youtube/src/feature/home/widgets/mobile/home_mobile_widget.dart';

/// Provides [HomeConfigWidgetState] to the home screen.
class HomeConfigInhWidget extends InheritedWidget {
  const HomeConfigInhWidget({required this.state, required super.child, super.key});

  final HomeConfigWidgetState state;

  static HomeConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<HomeConfigInhWidget>()?.widget;
    assert(widget != null, 'HomeConfigInhWidget was not found in the widget tree');
    return (widget! as HomeConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant HomeConfigInhWidget oldWidget) => false;
}

/// The app's main screen: Home, Trending and Library tabs.
class HomeConfigWidget extends StatefulWidget {
  const HomeConfigWidget({super.key});

  @override
  State<HomeConfigWidget> createState() => HomeConfigWidgetState();
}

class HomeConfigWidgetState extends State<HomeConfigWidget> {
  late final HomeDataController homeDataController;

  @override
  void initState() {
    super.initState();
    homeDataController = HomeDataController();
  }

  @override
  void dispose() {
    homeDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      HomeConfigInhWidget(state: this, child: const HomeMobileWidget());
}

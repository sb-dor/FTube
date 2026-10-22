import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:youtube/src/feature/home/models/home_tab.dart';

/// Selected tab and bottom-bar visibility of the home screen.
class HomeDataController with ChangeNotifier {
  HomeTab _tab = HomeTab.feed;
  bool _bottomBarVisible = true;
  Timer? _debounce;

  HomeTab get tab => _tab;

  bool get bottomBarVisible => _bottomBarVisible;

  void selectTab(HomeTab tab) {
    _bottomBarVisible = true;
    if (_tab == tab) {
      notifyListeners();
      return;
    }
    _tab = tab;
    notifyListeners();
  }

  /// Hides the bottom bar while the user scrolls down and shows it on scrolling up.
  void onUserScroll(ScrollDirection direction) {
    final visible = switch (direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => null,
    };
    if (visible == null || visible == _bottomBarVisible) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      _bottomBarVisible = visible;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

import 'package:flutter/cupertino.dart';

class GlobalContextHelper {
  static GlobalContextHelper? _instance;

  static GlobalContextHelper get instance => _instance ??= GlobalContextHelper._();

  GlobalContextHelper._();

  GlobalKey<NavigatorState> globalNavigatorContext = GlobalKey<NavigatorState>();
}

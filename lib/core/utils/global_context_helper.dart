import 'package:flutter/material.dart';

class GlobalContextHelper {
  static GlobalContextHelper? _instance;

  static GlobalContextHelper get instance =>
      _instance ??= GlobalContextHelper._();

  GlobalContextHelper._();

  GlobalKey<ScaffoldMessengerState> globalNavigatorContext =
      GlobalKey<ScaffoldMessengerState>();
}

import 'package:flutter/cupertino.dart';
import 'package:youtube/pages/home_page.dart';

abstract class AppRoutes {
  static Map<String, WidgetBuilder> routes() => {
        "/": (_) => const HomePage(),
      };
}

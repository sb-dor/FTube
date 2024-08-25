// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
//
// abstract final class VideoBackgroundService {
//   static final backgroundService = FlutterBackgroundService();
//
//   static Future<void> startBackgroundService() async {
//     //
//     await backgroundService.startService();
//   }
//
//   static Future<void> stopBackgroundService() async {
//     //
//     backgroundService.invoke('stop');
//   }
//
//   static Future<void> initBackgroundService() async {
//     await backgroundService.configure(
//       iosConfiguration: IosConfiguration(
//         autoStart: false,
//         onForeground: onStart,
//         onBackground: onIosBackground,
//       ),
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         isForegroundMode: false,
//         autoStart: false,
//         autoStartOnBoot: false,
//       ),
//     );
//   }
// }
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//
//   return true;
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance instance) async {
//   //
// }

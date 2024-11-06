import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/initialization/logic/app_runner.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/top_overlay_feature/view/pages/top_overlay_feature.dart';

// overlay entry point
// @pragma("vm:entry-point")
// void overlayMain() {
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider<TopOverlayFeatureBloc>(
//           create: (_) => TopOverlayFeatureBloc(),
//         )
//       ],
//       child: const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: TopOverlayFeature(),
//       ),
//     ),
//   );
// }

void main() {
  runZonedGuarded(
    () async => await AppRunner().init(),
    (error, stackTrace) {
      // logic for handling error here
    },
  );
}

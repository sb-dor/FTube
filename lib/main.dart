import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:youtube/features/initialization/logic/app_runner.dart';
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
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

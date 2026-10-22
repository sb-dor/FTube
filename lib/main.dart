import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/app_zone.dart';
import 'package:youtube/src/common/utils/error_util/error_util.dart';
import 'package:youtube/src/feature/initialization/data/initialization.dart';
import 'package:youtube/src/feature/initialization/widgets/app.dart';

void main() => appZone(
  () => $initializeApp(
    onSuccess: (dependencies) async => runApp(dependencies.inject(child: const App())),
    onError: (error, stackTrace) async {
      runApp(const _BootErrorApp());
      await ErrorUtil.logError(error, stackTrace, code: 'BOOT_FAILED');
    },
  ),
);

/// Shown when initialization fails.
class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: Localization.localizationsDelegates,
    supportedLocales: Localization.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(Localization.of(context).errorGeneric, textAlign: TextAlign.center),
          ),
        ),
      ),
    ),
  );
}

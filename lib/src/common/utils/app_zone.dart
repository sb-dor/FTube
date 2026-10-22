import 'dart:async';
import 'dart:io' show Platform;

import 'package:l/l.dart';
import 'package:youtube/src/common/utils/error_util/error_util.dart';

/// Catches all application errors and logs them.
// ignore: experimental_member_use
void appZone(Future<void> Function() fn) => l.capture<void>(
  () => runZonedGuarded<void>(() => fn(), ErrorUtil.logError),
  LogOptions(
    messageFormatting: _messageFormatting,
    handlePrint: true,
    outputInRelease: false,
    printColors: !Platform.isIOS,
  ),
);

Object _messageFormatting(LogMessage log) =>
    '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')} | ${log.message}';

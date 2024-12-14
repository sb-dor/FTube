import 'package:logger/logger.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class AppLoggerFactory extends Factory<Logger> {
  final LogFilter _logFilter;

  AppLoggerFactory({required LogFilter logFilter}) : _logFilter = logFilter;

  @override
  Logger create() {
    return Logger(
      filter: _logFilter,
      printer: PrettyPrinter(
        methodCount: 2,
        // Number of method calls to be displayed
        errorMethodCount: 8,
        // Number of method calls if stacktrace is provided
        lineLength: 120,
        // Width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: ConsoleOutput(),
    );
  }
}

final class NoOpLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return false;
  }
}

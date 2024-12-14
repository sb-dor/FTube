import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/duration_helper/duration_helper.dart';

abstract class DurationFromIso8601Helper {
  static String getDurationFromIso8601({required String? durationString}) {
    if (durationString == null) return '-';
    // "P" indicates the period (duration).
    // "1D" means 1 day.
    // "T" is used to separate the date and time parts.
    // "2M" is means 2 minutes
    // "1S" means 1 second.
    RegExp regex = RegExp('P([0-9]{1,}D)?T([0-9]{1,}H)?([0-9]{1,}M)?([0-9]{1,}S)?');

    RegExpMatch? match = regex.firstMatch(durationString);
    int? days = int.tryParse(_getNumFromString(value: match?.group(1)));
    int? hours = int.tryParse(_getNumFromString(value: match?.group(2)));
    int? minutes = int.tryParse(_getNumFromString(value: match?.group(3)));
    int? seconds = int.tryParse(_getNumFromString(value: match?.group(4)));

    Duration? duration = Duration(
      days: days ?? 0,
      hours: hours ?? 0,
      minutes: minutes ?? 0,
      seconds: seconds ?? 0,
    );

    final durationHelper = DurationHelper();

    return durationHelper.getFromDuration(duration);
  }

  static String _getNumFromString({required String? value}) {
    if (value == null || value.isEmpty) return '';
    String res = "";
    for (int i = 0; i < value.length; i++) {
      if (value[i] == '' || value[i] == ' ') continue;
      if (int.tryParse(value[i]) == null) continue;
      res += value[i];
    }
    return res;
  }
}

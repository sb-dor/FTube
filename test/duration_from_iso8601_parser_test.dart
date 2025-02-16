import 'package:flutter_test/flutter_test.dart';

void main() {
  String getNumFromString({required String? value}) {
    if (value == null || value.isEmpty) return '';
    String res = "";
    for (int i = 0; i < value.length; i++) {
      if (value[i] == '' || value[i] == ' ') continue;
      if (int.tryParse(value[i]) == null) continue;
      res += value[i];
    }
    return res;
  }

  String getFromDuration(Duration? duration) {
    String res = '';
    final int days = duration?.inDays ?? 0;
    if (days != 0) {
      res += '$days:';
    }
    final int hours = (duration?.inHours ?? 0) - (24 * (duration?.inDays ?? 0));
    if (days != 0) {
      if (hours >= 0 && hours <= 9) {
        res += '0$hours:';
      } else {
        res += '$hours:';
      }
    } else {
      if (hours != 0) {
        if (hours >= 0 && hours <= 9) {
          res += '0$hours:';
        } else {
          res += '$hours:';
        }
      }
    }
    final int minutes = (duration?.inMinutes ?? 0) - (60 * (duration?.inHours ?? 0));
    if (minutes >= 0 && minutes <= 9) {
      res += "0$minutes:";
    } else {
      res += '$minutes:';
    }
    //to get totalSeconds in 60 type second
    final int seconds = (duration?.inSeconds ?? 0) - (60 * (duration?.inMinutes ?? 0));
    if (seconds >= 0 && seconds <= 9) {
      res += "0$seconds";
    } else {
      res += '$seconds';
    }

    return res;
  }

  String getDurationFromIso8601({required String durationString}) {
    // "P" indicates the period (duration).
    // "1D" means 1 day.
    // "T" is used to separate the date and time parts.
    // "2M" is means 2 minutes
    // "1S" means 1 second.
    final RegExp regex = RegExp('P([0-9]{1,}D)?T([0-9]{1,}H)?([0-9]{1,}M)?([0-9]{1,}S)?');

    final RegExpMatch? match = regex.firstMatch(durationString);
    final int? days = int.tryParse(getNumFromString(value: match?.group(1)));
    final int? hours = int.tryParse(getNumFromString(value: match?.group(2)));
    final int? minutes = int.tryParse(getNumFromString(value: match?.group(3)));
    final int? seconds = int.tryParse(getNumFromString(value: match?.group(4)));

    final Duration duration =
        Duration(days: days ?? 0, hours: hours ?? 0, minutes: minutes ?? 0, seconds: seconds ?? 0);

    return getFromDuration(duration);
  }

  group('duration_from_iso8601_parser_test', () {
    test("first_test", () {
      final String time = 'PT1H10M8S';

      expect("01:10:08", getDurationFromIso8601(durationString: time));
    });

    test("second_test", () {
      final String time = 'PT3M57S';

      expect("03:57", getDurationFromIso8601(durationString: time));
    });

    test('third_test', () {
      final String time = 'PT1H9S';
      expect('01:00:09', getDurationFromIso8601(durationString: time));
    });

    test('fourth_test', () {
      final String time = 'PT20S';
      expect('00:20', getDurationFromIso8601(durationString: time));
    });

    test('fifth_test', () {
      final String time = 'P1DT1S';
      expect('1:00:00:01', getDurationFromIso8601(durationString: time));
    });

    test('sixth_test', () {
      final String time = 'PT10H3M46S';
      expect('10:03:46', getDurationFromIso8601(durationString: time));
    });

    test('seventh_test', () {
      final String time = 'PT1M1S';
      expect('01:01', getDurationFromIso8601(durationString: time));
    });
  });
}

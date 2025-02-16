class DurationHelper {
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
        res += '$hours:';
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
}

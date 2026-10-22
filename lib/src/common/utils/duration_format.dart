/// `1:02:03` / `2:03` text for a duration.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds' : '$minutes:$seconds';
}

/// Parses YouTube duration text such as `12:34` or `1:02:03` into seconds.
int? secondsFromDurationText(String? text) {
  if (text == null) return null;
  final parts = text.trim().split(':');
  if (parts.isEmpty || parts.length > 3) return null;
  var seconds = 0;
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null) return null;
    seconds = seconds * 60 + value;
  }
  return seconds;
}

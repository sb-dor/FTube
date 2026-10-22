/// Turns a video title into a safe file name (no path separators or reserved characters),
/// at most [maxLength] characters.
String safeFileName(String title, {int maxLength = 80}) {
  final cleaned = title
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'^\.+'), '');
  final name = cleaned.isEmpty ? 'video' : cleaned;
  return name.length <= maxLength ? name : name.substring(0, maxLength).trimRight();
}

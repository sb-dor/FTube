/// Extracts an 11-character YouTube video id from a link or returns null.
///
/// Supports `watch?v=`, `youtu.be/`, `shorts/`, `embed/`, `live/` and `v/` links on the
/// `www.`, `m.` and `music.` hosts, and a bare id.
String? videoIdFromLink(String text) {
  final value = text.trim();
  if (_idPattern.hasMatch(value)) return value;
  final uri = Uri.tryParse(value.startsWith('http') ? value : 'https://$value');
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  String? candidate;
  if (host == 'youtu.be') {
    candidate = uri.pathSegments.firstOrNull;
  } else if (host.endsWith('youtube.com') || host.endsWith('youtube-nocookie.com')) {
    candidate = uri.queryParameters['v'];
    final segments = uri.pathSegments;
    if (candidate == null &&
        segments.length >= 2 &&
        const {'shorts', 'embed', 'live', 'v'}.contains(segments.first)) {
      candidate = segments[1];
    }
  }
  return candidate != null && _idPattern.hasMatch(candidate) ? candidate : null;
}

/// The id of a YouTube video linked in free [text], e.g. a search query. Only link-like words
/// count, so an ordinary 11-letter word such as "programming" is never mistaken for a bare id.
String? videoIdInText(String text) {
  for (final word in text.split(RegExp(r'\s+'))) {
    if (!word.toLowerCase().contains('youtu')) continue;
    final id = videoIdFromLink(word);
    if (id != null) return id;
  }
  return null;
}

/// Short share link for a video.
Uri videoShareLink(String videoId) => Uri.https('youtu.be', '/$videoId');

/// YouTube's standard high-quality thumbnail for a video.
String videoThumbnailUrl(String videoId) => 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

final _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

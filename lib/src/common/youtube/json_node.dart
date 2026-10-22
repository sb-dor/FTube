import 'dart:convert';

/// A null-safe view over decoded JSON for walking YouTube's deeply nested responses.
///
/// Indexing never throws: a missing key, an out-of-range index or a type mismatch yields a
/// node whose [value] is null.
extension type const JsonNode(Object? value) {
  /// Child by map key ([String]) or list index ([int]).
  JsonNode operator [](Object key) => switch ((value, key)) {
    (final Map<Object?, Object?> map, final String name) => JsonNode(map[name]),
    (final List<Object?> list, final int index) when index >= 0 && index < list.length => JsonNode(
      list[index],
    ),
    _ => const JsonNode(null),
  };

  bool get isNull => value == null;

  String? get string => switch (value) {
    final String text when text.isNotEmpty => text,
    _ => null,
  };

  List<JsonNode> get list => switch (value) {
    final List<Object?> items => [for (final item in items) JsonNode(item)],
    _ => const [],
  };

  bool has(String key) => switch (value) {
    final Map<Object?, Object?> map => map.containsKey(key),
    _ => false,
  };

  /// YouTube text object: `{simpleText: ...}` or `{runs: [{text: ...}]}` or `{content: ...}`.
  String? get text =>
      this['simpleText'].string ??
      this['content'].string ??
      switch (this['runs'].list) {
        final runs when runs.isNotEmpty => runs.map((run) => run['text'].string ?? '').join(),
        _ => null,
      };

  /// URL of the largest image in a `{thumbnails: [...]}` or `{sources: [...]}` object.
  String? get largestImageUrl {
    final images = this['thumbnails'].isNull ? this['sources'].list : this['thumbnails'].list;
    if (images.isEmpty) return null;
    final url = images.last['url'].string;
    return url != null && url.startsWith('//') ? 'https:$url' : url;
  }

  /// Depth-first search for the first node that has [key].
  JsonNode find(String key) {
    final stack = <Object?>[value];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current is Map<Object?, Object?>) {
        if (current.containsKey(key)) return JsonNode(current[key]);
        stack.addAll(current.values.toList().reversed);
      } else if (current is List<Object?>) {
        stack.addAll(current.reversed);
      }
    }
    return const JsonNode(null);
  }
}

/// Extracts the JSON object assigned to `ytInitialData` in a YouTube HTML page.
JsonNode extractInitialData(String html) {
  for (final marker in const ['var ytInitialData = ', 'window["ytInitialData"] = ']) {
    final start = html.indexOf(marker);
    if (start == -1) continue;
    final from = start + marker.length;
    final end = html.indexOf(';</script>', from);
    if (end == -1) continue;
    final decoded = jsonDecode(html.substring(from, end));
    return JsonNode(decoded);
  }
  throw const FormatException('ytInitialData was not found in the page');
}

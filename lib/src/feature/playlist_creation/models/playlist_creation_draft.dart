import 'package:flutter/foundation.dart';

/// The "New playlist" form as typed: the [name] and whether the user already tried to submit it.
@immutable
class PlaylistCreationDraft {
  const PlaylistCreationDraft({this.name = '', this.submitted = false});

  final String name;

  /// Whether a submit was attempted, so validation errors may be shown.
  final bool submitted;

  PlaylistCreationDraft copyWith({String? name, bool? submitted}) =>
      PlaylistCreationDraft(name: name ?? this.name, submitted: submitted ?? this.submitted);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistCreationDraft && other.name == name && other.submitted == submitted;

  @override
  int get hashCode => Object.hash(name, submitted);

  @override
  String toString() => 'PlaylistCreationDraft($name, submitted: $submitted)';
}

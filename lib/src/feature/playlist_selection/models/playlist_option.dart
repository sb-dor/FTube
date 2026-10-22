import 'package:flutter/foundation.dart';

/// A user playlist a video can be saved into.
@immutable
class PlaylistOption {
  const PlaylistOption({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlaylistOption && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'PlaylistOption($id, $name)';
}

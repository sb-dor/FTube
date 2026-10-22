import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';

/// The session shown in the mini player, if any.
class MiniPlayerDataController with ChangeNotifier {
  MiniPlayerSession? _session;

  MiniPlayerSession? get session => _session;

  void show(MiniPlayerSession session) {
    _session = session;
    notifyListeners();
  }

  /// Closes the mini player and returns its session with the latest [position].
  MiniPlayerSession? close({Duration? position}) {
    final session = _session;
    if (session == null) return null;
    _session = null;
    notifyListeners();
    return session.copyWith(position: position);
  }
}

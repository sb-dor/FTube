import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';

/// The session shown in the mini player, if any.
class MiniPlayerDataController with ChangeNotifier {
  MiniPlayerSession? _session;
  bool _disposed = false;

  MiniPlayerSession? get session => _session;

  void show(MiniPlayerSession session) {
    _session = session;
    // A closing video screen calls this from dispose, while the widget tree is locked:
    // listeners then rebuild once the frame is done.
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      scheduler.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  /// Closes the mini player and returns its session with the latest [position].
  MiniPlayerSession? close({Duration? position}) {
    final session = _session;
    if (session == null) return null;
    _session = null;
    notifyListeners();
    return session.copyWith(position: position);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:async';

import 'package:control/control.dart';

extension StateControllerX<S extends Object> on StateController<S> {
  /// Completes once the state satisfies [test], e.g. to end a pull-to-refresh spinner when a
  /// reload finishes. Completes immediately when it already does.
  Future<void> waitFor(bool Function(S state) test) {
    if (test(state)) return Future<void>.value();
    final completer = Completer<void>();
    void listener() {
      if (!test(state) && !isDisposed) return;
      removeListener(listener);
      if (!completer.isCompleted) completer.complete();
    }

    addListener(listener);
    return completer.future;
  }
}

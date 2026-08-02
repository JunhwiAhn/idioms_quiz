import 'dart:async';

/// Keeps quiz flow paused until a fullscreen ad reports that it has closed.
class FullscreenAdGate {
  final Completer<void> _closed = Completer<void>();

  Future<void> showAndWait(Future<void> Function() show) async {
    await show();
    await _closed.future;
  }

  void finish() {
    if (!_closed.isCompleted) _closed.complete();
  }
}
